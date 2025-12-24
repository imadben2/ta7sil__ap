<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\GoogleAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Login user with device binding
     */
    public function login(Request $request): JsonResponse
    {
        // Debug logging
        \Log::info('=== Login Attempt ===');
        \Log::info('Email: ' . $request->input('email'));
        \Log::info('Password length: ' . strlen($request->input('password')));
        \Log::info('Device UUID: ' . $request->input('device_uuid'));
        \Log::info('All Input: ' . json_encode($request->all()));

        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
            'device_uuid' => 'required|string',
        ], [
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
            'password.required' => 'كلمة المرور مطلوبة',
            'password.min' => 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل',
            'device_uuid.required' => 'معرف الجهاز مطلوب',
        ]);

        $user = User::where('email', $request->email)->first();
        \Log::info('User found: ' . ($user ? 'YES (ID: ' . $user->id . ')' : 'NO'));

        if ($user) {
            $passwordCheck = Hash::check($request->password, $user->password);
            \Log::info('Password check result: ' . ($passwordCheck ? 'PASS' : 'FAIL'));
            \Log::info('Password hash from DB: ' . substr($user->password, 0, 20) . '...');
        }

        if (!$user || !Hash::check($request->password, $user->password)) {
            \Log::info('Login FAILED - throwing validation exception');
            throw ValidationException::withMessages([
                'email' => ['البريد الإلكتروني أو كلمة المرور غير صحيحة'],
            ]);
        }

        // Check device binding (bypass for student2@memo.com)
        $bypassDeviceCheck = in_array($user->email, ['student2@memo.com']);

        if (!$bypassDeviceCheck && $user->device_uuid && $user->device_uuid !== $request->device_uuid) {
            return response()->json([
                'message' => 'حسابك مرتبط بجهاز آخر. لتسجيل الدخول من هذا الجهاز، يجب طلب نقل الحساب.',
                'error' => 'device_mismatch'
            ], 403);
        }

        // Bind device if first login or if current user doesn't have a device bound
        if (!$user->device_uuid) {
            // Check if this device_uuid is already used by another user
            $existingUser = User::where('device_uuid', $request->device_uuid)
                ->where('id', '!=', $user->id)
                ->first();

            if ($existingUser) {
                \Log::warning('Device UUID already in use by another user', [
                    'device_uuid' => $request->device_uuid,
                    'current_user_id' => $user->id,
                    'existing_user_id' => $existingUser->id,
                ]);

                return response()->json([
                    'message' => 'هذا الجهاز مرتبط بحساب آخر. يرجى استخدام جهاز آخر أو التواصل مع الدعم الفني.',
                    'error' => 'device_already_bound'
                ], 403);
            }

            // Bind device to this user
            $user->bindDevice(
                $request->device_uuid,
                $request->device_name ?? 'Unknown Device',
                $request->device_model ?? 'Unknown Model',
                $request->device_os ?? 'Unknown OS'
            );

            \Log::info('Device bound successfully', [
                'user_id' => $user->id,
                'device_uuid' => $request->device_uuid,
            ]);
        }

        // Update last login timestamp
        $user->recordLogin();

        // Create token
        $token = $user->createToken('mobile_app')->plainTextToken;

        // Load academic profile and flatten it for Flutter
        $user->load('academicProfile');
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
        ], 200);
    }

    /**
     * Register new user
     */
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|min:3|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|regex:/^(05|06|07)[0-9]{8}$/',
            'device_uuid' => 'required|string',
            'device_name' => 'nullable|string',
            'device_model' => 'nullable|string',
            'device_os' => 'nullable|string',
            'academic_phase_id' => 'nullable|integer',
            'academic_year_id' => 'nullable|integer',
            'stream_id' => 'nullable|integer',
        ], [
            'name.required' => 'الاسم مطلوب',
            'name.min' => 'الاسم يجب أن يحتوي على 3 أحرف على الأقل',
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
            'email.unique' => 'هذا البريد الإلكتروني مستخدم بالفعل',
            'password.required' => 'كلمة المرور مطلوبة',
            'password.min' => 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل',
            'password.confirmed' => 'كلمات المرور غير متطابقة',
            'phone.regex' => 'رقم الهاتف غير صحيح',
            'device_uuid.required' => 'معرف الجهاز مطلوب',
        ]);

        // Check if this device_uuid is already used by another user
        $existingUser = User::where('device_uuid', $request->device_uuid)->first();
        if ($existingUser) {
            return response()->json([
                'message' => 'هذا الجهاز مرتبط بحساب آخر. يرجى استخدام جهاز آخر أو التواصل مع الدعم الفني.',
                'error' => 'device_already_bound'
            ], 403);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'device_uuid' => $request->device_uuid,
            'device_name' => $request->device_name ?? 'Unknown Device',
            'device_model' => $request->device_model ?? 'Unknown Model',
            'device_os' => $request->device_os ?? 'Unknown OS',
            'academic_phase_id' => $request->academic_phase_id,
            'academic_year_id' => $request->academic_year_id,
            'stream_id' => $request->stream_id,
        ]);

        // Create token
        $token = $user->createToken('mobile_app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Account created successfully',
            'data' => [
                'user' => $user,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => now()->addDays(7)->toISOString(),
            ],
        ], 201);
    }

    /**
     * Logout user
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج بنجاح'
        ], 200);
    }

    /**
     * Validate token
     */
    public function validateToken(Request $request): JsonResponse
    {
        $user = $request->user();

        // Check if device_uuid matches
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->header('X-Device-ID');
        if ($user->device_uuid && $user->device_uuid !== $deviceUuid) {
            return response()->json([
                'message' => 'حسابك مستخدم على جهاز آخر',
                'error' => 'device_mismatch'
            ], 403);
        }

        // Load academic profile and flatten it for Flutter
        $user->load('academicProfile');
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'user' => $userData,
            'valid' => true,
        ], 200);
    }

    /**
     * Refresh token
     */
    public function refreshToken(Request $request): JsonResponse
    {
        $user = $request->user();

        // Delete current token
        $request->user()->currentAccessToken()->delete();

        // Create new token
        $token = $user->createToken('mobile_app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
        ], 200);
    }

    /**
     * Request password reset (forgot password)
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
        ], [
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['البريد الإلكتروني غير موجود'],
            ]);
        }

        // Generate 6-digit code
        $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        // TODO: Store code in password_resets table
        // TODO: Send email with code

        return response()->json([
            'message' => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
            'code' => $code, // Remove in production
        ], 200);
    }

    /**
     * Logout from all devices
     */
    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج من جميع الأجهزة بنجاح'
        ], 200);
    }

    /**
     * Get current user
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        // Load academic profile and flatten it for Flutter
        $user->load('academicProfile');
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'success' => true,
            'data' => $userData,
        ], 200);
    }

    /**
     * Refresh token (alias for refreshToken)
     */
    public function refresh(Request $request): JsonResponse
    {
        return $this->refreshToken($request);
    }

    /**
     * Verify password reset code
     */
    public function verifyResetCode(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6',
        ]);

        // TODO: Verify code from password_resets table

        return response()->json([
            'message' => 'رمز التحقق صحيح',
            'valid' => true,
        ], 200);
    }

    /**
     * Reset password with code
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['البريد الإلكتروني غير موجود'],
            ]);
        }

        // TODO: Verify code from password_resets table

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        // Revoke all tokens
        $user->tokens()->delete();

        return response()->json([
            'message' => 'تم تغيير كلمة المرور بنجاح',
        ], 200);
    }

    /**
     * Request device transfer
     */
    public function requestDeviceTransfer(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'device_uuid' => 'required|string',
            'device_name' => 'nullable|string',
            'device_model' => 'nullable|string',
            'device_os' => 'nullable|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['البريد الإلكتروني أو كلمة المرور غير صحيحة'],
            ]);
        }

        // Check if this device_uuid is already used by another user
        $existingUser = User::where('device_uuid', $request->device_uuid)
            ->where('id', '!=', $user->id)
            ->first();

        if ($existingUser) {
            return response()->json([
                'message' => 'هذا الجهاز مرتبط بحساب آخر. يرجى استخدام جهاز آخر أو التواصل مع الدعم الفني.',
                'error' => 'device_already_bound'
            ], 403);
        }

        // Bind device to this user (this will unbind from old device)
        $user->bindDevice(
            $request->device_uuid,
            $request->device_name ?? 'Unknown Device',
            $request->device_model ?? 'Unknown Model',
            $request->device_os ?? 'Unknown OS'
        );

        // Revoke all tokens
        $user->tokens()->delete();

        // Create new token
        $token = $user->createToken('mobile_app')->plainTextToken;

        // Load academic profile and flatten it for Flutter
        $user->load('academicProfile');
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'message' => 'تم نقل الحساب إلى هذا الجهاز بنجاح',
            'user' => $userData,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 200);
    }

    /**
     * Get user's device transfer requests
     */
    public function myDeviceTransferRequests(Request $request): JsonResponse
    {
        // TODO: Implement device transfer requests tracking
        return response()->json([
            'data' => [],
        ], 200);
    }

    /**
     * Login or register with Google
     */
    public function loginWithGoogle(Request $request): JsonResponse
    {
        \Log::info('=== Google Login Attempt ===');
        \Log::info('Device UUID: ' . $request->input('device_uuid'));

        $request->validate([
            'id_token' => 'required|string',
            'device_uuid' => 'required|string',
            'device_name' => 'nullable|string',
            'device_model' => 'nullable|string',
            'device_os' => 'nullable|string',
        ], [
            'id_token.required' => 'رمز Google مطلوب',
            'device_uuid.required' => 'معرف الجهاز مطلوب',
        ]);

        // Verify Google token
        $googleService = app(GoogleAuthService::class);
        $googleData = $googleService->verifyIdToken($request->id_token);

        if (!$googleData) {
            \Log::warning('Google token verification failed');
            return response()->json([
                'message' => 'رمز Google غير صالح',
                'error' => 'invalid_google_token'
            ], 401);
        }

        \Log::info('Google user data: ' . json_encode([
            'google_id' => $googleData['google_id'],
            'email' => $googleData['email'],
            'name' => $googleData['name'],
        ]));

        // Check if email is verified
        if (!$googleData['email_verified']) {
            return response()->json([
                'message' => 'البريد الإلكتروني غير مُحقق في Google',
                'error' => 'email_not_verified'
            ], 403);
        }

        // Find existing user by google_id or email
        $user = User::where('google_id', $googleData['google_id'])
            ->orWhere('email', $googleData['email'])
            ->first();

        $isNewUser = false;

        if (!$user) {
            // Create new user
            $isNewUser = true;
            \Log::info('Creating new user via Google login');

            // Check if device is bound to another user
            $existingDevice = User::where('device_uuid', $request->device_uuid)->first();
            if ($existingDevice) {
                return response()->json([
                    'message' => 'هذا الجهاز مرتبط بحساب آخر',
                    'error' => 'device_already_bound'
                ], 403);
            }

            $user = User::create([
                'name' => $googleData['name'],
                'email' => $googleData['email'],
                'google_id' => $googleData['google_id'],
                'photo_url' => $googleData['picture'],
                'is_social_account' => true,
                'email_verified_at' => now(),
                'google_linked_at' => now(),
                'device_uuid' => $request->device_uuid,
                'device_name' => $request->device_name ?? 'Unknown Device',
                'device_model' => $request->device_model ?? 'Unknown Model',
                'device_os' => $request->device_os ?? 'Unknown OS',
            ]);

            \Log::info('New user created: ' . $user->id);
        } else {
            \Log::info('Existing user found: ' . $user->id);

            // Check if this is a social-only account trying to login with password
            // (not applicable here since this is Google login)

            // Link Google if not already linked
            if (!$user->google_id) {
                $user->update([
                    'google_id' => $googleData['google_id'],
                    'google_linked_at' => now(),
                ]);
                \Log::info('Google account linked to existing user');
            }

            // Update avatar if not set
            if (!$user->photo_url && $googleData['picture']) {
                $user->update(['photo_url' => $googleData['picture']]);
            }

            // Device binding check
            if (!$user->device_uuid) {
                // First device - bind it
                $existingDevice = User::where('device_uuid', $request->device_uuid)
                    ->where('id', '!=', $user->id)
                    ->first();

                if ($existingDevice) {
                    return response()->json([
                        'message' => 'هذا الجهاز مرتبط بحساب آخر',
                        'error' => 'device_already_bound'
                    ], 403);
                }

                $user->bindDevice(
                    $request->device_uuid,
                    $request->device_name ?? 'Unknown Device',
                    $request->device_model ?? 'Unknown Model',
                    $request->device_os ?? 'Unknown OS'
                );
                \Log::info('Device bound to user');
            } elseif ($user->device_uuid !== $request->device_uuid) {
                // Device mismatch - same rules apply as regular login
                // Bypass for certain accounts if needed
                $bypassDeviceCheck = in_array($user->email, ['student2@memo.com']);

                if (!$bypassDeviceCheck) {
                    return response()->json([
                        'message' => 'حسابك مرتبط بجهاز آخر',
                        'error' => 'device_mismatch'
                    ], 403);
                }
            }
        }

        // Record login
        $user->recordLogin();

        // Create token
        $token = $user->createToken('mobile_app')->plainTextToken;

        // Load academic profile and flatten it for Flutter
        $user->load('academicProfile');
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        \Log::info('Google login successful for user: ' . $user->id);

        return response()->json([
            'success' => true,
            'message' => $isNewUser ? 'تم إنشاء الحساب بنجاح' : 'تم تسجيل الدخول بنجاح',
            'is_new_user' => $isNewUser,
            'data' => [
                'user' => $userData,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => now()->addDays(7)->toISOString(),
            ],
        ], $isNewUser ? 201 : 200);
    }
}
