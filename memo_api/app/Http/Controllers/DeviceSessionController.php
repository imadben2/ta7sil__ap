<?php

namespace App\Http\Controllers;

use App\Http\Resources\DeviceSessionResource;
use App\Models\DeviceSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class DeviceSessionController extends Controller
{
    /**
     * Get all active device sessions for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $sessions = DeviceSession::where('user_id', $user->id)
            ->active()
            ->recentlyActive()
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'sessions' => DeviceSessionResource::collection($sessions),
                'total_count' => $sessions->count(),
                'current_session' => $sessions->where('is_current', true)->first(),
            ],
        ]);
    }

    /**
     * Logout from a specific device.
     */
    public function logout(Request $request, string $sessionId): JsonResponse
    {
        $user = $request->user();

        $session = DeviceSession::where('user_id', $user->id)
            ->where('id', $sessionId)
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'الجلسة غير موجودة',
            ], 404);
        }

        // Prevent logging out current session via this endpoint
        if ($session->is_current) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكنك تسجيل الخروج من الجهاز الحالي من هنا',
            ], 400);
        }

        // Revoke the associated token
        $token = PersonalAccessToken::findToken($session->token_id);
        if ($token) {
            $token->delete();
        }

        // Delete the session
        $session->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الخروج من الجهاز بنجاح',
        ]);
    }

    /**
     * Logout from all other devices except the current one.
     */
    public function logoutAllOthers(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get all sessions except the current one
        $sessions = DeviceSession::where('user_id', $user->id)
            ->where('is_current', false)
            ->get();

        // Revoke all tokens and delete sessions
        foreach ($sessions as $session) {
            $token = PersonalAccessToken::findToken($session->token_id);
            if ($token) {
                $token->delete();
            }
            $session->delete();
        }

        $count = $sessions->count();

        return response()->json([
            'success' => true,
            'message' => "تم تسجيل الخروج من {$count} جهاز بنجاح",
            'data' => [
                'logged_out_count' => $count,
            ],
        ]);
    }

    /**
     * Update device session information.
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentToken = $request->bearerToken();

        $validated = $request->validate([
            'device_name' => 'sometimes|string|max:255',
            'device_type' => 'sometimes|in:mobile,tablet,web',
            'device_os' => 'sometimes|string|max:50',
            'os_version' => 'sometimes|string|max:50',
            'app_version' => 'sometimes|string|max:50',
            'location' => 'sometimes|string|max:255',
            'latitude' => 'sometimes|numeric|between:-90,90',
            'longitude' => 'sometimes|numeric|between:-180,180',
        ]);

        // Find or create session for current token
        $tokenModel = PersonalAccessToken::findToken($currentToken);
        if (!$tokenModel) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid token',
            ], 401);
        }

        $session = DeviceSession::where('user_id', $user->id)
            ->where('token_id', (string) $tokenModel->id)
            ->first();

        if (!$session) {
            $validated['user_id'] = $user->id;
            $validated['token_id'] = (string) $tokenModel->id;
            $validated['ip_address'] = $request->ip();
            $validated['user_agent'] = $request->userAgent();
            $validated['is_current'] = true;
            $validated['last_active_at'] = now();

            $session = DeviceSession::create($validated);
            $session->markAsCurrent();
        } else {
            $session->update($validated);
            $session->updateLastActive();
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث معلومات الجلسة بنجاح',
            'data' => new DeviceSessionResource($session),
        ]);
    }

    /**
     * Get statistics about device sessions.
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();

        $totalSessions = DeviceSession::where('user_id', $user->id)->count();
        $activeSessions = DeviceSession::where('user_id', $user->id)->active()->count();
        $expiredSessions = DeviceSession::where('user_id', $user->id)->expired()->count();

        $sessionsByType = DeviceSession::where('user_id', $user->id)
            ->selectRaw('device_type, COUNT(*) as count')
            ->groupBy('device_type')
            ->get()
            ->pluck('count', 'device_type');

        $sessionsByOS = DeviceSession::where('user_id', $user->id)
            ->selectRaw('device_os, COUNT(*) as count')
            ->groupBy('device_os')
            ->get()
            ->pluck('count', 'device_os');

        return response()->json([
            'success' => true,
            'data' => [
                'total_sessions' => $totalSessions,
                'active_sessions' => $activeSessions,
                'expired_sessions' => $expiredSessions,
                'by_device_type' => $sessionsByType,
                'by_os' => $sessionsByOS,
            ],
        ]);
    }
}
