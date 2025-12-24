<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use App\Models\User;

class AuthController extends Controller
{
    /**
     * Show admin login form.
     *
     * GET /admin/login
     */
    public function showLoginForm()
    {
        // Redirect if already authenticated as admin
        if (Auth::check() && Auth::user()->is_admin) {
            return redirect()->route('admin.dashboard');
        }

        return view('auth.login');
    }

    /**
     * Handle admin login request.
     *
     * POST /admin/login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ], [
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
            'password.required' => 'كلمة المرور مطلوبة',
        ]);

        // Rate limiting: 5 attempts per minute
        $key = 'admin-login-' . $request->ip();
        if (cache()->has($key) && cache()->get($key) >= 5) {
            throw ValidationException::withMessages([
                'email' => 'تم تجاوز الحد الأقصى من المحاولات. يرجى المحاولة بعد دقيقة.',
            ]);
        }

        // Attempt authentication
        $credentials = $request->only('email', 'password');
        $remember = $request->boolean('remember');

        if (Auth::attempt($credentials, $remember)) {
            $user = Auth::user();

            // Check if user is admin
            if (!$user->is_admin) {
                Auth::logout();
                return redirect()->back()
                    ->withErrors(['email' => 'هذا الحساب غير مصرح له بالدخول إلى لوحة التحكم'])
                    ->withInput($request->only('email'));
            }

            // Check if user is active
            if (!$user->is_active) {
                Auth::logout();
                return redirect()->back()
                    ->withErrors(['email' => 'هذا الحساب معطّل. يرجى التواصل مع المسؤول'])
                    ->withInput($request->only('email'));
            }

            // Update last login
            $user->update(['last_login_at' => now()]);

            // Clear rate limit
            cache()->forget($key);

            // Regenerate session
            $request->session()->regenerate();

            return redirect()->intended(route('admin.dashboard'));
        }

        // Increment failed attempts
        $attempts = cache()->get($key, 0) + 1;
        cache()->put($key, $attempts, now()->addMinutes(1));

        throw ValidationException::withMessages([
            'email' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        ]);
    }

    /**
     * Handle admin logout.
     *
     * POST /admin/logout
     */
    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')
            ->with('success', 'تم تسجيل الخروج بنجاح');
    }

    /**
     * Show forgot password form.
     *
     * GET /admin/password/reset
     */
    public function showForgotPasswordForm()
    {
        return view('auth.forgot-password');
    }

    /**
     * Send password reset link.
     *
     * POST /admin/password/email
     */
    public function sendResetLinkEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ], [
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
        ]);

        // Rate limiting: 3 attempts per 10 minutes
        $key = 'password-reset-' . $request->ip();
        if (cache()->has($key) && cache()->get($key) >= 3) {
            return redirect()->back()
                ->withErrors(['email' => 'تم تجاوز الحد الأقصى من المحاولات. يرجى المحاولة بعد 10 دقائق.'])
                ->withInput();
        }

        // Check if user exists and is admin
        $user = User::where('email', $request->email)
            ->where('is_admin', true)
            ->first();

        if (!$user) {
            // Increment attempts
            $attempts = cache()->get($key, 0) + 1;
            cache()->put($key, $attempts, now()->addMinutes(10));

            return redirect()->back()
                ->withErrors(['email' => 'لم يتم العثور على حساب إداري بهذا البريد الإلكتروني'])
                ->withInput();
        }

        // Send password reset link
        $status = Password::sendResetLink(
            $request->only('email')
        );

        // Clear rate limit on success
        if ($status === Password::RESET_LINK_SENT) {
            cache()->forget($key);

            return redirect()->back()
                ->with('status', 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني');
        }

        // Increment attempts
        $attempts = cache()->get($key, 0) + 1;
        cache()->put($key, $attempts, now()->addMinutes(10));

        return redirect()->back()
            ->withErrors(['email' => 'حدث خطأ أثناء إرسال الرابط. يرجى المحاولة لاحقاً'])
            ->withInput();
    }

    /**
     * Show reset password form.
     *
     * GET /admin/password/reset/{token}
     */
    public function showResetPasswordForm(Request $request, $token)
    {
        return view('auth.reset-password', [
            'token' => $token,
            'email' => $request->email,
        ]);
    }

    /**
     * Reset password.
     *
     * POST /admin/password/reset
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ], [
            'email.required' => 'البريد الإلكتروني مطلوب',
            'email.email' => 'البريد الإلكتروني غير صحيح',
            'password.required' => 'كلمة المرور مطلوبة',
            'password.min' => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
            'password.confirmed' => 'كلمة المرور وتأكيدها غير متطابقتين',
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));

                $user->save();

                // Revoke all existing tokens (if using Sanctum)
                $user->tokens()->delete();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return redirect()->route('admin.login')
                ->with('success', 'تم إعادة تعيين كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن');
        }

        return redirect()->back()
            ->withErrors(['email' => 'رابط إعادة التعيين غير صالح أو منتهي الصلاحية'])
            ->withInput($request->only('email'));
    }
}
