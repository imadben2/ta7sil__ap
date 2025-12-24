<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // Check if user is authenticated
        if (!$user) {
            // For web requests (admin dashboard)
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }
            return redirect()->route('admin.login')
                ->with('error', 'يرجى تسجيل الدخول للمتابعة');
        }

        // Check if user is admin
        if (!$user->is_admin) {
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }
            auth()->logout();
            return redirect()->route('admin.login')
                ->with('error', 'هذا الحساب غير مصرح له بالدخول إلى لوحة التحكم');
        }

        // Check if user is active
        if (!$user->is_active) {
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Account disabled.',
                ], 403);
            }
            auth()->logout();
            return redirect()->route('admin.login')
                ->with('error', 'هذا الحساب معطّل. يرجى التواصل مع المسؤول');
        }

        return $next($request);
    }
}
