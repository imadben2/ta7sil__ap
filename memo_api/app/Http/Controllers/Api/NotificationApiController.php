<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotificationApiController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    /**
     * Get user's notifications
     * GET /api/notifications
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $perPage = $request->get('per_page', 20);

        $notifications = $user->notifications()
            ->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $notifications,
        ]);
    }

    /**
     * Get unread notifications
     * GET /api/notifications/unread
     */
    public function unread(Request $request): JsonResponse
    {
        $user = $request->user();

        $notifications = $user->unreadNotifications()->get();

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'unread_count' => $notifications->count(),
        ]);
    }

    /**
     * Mark notification as read
     * POST /api/notifications/{id}/mark-as-read
     */
    public function markAsRead(Request $request, $id): JsonResponse
    {
        $user = $request->user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'تم تحديد الإشعار كمقروء',
        ]);
    }

    /**
     * Mark all notifications as read
     * POST /api/notifications/mark-all-as-read
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->unreadNotifications->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'تم تحديد جميع الإشعارات كمقروءة',
        ]);
    }

    /**
     * Delete a notification
     * DELETE /api/notifications/{id}
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = $request->user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الإشعار',
        ]);
    }

    /**
     * Get notification statistics
     * GET /api/notifications/stats
     */
    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = [
            'total' => $user->notifications()->count(),
            'unread' => $user->unreadNotifications()->count(),
            'read' => $user->readNotifications()->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}
