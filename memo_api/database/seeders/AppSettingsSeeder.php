<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use Illuminate\Database\Seeder;

class AppSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Minimum required app version
        AppSetting::firstOrCreate(
            ['key' => 'min_app_version'],
            [
                'value' => '1.0',
                'type' => 'string',
                'group' => 'app',
                'description' => 'Minimum required app version'
            ]
        );

        // Sponsors section enabled
        AppSetting::firstOrCreate(
            ['key' => 'sponsors_section_enabled'],
            [
                'value' => '1',
                'type' => 'boolean',
                'group' => 'home',
                'description' => 'Enable sponsors section on home page'
            ]
        );

        // Promos section enabled
        AppSetting::firstOrCreate(
            ['key' => 'promos_section_enabled'],
            [
                'value' => '1',
                'type' => 'boolean',
                'group' => 'home',
                'description' => 'Enable promos section on home page'
            ]
        );
    }
}
