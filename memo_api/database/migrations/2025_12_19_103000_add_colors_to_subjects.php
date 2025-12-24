<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add colors and icons to subjects for better UI display
     */
    public function up(): void
    {
        // Define colors for subjects based on their category
        $subjectColors = [
            // Languages - Blue shades
            'اللغة العربية' => ['color' => '#2563eb', 'icon' => 'menu_book'],
            'اللغة الفرنسية' => ['color' => '#3b82f6', 'icon' => 'translate'],
            'اللغة الإنجليزية' => ['color' => '#60a5fa', 'icon' => 'language'],
            'لغة أجنبية (الاختيار الثالث)' => ['color' => '#93c5fd', 'icon' => 'g_translate'],

            // Sciences - Green shades
            'العلوم الطبيعية' => ['color' => '#16a34a', 'icon' => 'eco'],
            'علوم الطبيعة والحياة' => ['color' => '#22c55e', 'icon' => 'biotech'],
            'العلوم الفيزيائية' => ['color' => '#f97316', 'icon' => 'science'],

            // Math - Purple
            'الرياضيات' => ['color' => '#9333ea', 'icon' => 'calculate'],

            // Islamic Studies - Teal
            'التربية الإسلامية' => ['color' => '#14b8a6', 'icon' => 'mosque'],

            // History & Geography - Brown/Amber
            'التاريخ والجغرافيا' => ['color' => '#d97706', 'icon' => 'public'],

            // Philosophy - Indigo
            'الفلسفة' => ['color' => '#6366f1', 'icon' => 'psychology'],

            // Economics & Business - Emerald
            'الاقتصاد' => ['color' => '#059669', 'icon' => 'trending_up'],
            'المحاسبة' => ['color' => '#10b981', 'icon' => 'account_balance'],
            'القانون' => ['color' => '#0d9488', 'icon' => 'gavel'],

            // Technical - Cyan
            'الهندسة الكهربائية' => ['color' => '#06b6d4', 'icon' => 'electrical_services'],
            'الهندسة المدنية' => ['color' => '#0891b2', 'icon' => 'architecture'],
            'الهندسة الميكانيكية' => ['color' => '#0e7490', 'icon' => 'settings'],
        ];

        foreach ($subjectColors as $name => $data) {
            DB::table('subjects')
                ->where('name_ar', $name)
                ->update([
                    'color' => $data['color'],
                    'icon' => $data['icon'],
                ]);
        }

        // Update any remaining subjects without colors with a default color
        DB::table('subjects')
            ->whereNull('color')
            ->update(['color' => '#6366f1']); // Default to indigo
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reset colors to NULL
        DB::table('subjects')->update(['color' => null]);
    }
};
