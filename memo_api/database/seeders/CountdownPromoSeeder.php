<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Promo;
use Carbon\Carbon;

class CountdownPromoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * Creates a default countdown promo for Baccalauréat exam
     */
    public function run(): void
    {
        // Check if a countdown promo already exists
        $existingCountdown = Promo::where('promo_type', 'countdown')->first();

        if ($existingCountdown) {
            $this->command->info('Countdown promo already exists. Skipping...');
            return;
        }

        // BAC 2025 date - June 15, 2025 at 8:00 AM (Algeria time)
        $bacDate = Carbon::create(2025, 6, 15, 8, 0, 0, 'Africa/Algiers');

        Promo::create([
            'title' => 'العد التنازلي للبكالوريا 2025',
            'subtitle' => 'استعد للنجاح!',
            'badge' => 'مهم',
            'action_text' => null,
            'icon_name' => 'timer',
            'image_url' => null,
            'gradient_colors' => ['#3B82F6', '#1D4ED8'], // Blue gradient
            'action_type' => 'none',
            'action_value' => null,
            'display_order' => 0, // First position
            'is_active' => true,
            'promo_type' => 'countdown',
            'target_date' => $bacDate,
            'countdown_label' => 'يوم على البكالوريا',
            'starts_at' => null,
            'ends_at' => $bacDate, // Ends when BAC starts
        ]);

        $this->command->info('Countdown promo created successfully!');
    }
}
