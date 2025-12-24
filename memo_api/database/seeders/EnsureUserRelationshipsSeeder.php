<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\UserStats;
use App\Models\PlannerSetting;

class EnsureUserRelationshipsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();

        foreach ($users as $user) {
            // Ensure user has stats
            if (!$user->stats) {
                UserStats::create([
                    'user_id' => $user->id,
                    'current_streak_days' => 0,
                    'longest_streak_days' => 0,
                    'gamification_points' => 0,
                    'level' => 1,
                    'experience_points' => 0,
                    'total_study_minutes' => 0,
                    'last_study_date' => null,
                ]);
                $this->command->info("Created stats for user {$user->id}");
            }

            // Ensure user has planner settings
            if (!$user->plannerSetting) {
                PlannerSetting::create([
                    'user_id' => $user->id,
                    'study_start_time' => '17:30',
                    'study_end_time' => '22:30',
                    'sleep_start_time' => '23:00',
                    'sleep_end_time' => '06:00',
                    'use_pomodoro' => true,
                    'pomodoro_duration' => 25,
                    'short_break' => 5,
                    'long_break' => 15,
                    'enable_prayer_times' => true,
                    'prayer_duration_minutes' => 15,
                    'auto_reschedule_missed' => true,
                    'smart_content_suggestions' => true,
                ]);
                $this->command->info("Created planner settings for user {$user->id}");
            }
        }

        $this->command->info('All users now have required relationships!');
    }
}
