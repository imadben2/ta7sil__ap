<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AcademicStream;
use App\Models\BacStudyDay;
use App\Models\BacStudyDaySubject;
use App\Models\BacStudyDayTopic;
use App\Models\BacWeeklyReward;
use App\Models\Subject;
use App\Models\UserBacStudyProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminBacStudyScheduleController extends Controller
{
    /**
     * Display BAC Study Schedule overview
     */
    public function index(Request $request)
    {
        $streamId = $request->get('stream_id');

        // Get all BAC streams (3ème année secondaire)
        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        // Get statistics
        $stats = [
            'total_days' => BacStudyDay::when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))->count(),
            'total_topics' => BacStudyDayTopic::when($streamId, function($q) use ($streamId) {
                $q->whereHas('daySubject.studyDay', fn($sq) => $sq->where('academic_stream_id', $streamId));
            })->count(),
            'total_rewards' => BacWeeklyReward::when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))->count(),
            'users_with_progress' => UserBacStudyProgress::distinct('user_id')->count(),
            'completed_topics' => UserBacStudyProgress::where('is_completed', true)->count(),
        ];

        // Get days with empty subjects (placeholders)
        $emptyDays = BacStudyDay::when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))
            ->whereDoesntHave('daySubjects')
            ->pluck('day_number')
            ->toArray();

        // Get recent progress
        $recentProgress = UserBacStudyProgress::with(['user', 'topic.daySubject.studyDay', 'topic.daySubject.subject'])
            ->where('is_completed', true)
            ->orderBy('completed_at', 'desc')
            ->limit(10)
            ->get();

        return view('admin.bac-study-schedule.index', compact(
            'streams', 'stats', 'emptyDays', 'recentProgress', 'streamId'
        ));
    }

    /**
     * Display all days for a stream
     */
    public function days(Request $request)
    {
        $streamId = $request->get('stream_id');
        $weekNumber = $request->get('week');

        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        $query = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics'])
            ->when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))
            ->orderBy('day_number');

        if ($weekNumber) {
            $startDay = (($weekNumber - 1) * 7) + 1;
            $endDay = $weekNumber * 7;
            $query->whereBetween('day_number', [$startDay, $endDay]);
        }

        $days = $query->paginate(14);

        // Calculate weeks for filter
        $totalDays = BacStudyDay::when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))->max('day_number') ?? 98;
        $weeks = range(1, ceil($totalDays / 7));

        return view('admin.bac-study-schedule.days', compact('days', 'streams', 'streamId', 'weeks', 'weekNumber'));
    }

    /**
     * Show a specific day
     */
    public function showDay($id)
    {
        $day = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics', 'academicStream'])
            ->findOrFail($id);

        // Get available subjects for this stream (using forStream scope for JSON array)
        $subjects = Subject::forStream($day->academic_stream_id)->get();

        return view('admin.bac-study-schedule.show-day', compact('day', 'subjects'));
    }

    /**
     * Edit a specific day
     */
    public function editDay($id)
    {
        $day = BacStudyDay::with(['daySubjects.subject', 'daySubjects.topics', 'academicStream'])
            ->findOrFail($id);

        // Get available subjects for this stream (using forStream scope for JSON array)
        $subjects = Subject::forStream($day->academic_stream_id)->get();

        return view('admin.bac-study-schedule.edit-day', compact('day', 'subjects'));
    }

    /**
     * Update a specific day
     */
    public function updateDay(Request $request, $id)
    {
        $request->validate([
            'day_type' => 'required|in:study,review,reward',
            'title_ar' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $day = BacStudyDay::findOrFail($id);
        $day->update($request->only(['day_type', 'title_ar', 'is_active']));

        return redirect()->route('admin.bac-study-schedule.days.show', $id)
            ->with('success', 'تم تحديث اليوم بنجاح');
    }

    /**
     * Add subject to day
     */
    public function addSubjectToDay(Request $request, $dayId)
    {
        $request->validate([
            'subject_id' => 'required|exists:subjects,id',
        ]);

        $day = BacStudyDay::findOrFail($dayId);

        // Check if subject already exists for this day
        $exists = BacStudyDaySubject::where('bac_study_day_id', $dayId)
            ->where('subject_id', $request->subject_id)
            ->exists();

        if ($exists) {
            return back()->with('error', 'المادة موجودة مسبقاً في هذا اليوم');
        }

        // Get max order
        $maxOrder = BacStudyDaySubject::where('bac_study_day_id', $dayId)->max('order') ?? 0;

        BacStudyDaySubject::create([
            'bac_study_day_id' => $dayId,
            'subject_id' => $request->subject_id,
            'order' => $maxOrder + 1,
        ]);

        return back()->with('success', 'تمت إضافة المادة بنجاح');
    }

    /**
     * Remove subject from day
     */
    public function removeSubjectFromDay($dayId, $subjectId)
    {
        BacStudyDaySubject::where('bac_study_day_id', $dayId)
            ->where('id', $subjectId)
            ->delete();

        return back()->with('success', 'تم حذف المادة بنجاح');
    }

    /**
     * Add topic to day subject
     */
    public function addTopic(Request $request, $daySubjectId)
    {
        $request->validate([
            'topic_ar' => 'required|string|max:500',
            'description_ar' => 'nullable|string',
            'task_type' => 'required|in:study,memorize,solve,review,exercise',
        ]);

        $daySubject = BacStudyDaySubject::findOrFail($daySubjectId);

        // Get max order
        $maxOrder = BacStudyDayTopic::where('bac_study_day_subject_id', $daySubjectId)->max('order') ?? 0;

        BacStudyDayTopic::create([
            'bac_study_day_subject_id' => $daySubjectId,
            'topic_ar' => $request->topic_ar,
            'description_ar' => $request->description_ar,
            'task_type' => $request->task_type,
            'order' => $maxOrder + 1,
        ]);

        return back()->with('success', 'تمت إضافة الدرس بنجاح');
    }

    /**
     * Update topic
     */
    public function updateTopic(Request $request, $topicId)
    {
        $request->validate([
            'topic_ar' => 'required|string|max:500',
            'description_ar' => 'nullable|string',
            'task_type' => 'required|in:study,memorize,solve,review,exercise',
        ]);

        $topic = BacStudyDayTopic::findOrFail($topicId);
        $topic->update($request->only(['topic_ar', 'description_ar', 'task_type']));

        return back()->with('success', 'تم تحديث الدرس بنجاح');
    }

    /**
     * Delete topic
     */
    public function deleteTopic($topicId)
    {
        BacStudyDayTopic::findOrFail($topicId)->delete();

        return back()->with('success', 'تم حذف الدرس بنجاح');
    }

    /**
     * Display weekly rewards
     */
    public function rewards(Request $request)
    {
        $streamId = $request->get('stream_id');

        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        $rewards = BacWeeklyReward::with('academicStream')
            ->when($streamId, fn($q) => $q->where('academic_stream_id', $streamId))
            ->orderBy('week_number')
            ->paginate(14);

        return view('admin.bac-study-schedule.rewards', compact('rewards', 'streams', 'streamId'));
    }

    /**
     * Create reward form
     */
    public function createReward()
    {
        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        return view('admin.bac-study-schedule.create-reward', compact('streams'));
    }

    /**
     * Store reward
     */
    public function storeReward(Request $request)
    {
        $request->validate([
            'academic_stream_id' => 'required|exists:academic_streams,id',
            'week_number' => 'required|integer|min:1|max:14',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'movie_title' => 'nullable|string|max:255',
            'movie_image' => 'nullable|string|max:500',
        ]);

        // Check if reward exists for this week
        $exists = BacWeeklyReward::where('academic_stream_id', $request->academic_stream_id)
            ->where('week_number', $request->week_number)
            ->exists();

        if ($exists) {
            return back()->with('error', 'مكافأة هذا الأسبوع موجودة مسبقاً');
        }

        BacWeeklyReward::create($request->all());

        return redirect()->route('admin.bac-study-schedule.rewards')
            ->with('success', 'تمت إضافة المكافأة بنجاح');
    }

    /**
     * Edit reward
     */
    public function editReward($id)
    {
        $reward = BacWeeklyReward::findOrFail($id);

        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        return view('admin.bac-study-schedule.edit-reward', compact('reward', 'streams'));
    }

    /**
     * Update reward
     */
    public function updateReward(Request $request, $id)
    {
        $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'movie_title' => 'nullable|string|max:255',
            'movie_image' => 'nullable|string|max:500',
        ]);

        $reward = BacWeeklyReward::findOrFail($id);
        $reward->update($request->only(['title_ar', 'description_ar', 'movie_title', 'movie_image']));

        return redirect()->route('admin.bac-study-schedule.rewards')
            ->with('success', 'تم تحديث المكافأة بنجاح');
    }

    /**
     * Delete reward
     */
    public function deleteReward($id)
    {
        BacWeeklyReward::findOrFail($id)->delete();

        return back()->with('success', 'تم حذف المكافأة بنجاح');
    }

    /**
     * Display user progress statistics
     */
    public function progress(Request $request)
    {
        $streamId = $request->get('stream_id');

        $streams = AcademicStream::whereHas('academicYear', function ($query) {
            $query->where('slug', 'like', '%3as%')->orWhere('name_ar', 'like', '%ثالثة ثانوي%');
        })->get();

        // Get users with progress
        $usersProgress = DB::table('user_bac_study_progress')
            ->join('users', 'users.id', '=', 'user_bac_study_progress.user_id')
            ->join('bac_study_day_topics', 'bac_study_day_topics.id', '=', 'user_bac_study_progress.bac_study_day_topic_id')
            ->join('bac_study_day_subjects', 'bac_study_day_subjects.id', '=', 'bac_study_day_topics.bac_study_day_subject_id')
            ->join('bac_study_days', 'bac_study_days.id', '=', 'bac_study_day_subjects.bac_study_day_id')
            ->when($streamId, fn($q) => $q->where('bac_study_days.academic_stream_id', $streamId))
            ->select(
                'users.id',
                'users.name',
                'users.email',
                DB::raw('COUNT(CASE WHEN user_bac_study_progress.is_completed = 1 THEN 1 END) as completed_count'),
                DB::raw('COUNT(*) as total_count'),
                DB::raw('MAX(user_bac_study_progress.completed_at) as last_activity')
            )
            ->groupBy('users.id', 'users.name', 'users.email')
            ->orderByDesc('completed_count')
            ->paginate(20);

        // Get total topics for percentage calculation
        $totalTopics = BacStudyDayTopic::when($streamId, function($q) use ($streamId) {
            $q->whereHas('daySubject.studyDay', fn($sq) => $sq->where('academic_stream_id', $streamId));
        })->count();

        return view('admin.bac-study-schedule.progress', compact('usersProgress', 'streams', 'streamId', 'totalTopics'));
    }
}
