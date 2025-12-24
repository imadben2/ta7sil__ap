<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Subject;
use App\Models\Content;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\StudySession;
use App\Models\Course;
use App\Models\UserSubscription;
use App\Models\DeviceTransferRequest;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    /**
     * Display admin dashboard with comprehensive statistics.
     */
    public function index(Request $request)
    {
        $stats = Cache::remember('dashboard_stats', 300, function () {
            return [
                'overview' => $this->getOverviewStats(),
                'users' => $this->getUserStats(),
                'content' => $this->getContentStats(),
                'engagement' => $this->getEngagementStats(),
                'courses' => $this->getCourseStats(),
                'pending' => $this->getPendingActions(),
            ];
        });

        // Get recent activities (not cached for real-time updates)
        $recentActivities = $this->getRecentActivities();

        return view('admin.dashboard', compact('stats', 'recentActivities'));
    }

    /**
     * Get overview statistics.
     */
    private function getOverviewStats(): array
    {
        $totalUsers = User::where('role', 'student')->count();
        $activeUsers = User::where('role', 'student')
            ->when(Schema::hasColumn('users', 'is_active'), function($query) {
                $query->where('is_active', true);
            })
            ->count();
        $totalContent = Content::count();
        $totalSubjects = Subject::count();

        // Calculate growth percentages
        $lastMonthUsers = User::where('role', 'student')
            ->where('created_at', '>=', now()->subMonth())
            ->count();
        $userGrowth = $totalUsers > 0 ? round(($lastMonthUsers / $totalUsers) * 100, 1) : 0;

        $lastMonthContent = Content::where('created_at', '>=', now()->subMonth())->count();
        $contentGrowth = $totalContent > 0 ? round(($lastMonthContent / $totalContent) * 100, 1) : 0;

        return [
            'total_users' => $totalUsers,
            'active_users' => $activeUsers,
            'total_content' => $totalContent,
            'total_subjects' => $totalSubjects,
            'user_growth' => $userGrowth,
            'content_growth' => $contentGrowth,
            'total_quizzes' => Quiz::count(),
            'total_courses' => Course::count(),
        ];
    }

    /**
     * Get user statistics.
     */
    private function getUserStats(): array
    {
        $today = now()->startOfDay();
        $thisWeek = now()->startOfWeek();
        $thisMonth = now()->startOfMonth();

        return [
            'total' => User::where('role', 'student')->count(),
            'active' => User::where('role', 'student')
                ->when(Schema::hasColumn('users', 'is_active'), function($query) {
                    $query->where('is_active', true);
                })
                ->count(),
            'inactive' => User::where('role', 'student')
                ->when(Schema::hasColumn('users', 'is_active'), function($query) {
                    $query->where('is_active', false);
                })
                ->count(),
            'suspended' => User::where('role', 'student')
                ->when(Schema::hasColumn('users', 'is_banned'), function($query) {
                    $query->where('is_banned', true);
                })
                ->count(),
            'new_today' => User::where('role', 'student')->whereDate('created_at', $today)->count(),
            'new_this_week' => User::where('role', 'student')->where('created_at', '>=', $thisWeek)->count(),
            'new_this_month' => User::where('role', 'student')->where('created_at', '>=', $thisMonth)->count(),
            'active_today' => User::where('role', 'student')
                ->when(Schema::hasColumn('users', 'last_login_at'), function($query) use ($today) {
                    $query->whereDate('last_login_at', $today);
                })
                ->count(),
        ];
    }

    /**
     * Get content statistics.
     */
    private function getContentStats(): array
    {
        return [
            'total' => Content::count(),
            'lessons' => Content::whereHas('contentType', function($q) {
                $q->where('slug', 'lesson');
            })->count(),
            'summaries' => Content::whereHas('contentType', function($q) {
                $q->where('slug', 'summary');
            })->count(),
            'exercises' => Content::whereHas('contentType', function($q) {
                $q->where('slug', 'exercise');
            })->count(),
            'tests' => Content::whereHas('contentType', function($q) {
                $q->where('slug', 'test');
            })->count(),
            'published' => Content::where('is_published', true)->count(),
            'draft' => Content::where('is_published', false)->count(),
            'phases' => AcademicPhase::count(),
            'years' => AcademicYear::count(),
            'streams' => AcademicStream::count(),
            'subjects' => Subject::count(),
        ];
    }

    /**
     * Get engagement statistics.
     */
    private function getEngagementStats(): array
    {
        $today = now()->startOfDay();
        $thisWeek = now()->startOfWeek();
        $thisMonth = now()->startOfMonth();

        $totalSessions = StudySession::count();
        $completedSessions = StudySession::where('status', 'completed')->count();
        $totalQuizAttempts = QuizAttempt::count();
        $completedQuizzes = QuizAttempt::where('status', 'completed')->count();

        return [
            'total_sessions' => $totalSessions,
            'completed_sessions' => $completedSessions,
            'sessions_today' => StudySession::whereDate('created_at', $today)->count(),
            'sessions_this_week' => StudySession::where('created_at', '>=', $thisWeek)->count(),
            'sessions_this_month' => StudySession::where('created_at', '>=', $thisMonth)->count(),
            'total_quiz_attempts' => $totalQuizAttempts,
            'completed_quizzes' => $completedQuizzes,
            'average_score' => QuizAttempt::where('status', 'completed')->avg('score_percentage') ?? 0,
            'total_study_hours' => round(StudySession::where('status', 'completed')->sum('actual_duration_minutes') / 60, 1),
        ];
    }

    /**
     * Get course statistics.
     */
    private function getCourseStats(): array
    {
        return [
            'total_courses' => Course::count(),
            'published_courses' => Course::where('is_published', true)->count(),
            'draft_courses' => Course::where('is_published', false)->count(),
            'total_subscriptions' => UserSubscription::count(),
            'active_subscriptions' => UserSubscription::where('is_active', true)
                ->where('expires_at', '>', now())
                ->count(),
            'expired_subscriptions' => UserSubscription::where('expires_at', '<=', now())->count(),
        ];
    }

    /**
     * Get pending actions requiring admin attention.
     */
    private function getPendingActions(): array
    {
        return [
            'device_transfer_requests' => DeviceTransferRequest::where('status', 'pending')->count(),
            'pending_subscriptions' => UserSubscription::where('is_active', false)
                ->where('expires_at', '>', now())
                ->count(),
            'draft_content' => Content::where('is_published', false)->count(),
            'reported_issues' => 0, // Placeholder for future implementation
        ];
    }

    /**
     * Get recent activities.
     */
    private function getRecentActivities(): array
    {
        $recentUsers = User::where('role', 'student')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get(['id', 'name', 'email', 'created_at']);

        $recentContent = Content::with(['subject', 'contentType'])
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get(['id', 'title_ar', 'content_type_id', 'is_published', 'subject_id', 'created_at']);

        $recentSessions = StudySession::with('user', 'subject')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();

        return [
            'users' => $recentUsers,
            'content' => $recentContent,
            'sessions' => $recentSessions,
        ];
    }

    /**
     * Get chart data for user growth.
     */
    public function userGrowthChart(Request $request)
    {
        $days = $request->get('days', 30);
        $data = [];

        for ($i = $days - 1; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = User::where('role', 'student')
                ->whereDate('created_at', $date)
                ->count();

            $data[] = [
                'date' => $date->format('Y-m-d'),
                'count' => $count,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get chart data for study sessions.
     */
    public function studySessionsChart(Request $request)
    {
        $days = $request->get('days', 30);
        $data = [];

        for ($i = $days - 1; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $sessions = StudySession::whereDate('created_at', $date)->count();
            $completed = StudySession::where('status', 'completed')
                ->whereDate('created_at', $date)
                ->count();
            $hours = StudySession::where('status', 'completed')
                ->whereDate('created_at', $date)
                ->sum('actual_duration_minutes');

            $data[] = [
                'date' => $date->format('Y-m-d'),
                'sessions' => $sessions,
                'completed' => $completed,
                'hours' => round($hours / 60, 1),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get content distribution chart data.
     */
    public function contentDistributionChart()
    {
        $distribution = Content::select('content_type', DB::raw('count(*) as count'))
            ->groupBy('content_type')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $distribution,
        ]);
    }

    /**
     * Get top subjects by engagement.
     */
    public function topSubjectsChart(Request $request)
    {
        $limit = $request->get('limit', 10);

        $subjects = StudySession::select('subject_id', DB::raw('COUNT(*) as sessions'), DB::raw('SUM(actual_duration_minutes) as total_minutes'))
            ->where('status', 'completed')
            ->groupBy('subject_id')
            ->orderBy('total_minutes', 'desc')
            ->take($limit)
            ->with('subject')
            ->get()
            ->map(function ($item) {
                return [
                    'name' => $item->subject->name_ar ?? 'غير محدد',
                    'sessions' => $item->sessions,
                    'hours' => round($item->total_minutes / 60, 1),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $subjects,
        ]);
    }
}
