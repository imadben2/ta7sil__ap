<?php

namespace App\Services;

use App\Models\FcmToken;
use App\Models\Notification;
use App\Models\User;
use App\Models\StudySession;
use App\Models\ExamSchedule;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class NotificationService
{
    /**
     * Firebase FCM API endpoint.
     */
    protected string $fcmApiUrl = 'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send';

    /**
     * Get Firebase access token from service account credentials.
     */
    protected function getFirebaseAccessToken(): ?string
    {
        try {
            $credentialsPath = config('firebase.credentials.file');

            if (!file_exists($credentialsPath)) {
                Log::warning("Firebase credentials file not found at: {$credentialsPath}");
                return null;
            }

            $credentials = json_decode(file_get_contents($credentialsPath), true);

            if (!$credentials) {
                Log::warning("Failed to parse Firebase credentials");
                return null;
            }

            // Create JWT for Google OAuth
            $now = time();
            $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));

            $jwtClaim = base64_encode(json_encode([
                'iss' => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            $signatureInput = $jwtHeader . '.' . $jwtClaim;

            openssl_sign($signatureInput, $signature, $credentials['private_key'], 'SHA256');
            $jwtSignature = base64_encode($signature);

            $jwt = $signatureInput . '.' . $jwtSignature;

            // Exchange JWT for access token
            $response = Http::withOptions(['verify' => false])->asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if ($response->successful()) {
                return $response->json('access_token');
            }

            Log::error("Failed to get Firebase access token: " . $response->body());
            return null;

        } catch (\Exception $e) {
            Log::error("Error getting Firebase access token: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Schedule a study reminder notification.
     */
    public function scheduleStudyReminder(StudySession $session): ?Notification
    {
        $user = $session->user;

        if (!$user->notificationSettings?->shouldReceive('study_reminder')) {
            return null;
        }

        // Schedule 15 minutes before session
        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'study_reminder',
            'title_ar' => 'تذكير بجلسة الدراسة',
            'body_ar' => "حان وقت جلسة {$session->subject->name_ar}",
            'action_type' => 'open_session',
            'action_data' => ['session_id' => $session->id],
            'scheduled_for' => $session->start_time->subMinutes(15),
            'status' => 'pending',
            'priority' => 'normal',
        ]);

        return $notification;
    }

    /**
     * Send immediate session reminder notification.
     * Used by SendSessionRemindersJob to send notifications 15 minutes before session.
     *
     * @param User $user The user to send notification to
     * @param StudySession $session The study session
     * @param array $data Additional data (subject_name, session_type, start_time, duration, minutes_until_start)
     * @return bool Whether the notification was sent successfully
     */
    public function sendSessionReminder(User $user, StudySession $session, array $data = []): bool
    {
        if (!$user->notificationSettings?->shouldReceive('study_reminder')) {
            return false;
        }

        $subjectName = $data['subject_name'] ?? $session->subject->name_ar ?? 'مادة';
        $sessionType = $data['session_type'] ?? 'جلسة دراسية';
        $startTime = $data['start_time'] ?? '';
        $duration = $data['duration'] ?? 0;
        $minutesUntilStart = $data['minutes_until_start'] ?? 15;

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'study_reminder',
            'title_ar' => "تذكير: {$sessionType} - {$subjectName}",
            'body_ar' => "تبدأ جلستك بعد {$minutesUntilStart} دقيقة في الساعة {$startTime} ({$duration} دقيقة)",
            'action_type' => 'open_session',
            'action_data' => ['session_id' => $session->id],
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'normal',
        ]);

        return $this->sendPushNotification($notification);
    }

    /**
     * Schedule exam alert notifications.
     */
    public function scheduleExamAlerts(ExamSchedule $exam): array
    {
        $user = $exam->user;
        $notifications = [];

        if (!$user->notificationSettings?->shouldReceive('exam_alert')) {
            return $notifications;
        }

        $examDate = $exam->exam_date;

        // 7 days before
        if ($examDate->isFuture() && $examDate->diffInDays(now()) <= 7) {
            $notifications[] = Notification::create([
                'user_id' => $user->id,
                'type' => 'exam_alert',
                'title_ar' => 'امتحان قريب',
                'body_ar' => "امتحان {$exam->subject->name_ar} خلال أسبوع",
                'action_type' => 'open_exam',
                'action_data' => ['exam_id' => $exam->id],
                'scheduled_for' => $examDate->copy()->subDays(7)->setTime(9, 0),
                'status' => 'pending',
                'priority' => 'high',
            ]);
        }

        // 3 days before
        if ($examDate->isFuture() && $examDate->diffInDays(now()) <= 3) {
            $notifications[] = Notification::create([
                'user_id' => $user->id,
                'type' => 'exam_alert',
                'title_ar' => 'امتحان قريب جدًا',
                'body_ar' => "3 أيام للامتحان! راجع الملخصات - {$exam->subject->name_ar}",
                'action_type' => 'open_exam',
                'action_data' => ['exam_id' => $exam->id],
                'scheduled_for' => $examDate->copy()->subDays(3)->setTime(18, 0),
                'status' => 'pending',
                'priority' => 'high',
            ]);
        }

        // 24 hours before
        if ($examDate->isFuture() && $examDate->diffInHours(now()) <= 24) {
            $notifications[] = Notification::create([
                'user_id' => $user->id,
                'type' => 'exam_alert',
                'title_ar' => 'امتحان غدًا',
                'body_ar' => "غدًا الامتحان - راجعة أخيرة في {$exam->subject->name_ar}",
                'action_type' => 'open_exam',
                'action_data' => ['exam_id' => $exam->id],
                'scheduled_for' => $examDate->copy()->subDay()->setTime(20, 0),
                'status' => 'pending',
                'priority' => 'high',
            ]);
        }

        // 2 hours before
        if ($examDate->isFuture() && $examDate->diffInHours(now()) <= 2) {
            $notifications[] = Notification::create([
                'user_id' => $user->id,
                'type' => 'exam_alert',
                'title_ar' => 'الامتحان قريب',
                'body_ar' => "الامتحان بعد ساعتين. بالتوفيق!",
                'action_type' => 'open_exam',
                'action_data' => ['exam_id' => $exam->id],
                'scheduled_for' => $examDate->copy()->subHours(2),
                'status' => 'pending',
                'priority' => 'high',
            ]);
        }

        return $notifications;
    }

    /**
     * Send daily summary notification.
     */
    public function sendDailySummary(User $user): ?Notification
    {
        if (!$user->notificationSettings?->shouldReceive('daily_summary')) {
            return null;
        }

        // Get today's statistics
        $stats = $user->userStats;
        $todaySessionsCount = $user->studySessions()
            ->whereDate('start_time', today())
            ->count();

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'daily_summary',
            'title_ar' => 'ملخص اليوم',
            'body_ar' => "أكملت {$todaySessionsCount} جلسة دراسية اليوم! واصل التقدم 💪",
            'action_type' => 'open_stats',
            'action_data' => ['date' => today()->toDateString()],
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $this->sendPushNotification($notification);

        return $notification;
    }

    /**
     * Send weekly summary notification.
     */
    public function sendWeeklySummary(User $user): ?Notification
    {
        if (!$user->notificationSettings?->shouldReceive('weekly_summary')) {
            return null;
        }

        // Get week's statistics
        $weekSessionsCount = $user->studySessions()
            ->where('start_time', '>=', now()->startOfWeek())
            ->count();

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'daily_summary',
            'title_ar' => 'ملخص الأسبوع',
            'body_ar' => "أكملت {$weekSessionsCount} جلسة دراسية هذا الأسبوع! إنجاز رائع 🎉",
            'action_type' => 'open_stats',
            'action_data' => ['week_start' => now()->startOfWeek()->toDateString()],
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $this->sendPushNotification($notification);

        return $notification;
    }

    /**
     * Send achievement notification.
     */
    public function sendAchievementNotification(User $user, string $achievementType, array $data = []): ?Notification
    {
        if (!$user->notificationSettings?->shouldReceive('achievement')) {
            return null;
        }

        $messages = [
            'streak_7_days' => 'حافظت على الاستمرارية لمدة 7 أيام! 🔥',
            'first_quiz' => 'أكملت أول اختبار! بداية رائعة 🎯',
            'course_completed' => 'أنهيت الدورة! إنجاز عظيم 🎓',
            'level_up' => 'ارتقيت إلى المستوى التالي! 🚀',
        ];

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'achievement',
            'title_ar' => 'إنجاز جديد!',
            'body_ar' => $messages[$achievementType] ?? 'أحسنت! استمر في التقدم',
            'action_type' => 'open_achievements',
            'action_data' => array_merge(['achievement_type' => $achievementType], $data),
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'normal',
        ]);

        $this->sendPushNotification($notification);

        return $notification;
    }

    /**
     * Send course update notification.
     */
    public function sendCourseUpdateNotification(User $user, string $courseTitle, string $updateType = 'new_lesson'): ?Notification
    {
        if (!$user->notificationSettings?->shouldReceive('course_update')) {
            return null;
        }

        $messages = [
            'new_lesson' => "درس جديد متاح في {$courseTitle}",
            'instructor_message' => "رسالة جديدة من المدرس في {$courseTitle}",
        ];

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'course_update',
            'title_ar' => 'تحديث الدورة',
            'body_ar' => $messages[$updateType] ?? "تحديث جديد في {$courseTitle}",
            'action_type' => 'open_course',
            'action_data' => ['course_title' => $courseTitle],
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'normal',
        ]);

        $this->sendPushNotification($notification);

        return $notification;
    }

    /**
     * Send push notification via FCM.
     */
    public function sendPushNotification(Notification $notification): bool
    {
        try {
            $user = $notification->user;
            $fcmTokens = $user->fcmTokens()->where('is_active', true)->get();

            if ($fcmTokens->isEmpty()) {
                Log::info("No active FCM tokens found for user {$user->id}");
                $notification->markAsSent();
                return true;
            }

            // Check if user should receive notifications based on preferences
            $settings = $user->notificationSettings;
            if ($settings && !$settings->notifications_enabled) {
                Log::info("Notifications disabled for user {$user->id}");
                $notification->markAsSent();
                return true;
            }

            // Check quiet hours
            if ($settings && $settings->isInQuietHours() && $notification->priority !== 'high') {
                Log::info("In quiet hours for user {$user->id}, skipping notification");
                // Keep as pending to be sent later, or mark as sent based on business logic
                return false;
            }

            // Get Firebase access token
            $accessToken = $this->getFirebaseAccessToken();

            if (!$accessToken) {
                Log::warning("Could not get Firebase access token, falling back to log-only mode");
                Log::info("Would send FCM notification to user {$user->id}", [
                    'title' => $notification->title_ar,
                    'body' => $notification->body_ar,
                    'tokens_count' => $fcmTokens->count(),
                ]);
                $notification->markAsSent();
                return true;
            }

            $projectId = config('firebase.project_id');
            $apiUrl = str_replace('{project_id}', $projectId, $this->fcmApiUrl);

            $successCount = 0;
            $failedTokens = [];

            foreach ($fcmTokens as $fcmToken) {
                $result = $this->sendToSingleToken($apiUrl, $accessToken, $fcmToken->token, $notification);

                if ($result['success']) {
                    $successCount++;
                    $fcmToken->markAsUsed();
                } else {
                    // Check if token is invalid and should be deactivated
                    if ($result['invalidToken']) {
                        $fcmToken->deactivate();
                        $failedTokens[] = $fcmToken->token;
                        Log::warning("Deactivated invalid FCM token for user {$user->id}");
                    }
                }
            }

            Log::info("FCM notification sent to user {$user->id}", [
                'title' => $notification->title_ar,
                'success_count' => $successCount,
                'total_tokens' => $fcmTokens->count(),
                'failed_tokens' => count($failedTokens),
            ]);

            // Mark as sent if at least one token succeeded, or all tokens were invalid
            if ($successCount > 0 || $fcmTokens->count() === count($failedTokens)) {
                $notification->markAsSent();
                return true;
            }

            $notification->markAsFailed();
            return false;

        } catch (\Exception $e) {
            Log::error("Failed to send push notification", [
                'notification_id' => $notification->id,
                'error' => $e->getMessage(),
            ]);

            $notification->markAsFailed();
            return false;
        }
    }

    /**
     * Send notification to a single FCM token.
     */
    protected function sendToSingleToken(string $apiUrl, string $accessToken, string $token, Notification $notification): array
    {
        try {
            // Add RTL mark (U+200F) to force RTL layout for Arabic text
            $rlm = "\u{200F}";
            $title = $rlm . $notification->title_ar;
            $body = $rlm . $notification->body_ar;

            // Build FCM message payload
            $message = [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => [
                        'notification_id' => (string) $notification->id,
                        'type' => $notification->type,
                        'action_type' => $notification->action_type ?? '',
                        'action_data' => json_encode($notification->action_data ?? []),
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ],
                    'android' => [
                        'priority' => $notification->priority === 'high' ? 'high' : 'normal',
                        'notification' => [
                            'channel_id' => config('firebase.fcm.android_channel_id', 'memo_bac_notifications'),
                            'icon' => config('firebase.fcm.default_icon', 'ic_notification'),
                            'color' => config('firebase.fcm.default_color', '#4CAF50'),
                            'sound' => config('firebase.fcm.default_sound', 'default'),
                        ],
                    ],
                    'apns' => [
                        'payload' => [
                            'aps' => [
                                'alert' => [
                                    'title' => $title,
                                    'body' => $body,
                                ],
                                'sound' => config('firebase.fcm.default_sound', 'default'),
                                'badge' => 1,
                            ],
                        ],
                    ],
                ],
            ];

            // Add deep link if available
            if ($notification->action_type && $notification->action_data) {
                $deepLink = $this->buildDeepLink($notification);
                if ($deepLink) {
                    $message['message']['data']['deep_link'] = $deepLink;
                }
            }

            $response = Http::withOptions(['verify' => false])->withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($apiUrl, $message);

            if ($response->successful()) {
                return ['success' => true, 'invalidToken' => false];
            }

            $error = $response->json();
            $errorCode = $error['error']['details'][0]['errorCode'] ?? ($error['error']['code'] ?? 'UNKNOWN');

            // Check for invalid/unregistered token errors
            $invalidTokenErrors = ['UNREGISTERED', 'INVALID_ARGUMENT', 'NOT_FOUND'];

            return [
                'success' => false,
                'invalidToken' => in_array($errorCode, $invalidTokenErrors),
                'error' => $errorCode,
            ];

        } catch (\Exception $e) {
            Log::error("Error sending to FCM token", [
                'error' => $e->getMessage(),
            ]);

            return ['success' => false, 'invalidToken' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Build deep link URL for notification.
     */
    protected function buildDeepLink(Notification $notification): ?string
    {
        $scheme = config('firebase.deep_link.scheme', 'memobac');
        $actionData = $notification->action_data ?? [];

        $sessionId = $actionData['session_id'] ?? '';
        $examId = $actionData['exam_id'] ?? '';
        $quizId = $actionData['quiz_id'] ?? '';
        $courseId = $actionData['course_id'] ?? '';

        $routes = [
            'open_session' => "planner/session/{$sessionId}",
            'open_exam' => "planner/exam/{$examId}",
            'open_quiz' => "quiz/{$quizId}",
            'open_course' => "courses/{$courseId}",
            'open_achievements' => "profile/achievements",
            'open_stats' => "profile/statistics",
        ];

        $path = $routes[$notification->action_type] ?? null;

        if ($path) {
            return "{$scheme}://{$path}";
        }

        return null;
    }

    /**
     * Send notification to multiple users (batch).
     */
    public function sendBatchNotification(array $userIds, string $type, string $titleAr, string $bodyAr, array $actionData = []): int
    {
        $sent = 0;

        foreach ($userIds as $userId) {
            $user = User::find($userId);
            if (!$user) continue;

            $notification = Notification::create([
                'user_id' => $userId,
                'type' => $type,
                'title_ar' => $titleAr,
                'body_ar' => $bodyAr,
                'action_type' => $actionData['action_type'] ?? null,
                'action_data' => $actionData,
                'scheduled_for' => now(),
                'status' => 'pending',
                'priority' => $actionData['priority'] ?? 'normal',
            ]);

            if ($this->sendPushNotification($notification)) {
                $sent++;
            }
        }

        return $sent;
    }

    /**
     * Send system-wide notification to all users.
     */
    public function sendSystemNotification(string $titleAr, string $bodyAr, string $priority = 'normal'): int
    {
        $userIds = User::where('is_active', true)->pluck('id')->toArray();

        return $this->sendBatchNotification($userIds, 'system', $titleAr, $bodyAr, [
            'priority' => $priority,
        ]);
    }

    /**
     * Process due notifications and send them.
     */
    public function processDueNotifications(): int
    {
        $dueNotifications = Notification::due()->get();
        $sent = 0;

        foreach ($dueNotifications as $notification) {
            if ($this->sendPushNotification($notification)) {
                $sent++;
            }
        }

        Log::info("Processed {$sent} due notifications");

        return $sent;
    }
}
