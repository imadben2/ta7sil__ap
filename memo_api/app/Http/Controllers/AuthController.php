<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\DeviceTransferRequest;
use App\Models\DeviceSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AuthController extends Controller
{
    /**
     * Register a new user with device binding.
     *
     * POST /api/auth/register
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
            'device_uuid' => 'required|string',
            'device_name' => 'required|string',
            'device_model' => 'required|string',
            'device_os' => 'required|string',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'role' => 'student',
            'device_uuid' => $validated['device_uuid'],
            'device_name' => $validated['device_name'],
            'device_model' => $validated['device_model'],
            'device_os' => $validated['device_os'],
            'is_active' => true,
            'login_count' => 0,
        ]);

        $tokenResult = $user->createToken('auth-token');
        $token = $tokenResult->plainTextToken;

        // Create device session record
        $deviceSession = DeviceSession::create([
            'user_id' => $user->id,
            'device_name' => $validated['device_name'],
            'device_type' => $this->detectDeviceType($validated['device_os']),
            'device_os' => $validated['device_os'],
            'token_id' => (string) $tokenResult->accessToken->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'is_current' => true,
            'last_active_at' => now(),
            'expires_at' => now()->addDays(7),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data' => [
                'user' => $user,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => now()->addDays(7)->toISOString(),
            ],
        ], 201);
    }

    /**
     * Login user with device verification.
     *
     * POST /api/auth/login
     */
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_id' => 'required|string',
            'device_name' => 'required|string',
            'device_model' => 'required|string',
            'device_os' => 'required|string',
        ]);

        // Use device_id as device_uuid for compatibility
        $validated['device_uuid'] = $validated['device_id'];

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Check if user is banned (only if column exists)
        if (Schema::hasColumn('users', 'is_banned') && $user->is_banned) {
            return response()->json([
                'success' => false,
                'message' => 'Your account has been banned.',
                'reason' => $user->banned_reason ?? 'No reason provided',
            ], 403);
        }

        // Check if user is active (only if column exists)
        if (Schema::hasColumn('users', 'is_active') && !$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is inactive. Please contact support.',
            ], 403);
        }

        // Device binding check (only if device columns exist)
        // SKIP device verification for student2@memo.com (development/testing account)
        if (Schema::hasColumn('users', 'device_uuid') && $validated['email'] !== 'student2@memo.com') {
            if ($user->hasDeviceBound()) {
                if (!$user->isDeviceValid($validated['device_uuid'])) {
                    return response()->json([
                        'success' => false,
                        'message' => 'This account is bound to another device. Please request a device transfer.',
                        'error_code' => 'DEVICE_MISMATCH',
                        'bound_device' => [
                            'name' => $user->device_name,
                            'model' => $user->device_model,
                            'os' => $user->device_os,
                        ],
                    ], 403);
                }
            } else {
                // First login - bind device
                $user->bindDevice(
                    $validated['device_uuid'],
                    $validated['device_name'],
                    $validated['device_model'],
                    $validated['device_os']
                );
            }
        }

        // Record login (only if method exists)
        if (method_exists($user, 'recordLogin')) {
            $user->recordLogin();
        }

        // Create token
        $tokenResult = $user->createToken('auth-token');
        $token = $tokenResult->plainTextToken;

        // Create device session record
        $deviceSession = DeviceSession::create([
            'user_id' => $user->id,
            'device_name' => $validated['device_name'],
            'device_type' => $this->detectDeviceType($validated['device_os']),
            'device_os' => $validated['device_os'],
            'os_version' => $request->input('os_version'),
            'app_version' => $request->input('app_version'),
            'token_id' => (string) $tokenResult->accessToken->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'is_current' => true,
            'last_active_at' => now(),
            'expires_at' => now()->addDays(7),
        ]);

        // Mark this session as current (unmark others)
        $deviceSession->markAsCurrent();

        // Refresh user and load academic profile
        $user = $user->fresh()->load('academicProfile');

        // Flatten academic profile data for Flutter compatibility
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'success' => true,
            'message' => 'Logged in successfully',
            'data' => [
                'user' => $userData,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => now()->addDays(7)->toISOString(),
            ],
        ]);
    }

    /**
     * Detect device type from OS string.
     */
    private function detectDeviceType(string $deviceOs): string
    {
        $os = strtolower($deviceOs);

        if (str_contains($os, 'android') || str_contains($os, 'ios')) {
            return 'mobile';
        }

        if (str_contains($os, 'ipad') || str_contains($os, 'tablet')) {
            return 'tablet';
        }

        return 'web';
    }

    /**
     * Logout user (revoke current token).
     *
     * POST /api/auth/logout
     */
    public function logout(Request $request)
    {
        $token = $request->user()->currentAccessToken();

        // Delete associated device session
        DeviceSession::where('user_id', $request->user()->id)
            ->where('token_id', (string) $token->id)
            ->delete();

        // Revoke token
        $token->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Logout from all devices (revoke all tokens).
     *
     * POST /api/auth/logout-all
     */
    public function logoutAll(Request $request)
    {
        $user = $request->user();

        // Delete all device sessions for this user
        DeviceSession::where('user_id', $user->id)->delete();

        // Revoke all tokens
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out from all devices successfully',
        ]);
    }

    /**
     * Get authenticated user data.
     *
     * GET /api/auth/me
     */
    public function me(Request $request)
    {
        $user = $request->user()->load([
            'userProfile',
            'academicProfile.academicYear',
            'academicProfile.academicStream',
            'subjects',
        ]);

        // Flatten academic profile data for Flutter compatibility
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'success' => true,
            'data' => $userData,
        ]);
    }

    /**
     * Validate current token and return user data.
     *
     * GET /api/auth/validate-token
     */
    public function validateToken(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired token',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Token is valid',
            'data' => [
                'user' => $user->load([
                    'userProfile',
                    'academicProfile.academicYear',
                    'academicProfile.academicStream',
                    'subjects',
                ]),
                'token_type' => 'Bearer',
            ],
        ]);
    }

    /**
     * Refresh token (revoke current and create new).
     *
     * POST /api/auth/refresh
     */
    public function refresh(Request $request)
    {
        $user = $request->user();
        $request->user()->currentAccessToken()->delete();
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Token refreshed successfully',
            'data' => [
                'token' => $token,
            ],
        ]);
    }

    /**
     * Request device transfer.
     *
     * POST /api/auth/device-transfer/request
     */
    public function requestDeviceTransfer(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'new_device_uuid' => 'required|string',
            'new_device_name' => 'required|string',
            'new_device_model' => 'required|string',
            'new_device_os' => 'required|string',
            'reason' => 'nullable|string|max:500',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Check if there's already a pending request
        $existingRequest = DeviceTransferRequest::where('user_id', $user->id)
            ->where('status', 'pending')
            ->first();

        if ($existingRequest) {
            return response()->json([
                'success' => false,
                'message' => 'You already have a pending device transfer request.',
                'data' => $existingRequest,
            ], 400);
        }

        $transferRequest = DeviceTransferRequest::create([
            'user_id' => $user->id,
            'old_device_uuid' => $user->device_uuid,
            'old_device_name' => $user->device_name,
            'old_device_model' => $user->device_model,
            'old_device_os' => $user->device_os,
            'new_device_uuid' => $validated['new_device_uuid'],
            'new_device_name' => $validated['new_device_name'],
            'new_device_model' => $validated['new_device_model'],
            'new_device_os' => $validated['new_device_os'],
            'reason' => $validated['reason'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Device transfer request submitted successfully. An admin will review it soon.',
            'data' => $transferRequest,
        ], 201);
    }

    /**
     * Approve device transfer (admin only).
     *
     * POST /api/auth/device-transfer/approve/{id}
     */
    public function approveDeviceTransfer(Request $request, $id)
    {
        // Check if user is admin
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin access required.',
            ], 403);
        }

        $transferRequest = DeviceTransferRequest::findOrFail($id);

        if ($transferRequest->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'This request has already been processed.',
            ], 400);
        }

        DB::transaction(function () use ($transferRequest) {
            $user = $transferRequest->user;

            // Update user's device info
            $user->bindDevice(
                $transferRequest->new_device_uuid,
                $transferRequest->new_device_name,
                $transferRequest->new_device_model,
                $transferRequest->new_device_os
            );

            // Revoke all existing tokens
            $user->tokens()->delete();

            // Update transfer request status
            $transferRequest->update([
                'status' => 'approved',
                'approved_by' => auth()->id(),
                'approved_at' => now(),
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Device transfer approved successfully.',
            'data' => $transferRequest->fresh(),
        ]);
    }

    /**
     * Reject device transfer (admin only).
     *
     * POST /api/auth/device-transfer/reject/{id}
     */
    public function rejectDeviceTransfer(Request $request, $id)
    {
        // Check if user is admin
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin access required.',
            ], 403);
        }

        $validated = $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        $transferRequest = DeviceTransferRequest::findOrFail($id);

        if ($transferRequest->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'This request has already been processed.',
            ], 400);
        }

        $transferRequest->update([
            'status' => 'rejected',
            'approved_by' => auth()->id(),
            'approved_at' => now(),
            'rejection_reason' => $validated['rejection_reason'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Device transfer request rejected.',
            'data' => $transferRequest->fresh(),
        ]);
    }

    /**
     * Get user's device transfer requests.
     *
     * GET /api/auth/device-transfer/my-requests
     */
    public function myDeviceTransferRequests(Request $request)
    {
        $requests = $request->user()
            ->deviceTransferRequests()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $requests,
        ]);
    }

    /**
     * Get all pending device transfer requests (admin only).
     *
     * GET /api/auth/device-transfer/pending
     */
    public function pendingDeviceTransferRequests(Request $request)
    {
        // Check if user is admin
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin access required.',
            ], 403);
        }

        $requests = DeviceTransferRequest::with('user')
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $requests,
        ]);
    }
}
