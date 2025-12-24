<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserActivityLog;
use App\Services\UserService;
use App\Services\StatisticsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Yajra\DataTables\Facades\DataTables;

class UserController extends Controller
{
    protected $userService;
    protected $statisticsService;

    public function __construct(UserService $userService, StatisticsService $statisticsService)
    {
        $this->userService = $userService;
        $this->statisticsService = $statisticsService;
    }

    /**
     * Display list of users with filters.
     *
     * GET /admin/users
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            $response = $this->getDataTable($request);
            // Ensure UTF-8 encoding
            $response->headers->set('Content-Type', 'application/json; charset=UTF-8');
            return $response;
        }

        // For web view
        return view('admin.users.index');
    }

    /**
     * Get users data for DataTables.
     */
    private function getDataTable(Request $request)
    {
        $query = User::with(['academicProfile.academicYear.academicPhase', 'academicProfile.academicStream']);

        // Filter by academic phase
        if ($request->filled('phase_id')) {
            $query->whereHas('academicProfile.academicYear', function($q) use ($request) {
                $q->where('academic_phase_id', $request->phase_id);
            });
        }

        // Filter by academic year
        if ($request->filled('year_id')) {
            $query->whereHas('academicProfile', function($q) use ($request) {
                $q->where('academic_year_id', $request->year_id);
            });
        }

        // Filter by status
        if ($request->filled('status_filter')) {
            if ($request->status_filter === 'active') {
                $query->where('is_active', true);
                // Check if banned_at column exists
                if (\Schema::hasColumn('users', 'banned_at')) {
                    $query->whereNull('banned_at');
                }
            } elseif ($request->status_filter === 'inactive') {
                $query->where('is_active', false);
            } elseif ($request->status_filter === 'banned') {
                // Check if banned_at column exists
                if (\Schema::hasColumn('users', 'banned_at')) {
                    $query->whereNotNull('banned_at');
                }
            }
        }

        return DataTables::of($query)
            ->filter(function ($query) use ($request) {
                if ($request->has('search') && $request->search['value']) {
                    $searchValue = $request->search['value'];
                    $query->where(function($q) use ($searchValue) {
                        $q->where('name', 'LIKE', "%{$searchValue}%")
                          ->orWhere('email', 'LIKE', "%{$searchValue}%");
                    });
                }
            })
            ->addColumn('user_info', function ($user) {
                $name = $user->name ?? 'N/A';
                $email = $user->email ?? 'N/A';
                $initial = mb_substr($name, 0, 1, 'UTF-8');

                $avatar = $user->profile_image
                    ? '<img src="' . asset('storage/' . $user->profile_image) . '" class="w-10 h-10 rounded-full object-cover">'
                    : '<div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold">' . mb_strtoupper($initial, 'UTF-8') . '</div>';

                return '<div class="flex items-center gap-3">' .
                       $avatar .
                       '<div>' .
                       '<div class="font-medium text-gray-900">' . htmlspecialchars($name, ENT_QUOTES, 'UTF-8') . '</div>' .
                       '<div class="text-sm text-gray-500">' . htmlspecialchars($email, ENT_QUOTES, 'UTF-8') . '</div>' .
                       '</div></div>';
            })
            ->addColumn('academic_info', function ($user) {
                if ($user->academicProfile && $user->academicProfile->academicYear) {
                    $phase = optional($user->academicProfile->academicYear->academicPhase)->name_ar ?? '-';
                    $year = $user->academicProfile->academicYear->name_ar ?? '-';
                    $stream = optional($user->academicProfile->academicStream)->name_ar ?? 'مشترك';

                    return '<div class="text-sm">' .
                           '<div class="font-medium">' . htmlspecialchars($phase, ENT_QUOTES, 'UTF-8') . '</div>' .
                           '<div class="text-gray-600">' . htmlspecialchars($year, ENT_QUOTES, 'UTF-8') . '</div>' .
                           '<div class="text-gray-500">' . htmlspecialchars($stream, ENT_QUOTES, 'UTF-8') . '</div>' .
                           '</div>';
                }
                return '<span class="text-gray-400">غير محدد</span>';
            })
            ->addColumn('status', function ($user) {
                // Check if banned_at column exists and has value
                $hasBannedColumn = \Schema::hasColumn('users', 'banned_at');
                $isBanned = $hasBannedColumn && isset($user->banned_at) && $user->banned_at !== null;

                if ($isBanned) {
                    return '<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">محظور</span>';
                }
                if ($user->is_active) {
                    return '<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">نشط</span>';
                }
                return '<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">غير نشط</span>';
            })
            ->addColumn('registered_at', function ($user) {
                return '<div class="text-sm">' .
                       '<div>' . $user->created_at->format('Y-m-d') . '</div>' .
                       '<div class="text-gray-500">' . $user->created_at->diffForHumans() . '</div>' .
                       '</div>';
            })
            ->addColumn('actions', function ($user) {
                return view('admin.users.partials.actions', compact('user'))->render();
            })
            ->rawColumns(['user_info', 'academic_info', 'status', 'registered_at', 'actions'])
            ->make(true);
    }

    /**
     * Show user details.
     *
     * GET /admin/users/{id}
     */
    public function show($id)
    {
        $user = User::with([
            'userProfile',
            'academicProfile.academicYear',
            'academicProfile.academicStream',
            'subjects',
            'stats',
            'userSubjects.subject',
        ])->findOrFail($id);

        // Get recent activity
        $recentActivity = $user->activityLogs()
            ->latest()
            ->limit(50)
            ->get();

        // Get study statistics
        $stats = $this->userService->calculateUserStats($user, 'all');

        // Get user subscriptions (placeholder)
        $subscriptions = [];

        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'data' => [
                    'user' => $user,
                    'stats' => $stats,
                    'recent_activity' => $recentActivity,
                    'subscriptions' => $subscriptions,
                ],
            ]);
        }

        return view('admin.users.show', compact('user', 'stats', 'recentActivity', 'subscriptions'));
    }

    /**
     * Show create user form.
     *
     * GET /admin/users/create
     */
    public function create()
    {
        $academicPhases = \App\Models\AcademicPhase::orderBy('order')->get();
        $academicYears = \App\Models\AcademicYear::with('academicPhase')->orderBy('order')->get();
        $streams = \App\Models\AcademicStream::orderBy('order')->get();

        return view('admin.users.create', compact('academicPhases', 'academicYears', 'streams'));
    }

    /**
     * Get academic years by phase (AJAX).
     *
     * GET /admin/users/ajax/years-by-phase/{phaseId}
     */
    public function getYearsByPhase($phaseId)
    {
        $years = \App\Models\AcademicYear::where('academic_phase_id', $phaseId)
            ->orderBy('order')
            ->get(['id', 'name_ar', 'name_fr', 'name_en']);

        return response()->json([
            'success' => true,
            'data' => $years,
        ]);
    }

    /**
     * Get academic streams by year (AJAX).
     *
     * GET /admin/users/ajax/streams-by-year/{yearId}
     */
    public function getStreamsByYear($yearId)
    {
        $year = \App\Models\AcademicYear::find($yearId);

        if (!$year) {
            return response()->json([
                'success' => false,
                'message' => 'Academic year not found',
            ], 404);
        }

        $streams = \App\Models\AcademicStream::where('academic_year_id', $yearId)
            ->orderBy('order')
            ->get(['id', 'name_ar', 'name_fr', 'name_en']);

        return response()->json([
            'success' => true,
            'data' => $streams,
            'requires_stream' => $streams->isNotEmpty(),
        ]);
    }

    /**
     * Store new user.
     *
     * POST /admin/users
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|min:3|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'nullable|string|min:8',
            'phone' => 'nullable|string',
            'role' => 'nullable|in:student,teacher,admin',
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'academic_stream_id' => 'nullable|exists:academic_streams,id',
            'is_active' => 'nullable|boolean',
            'send_welcome_email' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $validated = $validator->validated();

        // Generate random password if not provided
        if (empty($validated['password'])) {
            $validated['password'] = Str::random(12);
        }

        // Create user
        $user = $this->userService->createUser($validated);

        // Create academic profile
        \App\Models\UserAcademicProfile::create([
            'user_id' => $user->id,
            'academic_phase_id' => $validated['academic_phase_id'],
            'academic_year_id' => $validated['academic_year_id'],
            'academic_stream_id' => $validated['academic_stream_id'] ?? null,
        ]);

        // Send welcome email if requested
        if ($request->boolean('send_welcome_email')) {
            // TODO: Send welcome email with credentials
        }

        // Log activity
        UserActivityLog::log($user->id, 'account_created_by_admin', 'Account created by admin');

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'User created successfully',
                'data' => $user,
            ], 201);
        }

        return redirect()->route('admin.users.show', $user->id)
            ->with('success', 'User created successfully');
    }

    /**
     * Update user.
     *
     * PUT /admin/users/{id}
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|min:3|max:255',
            'email' => 'nullable|email|unique:users,email,' . $id,
            'phone' => 'nullable|string',
            'is_active' => 'nullable|boolean',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'academic_stream_id' => 'nullable|exists:academic_streams,id',
        ]);

        if ($validator->fails()) {
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors(),
                ], 422);
            }
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $validated = $validator->validated();

        // Update user
        $user->update(array_filter([
            'name' => $validated['name'] ?? $user->name,
            'email' => $validated['email'] ?? $user->email,
            'phone' => $validated['phone'] ?? $user->phone,
            'is_active' => $validated['is_active'] ?? $user->is_active,
        ]));

        // Update academic profile if provided
        if (isset($validated['academic_year_id'])) {
            \App\Models\UserAcademicProfile::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'academic_year_id' => $validated['academic_year_id'],
                    'academic_stream_id' => $validated['academic_stream_id'] ?? null,
                ]
            );
        }

        // Log activity
        UserActivityLog::log($user->id, 'profile_updated_by_admin', 'Profile updated by admin');

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'User updated successfully',
                'data' => $user->fresh(),
            ]);
        }

        return redirect()->back()->with('success', 'User updated successfully');
    }

    /**
     * Delete user (soft delete).
     *
     * DELETE /admin/users/{id}
     */
    public function destroy($id)
    {
        $user = User::findOrFail($id);

        // Prevent self-deletion
        if ($user->id === auth()->id()) {
            if (request()->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'You cannot delete your own account',
                ], 403);
            }
            return redirect()->back()->with('error', 'You cannot delete your own account');
        }

        // Revoke all tokens
        $user->tokens()->delete();

        // Soft delete
        $user->delete();

        // Log activity
        UserActivityLog::log($user->id, 'account_deleted_by_admin', 'Account deleted by admin');

        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully',
            ]);
        }

        return redirect()->route('admin.users.index')->with('success', 'User deleted successfully');
    }

    /**
     * Reset user password.
     *
     * POST /admin/users/{id}/reset-password
     */
    public function resetPassword(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $newPassword = Str::random(12);
        $user->update(['password' => Hash::make($newPassword)]);

        // Revoke all tokens
        $user->tokens()->delete();

        // Log activity
        UserActivityLog::log($user->id, UserActivityLog::TYPE_PASSWORD_CHANGE, 'Password reset by admin');

        // TODO: Send email with new password

        return response()->json([
            'success' => true,
            'message' => 'Password reset successfully',
            'new_password' => $newPassword, // In production, send via email instead
        ]);
    }

    /**
     * Revoke user's device binding.
     *
     * POST /admin/users/{id}/revoke-device
     */
    public function revokeDevice(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $user->update([
            'device_uuid' => null,
            'device_name' => null,
            'device_model' => null,
            'device_os' => null,
        ]);

        // Revoke all tokens
        $user->tokens()->delete();

        // Log activity
        UserActivityLog::log($user->id, 'device_revoked_by_admin', 'Device binding revoked by admin');

        return response()->json([
            'success' => true,
            'message' => 'Device binding revoked successfully',
        ]);
    }

    /**
     * Toggle user active status.
     *
     * POST /admin/users/{id}/toggle-status
     */
    public function toggleStatus($id)
    {
        $user = User::findOrFail($id);

        $newStatus = !$user->is_active;
        $user->update(['is_active' => $newStatus]);

        if (!$newStatus) {
            // If deactivating, revoke tokens
            $user->tokens()->delete();
        }

        // Log activity
        $action = $newStatus ? 'activated' : 'deactivated';
        UserActivityLog::log($user->id, "account_{$action}_by_admin", "Account {$action} by admin");

        return response()->json([
            'success' => true,
            'message' => 'User status updated successfully',
            'is_active' => $newStatus,
        ]);
    }

    /**
     * Get analytics/statistics for all users.
     *
     * GET /admin/users/analytics
     */
    public function analytics(Request $request)
    {
        // Total users
        $totalUsers = User::count();

        // New users this month
        $newThisMonth = User::where('created_at', '>=', now()->startOfMonth())->count();

        // Active users (last 7 days)
        $activeUsers = User::whereHas('activityLogs', function($q) {
            $q->where('created_at', '>=', now()->subDays(7));
        })->count();

        // Users by phase
        $usersByPhase = \DB::table('users')
            ->select('academic_years.academic_phase_id', \DB::raw('count(*) as count'))
            ->join('user_academic_profiles', 'users.id', '=', 'user_academic_profiles.user_id')
            ->join('academic_years', 'user_academic_profiles.academic_year_id', '=', 'academic_years.id')
            ->groupBy('academic_years.academic_phase_id')
            ->get();

        // Enhance with phase names
        $phases = \App\Models\AcademicPhase::pluck('name_ar', 'id');
        $usersByPhase = $usersByPhase->map(function($item) use ($phases) {
            return [
                'academic_phase_id' => $item->academic_phase_id,
                'count' => $item->count,
                'phase_name' => $phases[$item->academic_phase_id] ?? 'Unknown',
            ];
        });

        // Top users by study time
        $topUsers = User::select('users.*', 'user_stats.total_study_minutes')
            ->join('user_stats', 'users.id', '=', 'user_stats.user_id')
            ->orderBy('user_stats.total_study_minutes', 'desc')
            ->limit(10)
            ->get();

        // Inactive users (> 30 days)
        $inactiveUsers = User::whereHas('stats', function($q) {
            $q->where('last_study_date', '<', now()->subDays(30))
              ->orWhereNull('last_study_date');
        })->count();

        // Registration trend (last 30 days)
        $registrationTrend = User::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->where('created_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'data' => [
                    'overview' => [
                        'total_users' => $totalUsers,
                        'new_this_month' => $newThisMonth,
                        'active_users' => $activeUsers,
                        'inactive_users' => $inactiveUsers,
                    ],
                    'users_by_phase' => $usersByPhase,
                    'top_users' => $topUsers,
                    'registration_trend' => $registrationTrend,
                ],
            ]);
        }

        return view('admin.users.analytics', compact(
            'totalUsers',
            'newThisMonth',
            'activeUsers',
            'inactiveUsers',
            'usersByPhase',
            'topUsers',
            'registrationTrend'
        ));
    }

    /**
     * Export users to Excel/CSV.
     *
     * GET /admin/users/export
     */
    public function export(Request $request)
    {
        $users = User::with(['academicProfile.academicYear', 'academicProfile.academicStream', 'stats'])
            ->get();

        $data = $users->map(function($user) {
            return [
                'ID' => $user->id,
                'Name' => $user->name,
                'Email' => $user->email,
                'Phone' => $user->phone,
                'Academic Year' => $user->academicProfile?->academicYear?->name_ar,
                'Stream' => $user->academicProfile?->academicStream?->name_ar,
                'Total Study Hours' => round(($user->stats->total_study_minutes ?? 0) / 60, 1),
                'Current Streak' => $user->stats->current_streak_days ?? 0,
                'Level' => $user->stats->level ?? 1,
                'Points' => $user->stats->gamification_points ?? 0,
                'Is Active' => $user->is_active ? 'Yes' : 'No',
                'Registered At' => $user->created_at->format('Y-m-d H:i:s'),
            ];
        });

        // Return as JSON for now (in production, use Laravel Excel)
        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Bulk activate/deactivate users.
     *
     * POST /admin/users/bulk-action
     */
    public function bulkAction(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_ids' => 'required|array',
            'user_ids.*' => 'exists:users,id',
            'action' => 'required|in:activate,deactivate,delete',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userIds = $request->user_ids;
        $action = $request->action;

        // Prevent acting on self
        $userIds = array_diff($userIds, [auth()->id()]);

        $count = 0;

        switch ($action) {
            case 'activate':
                User::whereIn('id', $userIds)->update(['is_active' => true]);
                $count = count($userIds);
                break;

            case 'deactivate':
                User::whereIn('id', $userIds)->update(['is_active' => false]);
                // Revoke tokens
                \DB::table('personal_access_tokens')->whereIn('tokenable_id', $userIds)->delete();
                $count = count($userIds);
                break;

            case 'delete':
                User::whereIn('id', $userIds)->delete();
                $count = count($userIds);
                break;
        }

        return response()->json([
            'success' => true,
            'message' => "{$count} users {$action}d successfully",
        ]);
    }
}
