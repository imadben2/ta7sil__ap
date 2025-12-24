<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PrayerTime;
use App\Models\PlannerSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

/**
 * Prayer Times Controller
 *
 * Manages prayer times integration for the intelligent planner.
 * Uses Aladhan API (https://aladhan.com/prayer-times-api) for fetching prayer times.
 *
 * Features:
 * - Get prayer times for a specific date
 * - Sync prayer times for the next 30 days
 * - Auto-detect location from planner settings
 * - Cache prayer times in database
 */
class PrayerTimesController extends Controller
{
    /**
     * Aladhan API base URL
     */
    private const ALADHAN_API_BASE = 'http://api.aladhan.com/v1';

    /**
     * Get prayer times for a specific date
     *
     * Returns 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
     * Uses cached data from database if available
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getPrayerTimes(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'nullable|date',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $date = $request->date ? Carbon::parse($request->date) : Carbon::today();

        // Get user's planner settings for location
        $settings = PlannerSetting::where('user_id', $user->id)->first();

        // Use provided coordinates or fall back to settings or default (Algiers)
        $latitude = $request->latitude ?? ($settings->latitude ?? 36.7538);
        $longitude = $request->longitude ?? ($settings->longitude ?? 3.0588);

        // Check if prayer times are already cached for this date
        $cachedPrayerTimes = PrayerTime::where('user_id', $user->id)
            ->where('prayer_date', $date->format('Y-m-d'))
            ->get();

        if ($cachedPrayerTimes->isNotEmpty()) {
            return response()->json([
                'date' => $date->format('Y-m-d'),
                'prayer_times' => $cachedPrayerTimes->map(function ($prayer) {
                    return [
                        'name' => $prayer->prayer_name,
                        'time' => $prayer->prayer_time,
                        'duration_minutes' => $prayer->duration_minutes,
                    ];
                }),
                'source' => 'cache',
            ]);
        }

        // Fetch from Aladhan API
        try {
            $prayerTimes = $this->fetchPrayerTimesFromAPI($date, $latitude, $longitude);

            // Cache in database
            $this->cachePrayerTimes($user->id, $date, $prayerTimes);

            return response()->json([
                'date' => $date->format('Y-m-d'),
                'prayer_times' => $prayerTimes,
                'source' => 'api',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to fetch prayer times',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Sync prayer times for the next 30 days
     *
     * Fetches and caches prayer times to avoid repeated API calls
     * Should be called weekly or when location changes
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function syncPrayerTimes(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'days' => 'nullable|integer|min:1|max:60',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $days = $request->days ?? 30;

        // Get user's planner settings for location
        $settings = PlannerSetting::where('user_id', $user->id)->first();

        // Use provided coordinates or fall back to settings or default (Algiers)
        $latitude = $request->latitude ?? ($settings->latitude ?? 36.7538);
        $longitude = $request->longitude ?? ($settings->longitude ?? 3.0588);

        $syncedDays = 0;
        $errors = [];

        // Clear old prayer times (older than today)
        PrayerTime::where('user_id', $user->id)
            ->where('prayer_date', '<', Carbon::today()->format('Y-m-d'))
            ->delete();

        // Fetch prayer times for next X days
        for ($i = 0; $i < $days; $i++) {
            $date = Carbon::today()->addDays($i);

            try {
                // Skip if already cached for this date
                $existingCount = PrayerTime::where('user_id', $user->id)
                    ->where('prayer_date', $date->format('Y-m-d'))
                    ->count();

                if ($existingCount >= 5) {
                    continue; // Already have all 5 prayers cached
                }

                // Fetch from API
                $prayerTimes = $this->fetchPrayerTimesFromAPI($date, $latitude, $longitude);

                // Cache in database
                $this->cachePrayerTimes($user->id, $date, $prayerTimes);

                $syncedDays++;

                // Rate limiting - sleep briefly between requests
                if ($i < $days - 1) {
                    usleep(200000); // 200ms delay
                }
            } catch (\Exception $e) {
                $errors[] = [
                    'date' => $date->format('Y-m-d'),
                    'error' => $e->getMessage(),
                ];
            }
        }

        return response()->json([
            'message' => 'Temps de prière synchronisés avec succès',
            'synced_days' => $syncedDays,
            'total_days_requested' => $days,
            'errors' => $errors,
            'location' => [
                'latitude' => $latitude,
                'longitude' => $longitude,
            ],
        ]);
    }

    /**
     * Fetch prayer times from Aladhan API
     *
     * @param Carbon $date
     * @param float $latitude
     * @param float $longitude
     * @return array
     * @throws \Exception
     */
    private function fetchPrayerTimesFromAPI(Carbon $date, float $latitude, float $longitude): array
    {
        $response = Http::timeout(10)->get(self::ALADHAN_API_BASE . '/timings', [
            'latitude' => $latitude,
            'longitude' => $longitude,
            'date' => $date->format('d-m-Y'),
            'method' => 3, // Muslim World League
        ]);

        if (!$response->successful()) {
            throw new \Exception('Aladhan API request failed');
        }

        $data = $response->json();

        if (!isset($data['data']['timings'])) {
            throw new \Exception('Invalid response from Aladhan API');
        }

        $timings = $data['data']['timings'];

        return [
            [
                'name' => 'Fajr',
                'time' => $this->formatPrayerTime($timings['Fajr']),
                'duration_minutes' => 15,
            ],
            [
                'name' => 'Dhuhr',
                'time' => $this->formatPrayerTime($timings['Dhuhr']),
                'duration_minutes' => 15,
            ],
            [
                'name' => 'Asr',
                'time' => $this->formatPrayerTime($timings['Asr']),
                'duration_minutes' => 15,
            ],
            [
                'name' => 'Maghrib',
                'time' => $this->formatPrayerTime($timings['Maghrib']),
                'duration_minutes' => 15,
            ],
            [
                'name' => 'Isha',
                'time' => $this->formatPrayerTime($timings['Isha']),
                'duration_minutes' => 15,
            ],
        ];
    }

    /**
     * Cache prayer times in database
     *
     * @param int $userId
     * @param Carbon $date
     * @param array $prayerTimes
     * @return void
     */
    private function cachePrayerTimes(int $userId, Carbon $date, array $prayerTimes): void
    {
        foreach ($prayerTimes as $prayer) {
            PrayerTime::updateOrCreate(
                [
                    'user_id' => $userId,
                    'prayer_date' => $date->format('Y-m-d'),
                    'prayer_name' => $prayer['name'],
                ],
                [
                    'prayer_time' => $prayer['time'],
                    'duration_minutes' => $prayer['duration_minutes'],
                ]
            );
        }
    }

    /**
     * Format prayer time from API response (HH:MM format)
     *
     * API returns times like "05:30 (CET)" - we need just "05:30"
     *
     * @param string $time
     * @return string
     */
    private function formatPrayerTime(string $time): string
    {
        // Extract just HH:MM part (remove timezone if present)
        preg_match('/(\d{2}:\d{2})/', $time, $matches);
        return $matches[1] ?? $time;
    }
}
