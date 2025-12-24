<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BacStudyDay;
use App\Models\BacStudyDaySubject;
use App\Models\BacStudyDayTopic;
use App\Models\BacWeeklyReward;
use App\Models\UserBacStudyProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BacStudyScheduleController extends Controller
{
    /**
     * Get full study schedule for a stream
     * GET /api/bac-study/schedule/{stream_id}
     */
    public function index($streamId)
    {
        $days = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics'])
            ->byStream($streamId)
            ->active()
            ->orderBy('day_number')
            ->get()
            ->map(function ($day) {
                return $this->formatDayResponse($day);
            });

        return response()->json([
            'success' => true,
            'data' => $days,
            'total_days' => $days->count(),
        ]);
    }

    /**
     * Get study schedule for a specific day
     * GET /api/bac-study/day/{stream_id}/{day_number}
     */
    public function getByDay($streamId, $dayNumber)
    {
        $day = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics'])
            ->byStream($streamId)
            ->where('day_number', $dayNumber)
            ->first();

        if (!$day) {
            return response()->json([
                'success' => false,
                'message' => 'اليوم غير موجود',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatDayResponse($day),
        ]);
    }

    /**
     * Get study schedule for a specific week
     * GET /api/bac-study/week/{stream_id}/{week_number}
     */
    public function getByWeek(Request $request, $streamId, $weekNumber)
    {
        $user = $request->user();
        $startDay = (($weekNumber - 1) * 7) + 1;
        $endDay = $weekNumber * 7;

        $days = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics'])
            ->byStream($streamId)
            ->active()
            ->whereBetween('day_number', [$startDay, $endDay])
            ->orderBy('day_number')
            ->get();

        // Get all topic IDs for this week to fetch progress in one query
        $allTopicIds = $days->flatMap(function ($day) {
            return $day->daySubjects->flatMap->topics->pluck('id');
        });

        // Get user progress for all topics in this week
        $userProgress = collect();
        if ($user && $allTopicIds->isNotEmpty()) {
            $userProgress = UserBacStudyProgress::byUser($user->id)
                ->whereIn('bac_study_day_topic_id', $allTopicIds)
                ->pluck('is_completed', 'bac_study_day_topic_id');
        }

        // Format days with user progress
        $formattedDays = $days->map(function ($day) use ($userProgress) {
            return $this->formatDayResponse($day, $userProgress);
        });

        // Get weekly reward
        $reward = BacWeeklyReward::byStream($streamId)
            ->where('week_number', $weekNumber)
            ->first();

        return response()->json([
            'success' => true,
            'week_number' => (int) $weekNumber,
            'data' => $formattedDays,
            'reward' => $reward ? [
                'title_ar' => $reward->title_ar,
                'description_ar' => $reward->description_ar,
                'movie_title' => $reward->movie_title,
                'movie_image' => $reward->movie_image,
            ] : null,
        ]);
    }

    /**
     * Get all weekly rewards for a stream
     * GET /api/bac-study/rewards/{stream_id}
     */
    public function getRewards(Request $request, $streamId)
    {
        $user = $request->user();

        // Get all days with their topics to check completion per week
        $days = BacStudyDay::byStream($streamId)
            ->with('daySubjects.topics')
            ->get()
            ->groupBy(function ($day) {
                return ceil($day->day_number / 7); // Group by week number
            });

        // Calculate which weeks are completed
        $completedWeeks = [];
        if ($user) {
            foreach ($days as $weekNumber => $weekDays) {
                $weekTopicIds = $weekDays->flatMap(function ($day) {
                    return $day->daySubjects->flatMap->topics->pluck('id');
                });

                if ($weekTopicIds->isEmpty()) {
                    // If no topics in the week, consider it completed
                    $completedWeeks[] = $weekNumber;
                    continue;
                }

                $completedCount = UserBacStudyProgress::byUser($user->id)
                    ->completed()
                    ->whereIn('bac_study_day_topic_id', $weekTopicIds)
                    ->count();

                if ($completedCount >= $weekTopicIds->count()) {
                    $completedWeeks[] = $weekNumber;
                }
            }
        }

        $rewards = BacWeeklyReward::byStream($streamId)
            ->orderBy('week_number')
            ->get()
            ->map(function ($reward) use ($completedWeeks) {
                return [
                    'id' => $reward->id,
                    'week_number' => $reward->week_number,
                    'title_ar' => $reward->title_ar,
                    'description_ar' => $reward->description_ar,
                    'movie_title' => $reward->movie_title,
                    'movie_image' => $reward->movie_image,
                    'is_unlocked' => in_array($reward->week_number, $completedWeeks),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $rewards,
        ]);
    }

    /**
     * Mark a topic as completed
     * POST /api/bac-study/progress/complete
     */
    public function markTopicComplete(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'topic_id' => 'required|exists:bac_study_day_topics,id',
            'is_completed' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        $progress = UserBacStudyProgress::updateOrCreate(
            [
                'user_id' => $user->id,
                'bac_study_day_topic_id' => $request->topic_id,
            ],
            [
                'is_completed' => $request->is_completed,
                'completed_at' => $request->is_completed ? now() : null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => $request->is_completed ? 'تم إكمال المهمة' : 'تم إلغاء إكمال المهمة',
            'data' => $progress,
        ]);
    }

    /**
     * Get user's study progress
     * GET /api/bac-study/progress/user
     */
    public function getUserProgress(Request $request)
    {
        $user = $request->user();
        $streamId = $request->query('stream_id');

        $query = UserBacStudyProgress::with(['topic.daySubject.studyDay', 'topic.daySubject.subject'])
            ->byUser($user->id);

        if ($streamId) {
            $query->whereHas('topic.daySubject.studyDay', function ($q) use ($streamId) {
                $q->where('academic_stream_id', $streamId);
            });
        }

        $progress = $query->get()->map(function ($item) {
            return [
                'topic_id' => $item->bac_study_day_topic_id,
                'topic_ar' => $item->topic->topic_ar,
                'is_completed' => $item->is_completed,
                'completed_at' => $item->completed_at,
                'day_number' => $item->topic->daySubject->studyDay->day_number,
                'subject_name' => $item->topic->daySubject->subject->name_ar,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $progress,
        ]);
    }

    /**
     * Get user's study statistics
     * GET /api/bac-study/progress/stats
     */
    public function getStats(Request $request)
    {
        $user = $request->user();
        $streamId = $request->query('stream_id');

        // Get total topics count
        $totalTopicsQuery = BacStudyDayTopic::query();
        if ($streamId) {
            $totalTopicsQuery->whereHas('daySubject.studyDay', function ($q) use ($streamId) {
                $q->where('academic_stream_id', $streamId);
            });
        }
        $totalTopics = $totalTopicsQuery->count();

        // Get completed topics count
        $completedQuery = UserBacStudyProgress::byUser($user->id)->completed();
        if ($streamId) {
            $completedQuery->whereHas('topic.daySubject.studyDay', function ($q) use ($streamId) {
                $q->where('academic_stream_id', $streamId);
            });
        }
        $completedTopics = $completedQuery->count();

        // Get total days count
        $totalDaysQuery = BacStudyDay::query();
        if ($streamId) {
            $totalDaysQuery->byStream($streamId);
        }
        $totalDays = $totalDaysQuery->count();

        // Get completed days (days where all topics are completed)
        $completedDays = 0;
        if ($streamId) {
            $days = BacStudyDay::byStream($streamId)->with('daySubjects.topics')->get();
            foreach ($days as $day) {
                $dayTopics = $day->daySubjects->flatMap->topics;
                $dayTopicIds = $dayTopics->pluck('id');

                if ($dayTopicIds->isEmpty()) continue;

                $completedDayTopics = UserBacStudyProgress::byUser($user->id)
                    ->completed()
                    ->whereIn('bac_study_day_topic_id', $dayTopicIds)
                    ->count();

                if ($completedDayTopics >= $dayTopicIds->count()) {
                    $completedDays++;
                }
            }
        }

        // Calculate progress percentage
        $progressPercentage = $totalTopics > 0
            ? round(($completedTopics / $totalTopics) * 100, 2)
            : 0;

        // Find current day (first day with incomplete topics)
        $currentDay = 1;
        if ($streamId) {
            $days = BacStudyDay::byStream($streamId)
                ->with('daySubjects.topics')
                ->orderBy('day_number')
                ->get();

            foreach ($days as $day) {
                $dayTopics = $day->daySubjects->flatMap->topics;
                $dayTopicIds = $dayTopics->pluck('id');

                if ($dayTopicIds->isEmpty()) {
                    $currentDay = $day->day_number + 1;
                    continue;
                }

                $completedDayTopics = UserBacStudyProgress::byUser($user->id)
                    ->completed()
                    ->whereIn('bac_study_day_topic_id', $dayTopicIds)
                    ->count();

                if ($completedDayTopics < $dayTopicIds->count()) {
                    $currentDay = $day->day_number;
                    break;
                }
                $currentDay = $day->day_number + 1;
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_days' => $totalDays,
                'completed_days' => $completedDays,
                'total_topics' => $totalTopics,
                'completed_topics' => $completedTopics,
                'progress_percentage' => $progressPercentage,
                'current_day' => min($currentDay, $totalDays),
            ],
        ]);
    }

    /**
     * Get day with user progress
     * GET /api/bac-study/day-with-progress/{stream_id}/{day_number}
     */
    public function getDayWithProgress(Request $request, $streamId, $dayNumber)
    {
        $user = $request->user();

        $day = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics'])
            ->byStream($streamId)
            ->where('day_number', $dayNumber)
            ->first();

        if (!$day) {
            return response()->json([
                'success' => false,
                'message' => 'اليوم غير موجود',
            ], 404);
        }

        // Get user progress for this day's topics
        $topicIds = $day->daySubjects->flatMap->topics->pluck('id');
        $userProgress = UserBacStudyProgress::byUser($user->id)
            ->whereIn('bac_study_day_topic_id', $topicIds)
            ->pluck('is_completed', 'bac_study_day_topic_id');

        $response = $this->formatDayResponse($day, $userProgress);

        return response()->json([
            'success' => true,
            'data' => $response,
        ]);
    }

    /**
     * Format day response
     */
    private function formatDayResponse($day, $userProgress = null)
    {
        return [
            'id' => $day->id,
            'day_number' => $day->day_number,
            'day_type' => $day->day_type,
            'title_ar' => $day->title_ar,
            'week_number' => $day->week_number,
            'subjects' => $day->daySubjects->filter(function ($daySubject) {
                return $daySubject->subject !== null;
            })->map(function ($daySubject) use ($userProgress) {
                return [
                    'id' => $daySubject->id,
                    'subject' => [
                        'id' => $daySubject->subject->id,
                        'name_ar' => $daySubject->subject->name_ar,
                        'color' => $daySubject->subject->color ?? '#6366F1',
                        'icon' => $daySubject->subject->icon ?? 'book',
                    ],
                    'order' => $daySubject->order,
                    'topics' => $daySubject->topics->map(function ($topic) use ($userProgress) {
                        return [
                            'id' => $topic->id,
                            'topic_ar' => $topic->topic_ar,
                            'description_ar' => $topic->description_ar,
                            'task_type' => $topic->task_type,
                            'order' => $topic->order,
                            'is_completed' => $userProgress
                                ? ($userProgress[$topic->id] ?? false)
                                : false,
                        ];
                    }),
                ];
            })->values(),
        ];
    }
}
