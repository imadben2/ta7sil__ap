<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Google OAuth Client IDs
    |--------------------------------------------------------------------------
    |
    | These are the client IDs from your Google Cloud Console project.
    | You need to create OAuth 2.0 credentials for:
    | - Web application (for server-side verification)
    | - Android (with SHA-1 fingerprint)
    | - iOS (with bundle ID)
    |
    */

    'client_id' => env('GOOGLE_CLIENT_ID'),

    'ios_client_id' => env('GOOGLE_IOS_CLIENT_ID'),

    'android_client_id' => env('GOOGLE_ANDROID_CLIENT_ID'),

];
