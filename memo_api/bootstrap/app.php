<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'admin' => \App\Http\Middleware\EnsureUserIsAdmin::class,
        ]);

        // Configure auth middleware to redirect to admin.login
        $middleware->redirectGuestsTo(function ($request) {
            return route('admin.login');
        });

        // Configure session and CSRF settings
        $middleware->encryptCookies(except: [
            // Add any cookies you don't want encrypted
        ]);

        $middleware->validateCsrfTokens(except: [
            // Add any URIs you want to exclude from CSRF verification
        ]);

        // Add compression middleware globally for API responses
        $middleware->append(\App\Http\Middleware\CompressResponse::class);

        // Track user activity
        $middleware->append(\App\Http\Middleware\TrackUserActivity::class);

        // Set timezone from app settings
        $middleware->append(\App\Http\Middleware\SetTimezone::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
