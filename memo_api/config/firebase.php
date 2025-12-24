<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Firebase Credentials
    |--------------------------------------------------------------------------
    |
    | Path to the Firebase service account credentials JSON file.
    | Download this from Firebase Console > Project Settings > Service Accounts
    |
    */
    'credentials' => [
        'file' => storage_path('app/firebase-credentials.json'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Firebase Project ID
    |--------------------------------------------------------------------------
    |
    | Your Firebase project ID from the Firebase Console.
    |
    */
    'project_id' => env('FIREBASE_PROJECT_ID'),

    /*
    |--------------------------------------------------------------------------
    | FCM Settings
    |--------------------------------------------------------------------------
    |
    | Configuration for Firebase Cloud Messaging.
    |
    */
    'fcm' => [
        // Default notification icon (Android)
        'default_icon' => env('FCM_DEFAULT_ICON', 'ic_notification'),

        // Default notification color (Android)
        'default_color' => env('FCM_DEFAULT_COLOR', '#4CAF50'),

        // Default notification sound
        'default_sound' => env('FCM_DEFAULT_SOUND', 'default'),

        // Android channel ID
        'android_channel_id' => env('FCM_ANDROID_CHANNEL_ID', 'memo_bac_notifications'),

        // Retry settings
        'retry_count' => env('FCM_RETRY_COUNT', 3),
        'retry_delay' => env('FCM_RETRY_DELAY', 1000), // milliseconds

        // Batch sending
        'batch_size' => env('FCM_BATCH_SIZE', 500), // Max tokens per batch
    ],

    /*
    |--------------------------------------------------------------------------
    | Notification Rate Limiting
    |--------------------------------------------------------------------------
    |
    | Prevent notification spam by limiting notifications per user.
    |
    */
    'rate_limiting' => [
        'enabled' => env('NOTIFICATION_RATE_LIMIT_ENABLED', true),
        'max_per_day' => env('NOTIFICATION_MAX_PER_DAY', 10),
        'max_per_hour' => env('NOTIFICATION_MAX_PER_HOUR', 5),
    ],

    /*
    |--------------------------------------------------------------------------
    | Deep Link Configuration
    |--------------------------------------------------------------------------
    |
    | Base URL scheme for deep linking into the mobile app.
    |
    */
    'deep_link' => [
        'scheme' => env('DEEP_LINK_SCHEME', 'memobac'),
        'host' => env('DEEP_LINK_HOST', ''),
    ],
];
