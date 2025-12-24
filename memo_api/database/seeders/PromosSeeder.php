<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Promo;
use App\Models\AppSetting;

class PromosSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * Seeds promotional slides for the home page slider
     */
    public function run(): void
    {
        // Enable promos section by default
        AppSetting::setValue('promos_section_enabled', '1');

        // Clear existing promos
        Promo::truncate();

        // Create sample promos
        $promos = [
            [
                'title' => 'دورات جديدة متاحة!',
                'subtitle' => 'اكتشف دوراتنا المتخصصة للبكالوريا',
                'badge' => 'جديد',
                'action_text' => 'اكتشف الآن',
                'icon_name' => 'school',
                'image_url' => null,
                'gradient_colors' => ['#2196F3', '#1565C0'],
                'action_type' => 'route',
                'action_value' => '/courses',
                'display_order' => 1,
                'is_active' => true,
            ],
            [
                'title' => 'تحدي الأسبوع',
                'subtitle' => 'أكمل 5 اختبارات واربح 100 نقطة إضافية',
                'badge' => 'تحدي',
                'action_text' => 'ابدأ التحدي',
                'icon_name' => 'emoji_events',
                'image_url' => null,
                'gradient_colors' => ['#FF9800', '#E65100'],
                'action_type' => 'route',
                'action_value' => '/quiz',
                'display_order' => 2,
                'is_active' => true,
            ],
            [
                'title' => 'محاكاة البكالوريا',
                'subtitle' => 'جرب نفسك في ظروف امتحان حقيقية',
                'badge' => null,
                'action_text' => 'ابدأ المحاكاة',
                'icon_name' => 'assignment',
                'image_url' => null,
                'gradient_colors' => ['#4CAF50', '#2E7D32'],
                'action_type' => 'route',
                'action_value' => '/bac',
                'display_order' => 3,
                'is_active' => true,
            ],
            [
                'title' => 'ادعُ أصدقاءك',
                'subtitle' => 'اربح 50 نقطة عن كل صديق يسجل',
                'badge' => 'مكافأة',
                'action_text' => 'دعوة صديق',
                'icon_name' => 'people',
                'image_url' => null,
                'gradient_colors' => ['#9C27B0', '#6A1B9A'],
                'action_type' => 'url',
                'action_value' => 'https://tahsil.app/invite',
                'display_order' => 4,
                'is_active' => true,
            ],
            [
                'title' => 'خطط دراستك بذكاء',
                'subtitle' => 'استخدم البلانر الذكي لتنظيم وقتك',
                'badge' => null,
                'action_text' => 'افتح البلانر',
                'icon_name' => 'calendar_month',
                'image_url' => null,
                'gradient_colors' => ['#00BCD4', '#0097A7'],
                'action_type' => 'route',
                'action_value' => '/planner',
                'display_order' => 5,
                'is_active' => true,
            ],
            [
                'title' => 'عروض رمضان',
                'subtitle' => 'خصم 50% على جميع الدورات',
                'badge' => 'عرض محدود',
                'action_text' => 'استفد الآن',
                'icon_name' => 'celebration',
                'image_url' => null,
                'gradient_colors' => ['#E91E63', '#AD1457'],
                'action_type' => 'route',
                'action_value' => '/subscriptions',
                'display_order' => 6,
                'is_active' => false, // Disabled by default, enable during Ramadan
            ],
        ];

        foreach ($promos as $promoData) {
            Promo::create($promoData);
        }

        $this->command->info('Promos seeded successfully! Created ' . count($promos) . ' promos.');
    }
}
