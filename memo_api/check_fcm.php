<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\FcmToken;
use App\Models\User;

echo "=== Simulating previewBroadcast for target_type=all ===\n\n";

// Simulate the exact query from previewBroadcast
$targetType = 'all';

$query = User::where('is_active', true)
    ->whereHas('fcmTokens', function ($q) {
        $q->where('is_active', true);
    });

// No additional filters for 'all'
$count = $query->count();
echo "Recipients count: {$count}\n";

$userIds = $query->pluck('id')->toArray();
echo "User IDs: " . json_encode($userIds) . "\n";

$totalDevices = FcmToken::whereIn('user_id', $userIds)
    ->where('is_active', true)
    ->count();
echo "Devices count: {$totalDevices}\n";

echo "\n=== Raw FCM Token Data ===\n";
$tokens = FcmToken::all();
foreach ($tokens as $t) {
    echo "ID: {$t->id}, user_id: {$t->user_id}, is_active: " . ($t->is_active ? '1' : '0') . ", platform: {$t->device_platform}\n";
}

echo "\n=== Check is_active column type ===\n";
$token = FcmToken::first();
if ($token) {
    echo "is_active raw value: " . var_export($token->getRawOriginal('is_active'), true) . "\n";
    echo "is_active casted: " . var_export($token->is_active, true) . "\n";
}
