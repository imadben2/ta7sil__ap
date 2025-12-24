<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class PrayerTime extends Model
{
    protected $fillable = [
        'user_id',
        'date',
        'fajr_time',
        'dhuhr_time',
        'asr_time',
        'maghrib_time',
        'isha_time',
        'prayer_duration_minutes',
    ];

    protected $casts = [
        'date' => 'date',
        'prayer_duration_minutes' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getPrayerTimes(): array
    {
        return [
            'fajr' => $this->fajr_time,
            'dhuhr' => $this->dhuhr_time,
            'asr' => $this->asr_time,
            'maghrib' => $this->maghrib_time,
            'isha' => $this->isha_time,
        ];
    }

    public function getNextPrayerTime(?Carbon $currentTime = null): ?array
    {
        $currentTime = $currentTime ?? Carbon::now();
        $prayers = $this->getPrayerTimes();

        foreach ($prayers as $name => $time) {
            $prayerTime = Carbon::parse($time);
            if ($prayerTime->isAfter($currentTime)) {
                return [
                    'name' => $name,
                    'time' => $time,
                ];
            }
        }

        return null;
    }
}
