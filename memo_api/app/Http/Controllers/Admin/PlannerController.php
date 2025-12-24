<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\StudySchedule;
use App\Models\StudySession;
use App\Models\SubjectPriority;
use App\Models\ExamSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlannerController extends Controller
{
    /**
     * Display planner overview dashboard
     */
    public function index()
    {
        $stats = [
            'total_users_with_schedules' => User::whereHas('studySchedules')->count(),
            'active_schedules' => StudySchedule::where('status', 'active')->count(),
            'total_sessions_today' => StudySession::whereDate('scheduled_date', today())->count(),
            'completed_sessions_today' => StudySession::whereDate('scheduled_date', today())
                ->where('status', 'completed')
                ->count(),
            'in_progress_sessions' => StudySession::where('status', 'in_progress')->count(),
            'missed_sessions_today' => StudySession::whereDate('scheduled_date', today())
                ->where('status', 'missed')
                ->count(),
        ];

        // Get recent schedules
        $recentSchedules = StudySchedule::with('user')
            ->latest()
            ->take(10)
            ->get();

        // Get active sessions
        $activeSessions = StudySession::with(['user', 'subject'])
            ->where('status', 'in_progress')
            ->latest()
            ->take(10)
            ->get();

        // Get top priority subjects across all users
        $topPriorities = SubjectPriority::with(['user', 'subject'])
            ->orderBy('total_priority_score', 'desc')
            ->take(10)
            ->get();

        return view('admin.planner.index', compact('stats', 'recentSchedules', 'activeSessions', 'topPriorities'));
    }

    /**
     * Display all schedules
     */
    public function schedules(Request $request)
    {
        $query = StudySchedule::with(['user', 'studySessions']);

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Filter by user
        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Search
        if ($request->filled('search')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('email', 'like', '%' . $request->search . '%');
            });
        }

        $schedules = $query->latest()->paginate(20);

        $users = User::whereHas('studySchedules')->get();

        return view('admin.planner.schedules', compact('schedules', 'users'));
    }

    /**
     * Display schedule details
     */
    public function showSchedule($id)
    {
        $schedule = StudySchedule::with(['user', 'studySessions.subject', 'studySessions.activities'])
            ->findOrFail($id);

        // Calculate statistics
        $stats = [
            'total_sessions' => $schedule->studySessions->count(),
            'completed' => $schedule->studySessions->where('status', 'completed')->count(),
            'missed' => $schedule->studySessions->where('status', 'missed')->count(),
            'scheduled' => $schedule->studySessions->where('status', 'scheduled')->count(),
            'in_progress' => $schedule->studySessions->where('status', 'in_progress')->count(),
        ];

        return view('admin.planner.show-schedule', compact('schedule', 'stats'));
    }

    /**
     * Display all sessions
     */
    public function sessions(Request $request)
    {
        $query = StudySession::with(['user', 'subject', 'studySchedule']);

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Filter by date
        if ($request->filled('date')) {
            $query->whereDate('scheduled_date', $request->date);
        }

        // Filter by user
        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Search
        if ($request->filled('search')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%');
            });
        }

        $sessions = $query->latest('scheduled_date')->paginate(20);

        $users = User::whereHas('studySessions')->get();

        return view('admin.planner.sessions', compact('sessions', 'users'));
    }

    /**
     * Display session details
     */
    public function showSession($id)
    {
        $session = StudySession::with([
            'user',
            'subject',
            'studySchedule',
            'activities',
            'suggestedContent'
        ])->findOrFail($id);

        return view('admin.planner.show-session', compact('session'));
    }

    /**
     * Display priorities overview
     */
    public function priorities(Request $request)
    {
        $query = SubjectPriority::with(['user', 'subject']);

        // Filter by user
        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Search
        if ($request->filled('search')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%');
            })->orWhereHas('subject', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%');
            });
        }

        $priorities = $query->orderBy('total_priority_score', 'desc')->paginate(20);

        $users = User::whereHas('subjectPriorities')->get();

        return view('admin.planner.priorities', compact('priorities', 'users'));
    }

    /**
     * Display analytics
     */
    public function analytics(Request $request)
    {
        $startDate = $request->input('start_date', now()->subDays(30)->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->format('Y-m-d'));

        // Sessions over time
        $sessionsOverTime = StudySession::selectRaw('scheduled_date as date, COUNT(*) as count, status')
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->groupBy('date', 'status')
            ->orderBy('date')
            ->get()
            ->groupBy('date');

        // Completion rates by user
        $userCompletionRates = DB::table('study_sessions')
            ->join('users', 'study_sessions.user_id', '=', 'users.id')
            ->selectRaw('users.id, users.name,
                COUNT(*) as total,
                SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) as completed,
                CAST(AVG(CASE WHEN status = "completed" AND actual_duration_minutes IS NOT NULL THEN 100 ELSE 0 END) AS SIGNED) as avg_completion')
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->groupBy('users.id', 'users.name')
            ->get();

        // Sessions by time of day (simplified - group by hour from scheduled_start_time)
        $focusScoresByTime = StudySession::selectRaw('
                CAST(substr(scheduled_start_time, 1, 2) AS SIGNED) as hour,
                COUNT(*) as session_count
            ')
            ->where('status', 'completed')
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->groupBy('hour')
            ->orderBy('hour')
            ->get();

        return view('admin.planner.analytics', compact(
            'sessionsOverTime',
            'userCompletionRates',
            'focusScoresByTime',
            'startDate',
            'endDate'
        ));
    }
}
