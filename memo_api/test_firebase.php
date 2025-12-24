<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\Http;

echo "=== Testing Firebase Connection ===\n\n";

// Check config
$projectId = config('firebase.project_id');
$credentialsPath = config('firebase.credentials.file');

echo "Project ID: " . ($projectId ?: 'NOT SET') . "\n";
echo "Credentials Path: " . ($credentialsPath ?: 'NOT SET') . "\n";
echo "Credentials File Exists: " . (file_exists($credentialsPath) ? 'YES' : 'NO') . "\n\n";

if (!file_exists($credentialsPath)) {
    echo "ERROR: Firebase credentials file not found!\n";
    exit(1);
}

// Read credentials
$credentials = json_decode(file_get_contents($credentialsPath), true);
echo "Credentials project_id: " . ($credentials['project_id'] ?? 'NOT FOUND') . "\n";
echo "Client email: " . ($credentials['client_email'] ?? 'NOT FOUND') . "\n\n";

// Try to get access token
echo "=== Getting Firebase Access Token ===\n";

try {
    $now = time();
    $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));

    $jwtClaim = base64_encode(json_encode([
        'iss' => $credentials['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'iat' => $now,
        'exp' => $now + 3600,
    ]));

    $signatureInput = $jwtHeader . '.' . $jwtClaim;

    openssl_sign($signatureInput, $signature, $credentials['private_key'], 'SHA256');
    $jwtSignature = base64_encode($signature);

    $jwt = $signatureInput . '.' . $jwtSignature;

    $response = Http::withOptions(['verify' => false])->asForm()->post('https://oauth2.googleapis.com/token', [
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt,
    ]);

    if ($response->successful()) {
        $token = $response->json('access_token');
        echo "SUCCESS! Got access token: " . substr($token, 0, 50) . "...\n\n";
        echo "=== Firebase is configured correctly! ===\n";
    } else {
        echo "FAILED to get token!\n";
        echo "Response: " . $response->body() . "\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
