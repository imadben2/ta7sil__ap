<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class GoogleAuthService
{
    /**
     * Google's public keys endpoint
     */
    private const GOOGLE_CERTS_URL = 'https://www.googleapis.com/oauth2/v3/certs';

    /**
     * Google token info endpoint (alternative verification method)
     */
    private const TOKEN_INFO_URL = 'https://oauth2.googleapis.com/tokeninfo';

    /**
     * Valid client IDs for token verification
     */
    private array $validClientIds;

    public function __construct()
    {
        $this->validClientIds = array_filter([
            config('google.client_id'),
            config('google.ios_client_id'),
            config('google.android_client_id'),
        ]);
    }

    /**
     * Verify Google ID token and return user payload
     *
     * @param string $idToken The ID token from Google Sign-In
     * @return array|null User data or null if verification fails
     */
    public function verifyIdToken(string $idToken): ?array
    {
        try {
            // Use Google's tokeninfo endpoint for verification
            // This is simpler and doesn't require the Google API client library
            $response = Http::timeout(10)->get(self::TOKEN_INFO_URL, [
                'id_token' => $idToken,
            ]);

            if (!$response->successful()) {
                Log::warning('Google token verification failed: HTTP ' . $response->status());
                return null;
            }

            $payload = $response->json();

            // Verify the token is not expired
            if (isset($payload['exp']) && $payload['exp'] < time()) {
                Log::warning('Google token verification failed: Token expired');
                return null;
            }

            // Verify the audience (client ID) matches one of our valid client IDs
            if (!isset($payload['aud']) || !in_array($payload['aud'], $this->validClientIds)) {
                Log::warning('Google token verification failed: Invalid audience. Got: ' . ($payload['aud'] ?? 'null'));
                return null;
            }

            // Verify the issuer
            $validIssuers = ['accounts.google.com', 'https://accounts.google.com'];
            if (!isset($payload['iss']) || !in_array($payload['iss'], $validIssuers)) {
                Log::warning('Google token verification failed: Invalid issuer');
                return null;
            }

            // Return normalized user data
            return [
                'google_id' => $payload['sub'] ?? null,
                'email' => $payload['email'] ?? null,
                'email_verified' => ($payload['email_verified'] ?? 'false') === 'true',
                'name' => $payload['name'] ?? '',
                'picture' => $payload['picture'] ?? null,
                'given_name' => $payload['given_name'] ?? '',
                'family_name' => $payload['family_name'] ?? '',
                'locale' => $payload['locale'] ?? null,
            ];
        } catch (\Exception $e) {
            Log::error('Google token verification exception: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            return null;
        }
    }

    /**
     * Get the list of valid client IDs
     *
     * @return array
     */
    public function getValidClientIds(): array
    {
        return $this->validClientIds;
    }
}
