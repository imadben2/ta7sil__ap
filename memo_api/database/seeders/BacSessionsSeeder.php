<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BacSessionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Creates GLOBAL BAC sessions shared across ALL years
     */
    public function run(): void
    {
        // BAC Sessions - GLOBAL (shared across all years)
        // Only 1 session: Normal (main session for all years)
        $sessions = [
            [
                'name_ar' => 'الدورة العادية',
                'slug' => 'normal',
                'session_type' => 'main',
                'exam_date' => null,
            ],
        ];

        foreach ($sessions as $session) {
            // Use insertOrIgnore to avoid duplicates
            DB::table('bac_sessions')->insertOrIgnore($session);
        }

        // BAC Years (سنوات البكالوريا من 2010 إلى 2024)
        $years = [];
        for ($year = 2010; $year <= 2024; $year++) {
            $years[] = [
                'year' => $year,
                'is_active' => ($year >= 2020), // Last 5 years are active
            ];
        }

        foreach ($years as $year) {
            DB::table('bac_years')->insertOrIgnore($year);
        }

        $this->command->info('BAC sessions and years seeded successfully!');
        $this->command->info('- 1 BAC session (الدورة العادية) - GLOBAL for all years');
        $this->command->info('- 15 BAC years (2010-2024)');
        $this->command->info('- Years 2020-2024 marked as active');
    }
}
