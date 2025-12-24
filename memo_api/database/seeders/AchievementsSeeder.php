<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AchievementsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $achievements = [
            // الإنجازات الأولية (First Steps)
            [
                'name_ar' => 'الجلسة الأولى',
                'description_ar' => 'أكمل أول جلسة دراسية',
                'icon' => 'star',
                'badge_color' => '#10B981',
                'criteria_type' => 'FirstSession',
                'criteria_value' => json_encode(['sessions' => 1]),
                'points' => 10
            ],
            [
                'name_ar' => 'المتعلم المبتدئ',
                'description_ar' => 'أكمل 5 جلسات دراسية',
                'icon' => 'book',
                'badge_color' => '#3B82F6',
                'criteria_type' => 'SessionCount',
                'criteria_value' => json_encode(['sessions' => 5]),
                'points' => 25
            ],
            [
                'name_ar' => 'المثابر',
                'description_ar' => 'ادرس لمدة 3 أيام متتالية',
                'icon' => 'calendar',
                'badge_color' => '#F59E0B',
                'criteria_type' => 'ConsecutiveDays',
                'criteria_value' => json_encode(['days' => 3]),
                'points' => 50
            ],

            // إنجازات الوقت (Time-based)
            [
                'name_ar' => 'ساعة التركيز',
                'description_ar' => 'ادرس لمدة ساعة متواصلة',
                'icon' => 'clock',
                'badge_color' => '#8B5CF6',
                'criteria_type' => 'StudyMinutes',
                'criteria_value' => json_encode(['minutes' => 60]),
                'points' => 30
            ],
            [
                'name_ar' => 'الماراثوني',
                'description_ar' => 'ادرس لمدة 3 ساعات في يوم واحد',
                'icon' => 'zap',
                'badge_color' => '#EF4444',
                'criteria_type' => 'DailyStudyMinutes',
                'criteria_value' => json_encode(['minutes' => 180]),
                'points' => 100
            ],
            [
                'name_ar' => 'المتفاني',
                'description_ar' => 'ادرس 10 ساعات في الأسبوع',
                'icon' => 'award',
                'badge_color' => '#EC4899',
                'criteria_type' => 'WeeklyStudyMinutes',
                'criteria_value' => json_encode(['minutes' => 600]),
                'points' => 150
            ],
            [
                'name_ar' => 'البطل الأسطوري',
                'description_ar' => 'ادرس 40 ساعة في الشهر',
                'icon' => 'trophy',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'MonthlyStudyMinutes',
                'criteria_value' => json_encode(['minutes' => 2400]),
                'points' => 500
            ],

            // إنجازات المحتوى (Content-based)
            [
                'name_ar' => 'قارئ نهم',
                'description_ar' => 'أكمل 10 دروس',
                'icon' => 'book-open',
                'badge_color' => '#06B6D4',
                'criteria_type' => 'ContentCount',
                'criteria_value' => json_encode(['type' => 'lesson', 'count' => 10]),
                'points' => 50
            ],
            [
                'name_ar' => 'محب الملخصات',
                'description_ar' => 'أكمل 20 ملخصا',
                'icon' => 'file-text',
                'badge_color' => '#14B8A6',
                'criteria_type' => 'ContentCount',
                'criteria_value' => json_encode(['type' => 'summary', 'count' => 20]),
                'points' => 75
            ],
            [
                'name_ar' => 'متحدي التمارين',
                'description_ar' => 'أكمل 15 سلسلة تمارين',
                'icon' => 'edit',
                'badge_color' => '#F59E0B',
                'criteria_type' => 'ContentCount',
                'criteria_value' => json_encode(['type' => 'exercises', 'count' => 15]),
                'points' => 100
            ],

            // إنجازات الاختبارات (Quiz-based)
            [
                'name_ar' => 'المتقن',
                'description_ar' => 'احصل على 100% في اختبار',
                'icon' => 'check-circle',
                'badge_color' => '#10B981',
                'criteria_type' => 'PerfectQuiz',
                'criteria_value' => json_encode(['score' => 100]),
                'points' => 75
            ],
            [
                'name_ar' => 'النجم الساطع',
                'description_ar' => 'احصل على 100% في 5 اختبارات',
                'icon' => 'star',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'PerfectQuizStreak',
                'criteria_value' => json_encode(['count' => 5]),
                'points' => 200
            ],
            [
                'name_ar' => 'متحدي الاختبارات',
                'description_ar' => 'أكمل 20 اختبارا',
                'icon' => 'file-check',
                'badge_color' => '#EF4444',
                'criteria_type' => 'QuizCount',
                'criteria_value' => json_encode(['count' => 20]),
                'points' => 100
            ],
            [
                'name_ar' => 'محطم الأرقام',
                'description_ar' => 'أكمل 50 اختبارا',
                'icon' => 'trending-up',
                'badge_color' => '#8B5CF6',
                'criteria_type' => 'QuizCount',
                'criteria_value' => json_encode(['count' => 50]),
                'points' => 250
            ],

            // إنجازات البكالوريا (BAC Simulations)
            [
                'name_ar' => 'محاكي البكالوريا',
                'description_ar' => 'أكمل أول محاكاة بكالوريا',
                'icon' => 'file-text',
                'badge_color' => '#3B82F6',
                'criteria_type' => 'BacSimulation',
                'criteria_value' => json_encode(['count' => 1]),
                'points' => 50
            ],
            [
                'name_ar' => 'مستعد للبكالوريا',
                'description_ar' => 'أكمل 5 محاكيات بكالوريا',
                'icon' => 'briefcase',
                'badge_color' => '#10B981',
                'criteria_type' => 'BacSimulation',
                'criteria_value' => json_encode(['count' => 5]),
                'points' => 150
            ],
            [
                'name_ar' => 'بطل البكالوريا',
                'description_ar' => 'احصل على أكثر من 15/20 في محاكاة',
                'icon' => 'award',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'BacHighScore',
                'criteria_value' => json_encode(['score' => 15]),
                'points' => 200
            ],

            // إنجازات المواد (Subject-based)
            [
                'name_ar' => 'عبقري الرياضيات',
                'description_ar' => 'أكمل 20 محتوى في الرياضيات',
                'icon' => 'calculator',
                'badge_color' => '#3B82F6',
                'criteria_type' => 'SubjectMastery',
                'criteria_value' => json_encode(['subject' => 'mathematics', 'count' => 20]),
                'points' => 100
            ],
            [
                'name_ar' => 'عالم الفيزياء',
                'description_ar' => 'أكمل 20 محتوى في الفيزياء',
                'icon' => 'atom',
                'badge_color' => '#8B5CF6',
                'criteria_type' => 'SubjectMastery',
                'criteria_value' => json_encode(['subject' => 'physics', 'count' => 20]),
                'points' => 100
            ],
            [
                'name_ar' => 'مستكشف الطبيعة',
                'description_ar' => 'أكمل 20 محتوى في علوم الطبيعة والحياة',
                'icon' => 'leaf',
                'badge_color' => '#10B981',
                'criteria_type' => 'SubjectMastery',
                'criteria_value' => json_encode(['subject' => 'biology', 'count' => 20]),
                'points' => 100
            ],
            [
                'name_ar' => 'أديب اللغة',
                'description_ar' => 'أكمل 20 محتوى في اللغة العربية',
                'icon' => 'book',
                'badge_color' => '#EF4444',
                'criteria_type' => 'SubjectMastery',
                'criteria_value' => json_encode(['subject' => 'arabic', 'count' => 20]),
                'points' => 100
            ],
            [
                'name_ar' => 'فيلسوف الفكر',
                'description_ar' => 'أكمل 15 محتوى في الفلسفة',
                'icon' => 'brain',
                'badge_color' => '#6366F1',
                'criteria_type' => 'SubjectMastery',
                'criteria_value' => json_encode(['subject' => 'philosophy', 'count' => 15]),
                'points' => 75
            ],

            // إنجازات المراجعة (Revision)
            [
                'name_ar' => 'المراجع الدؤوب',
                'description_ar' => 'راجع نفس المحتوى 3 مرات',
                'icon' => 'refresh-cw',
                'badge_color' => '#06B6D4',
                'criteria_type' => 'ContentRevision',
                'criteria_value' => json_encode(['revisions' => 3]),
                'points' => 50
            ],
            [
                'name_ar' => 'المحترف',
                'description_ar' => 'أكمل 100 محتوى في أي مادة',
                'icon' => 'shield',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'TotalContent',
                'criteria_value' => json_encode(['count' => 100]),
                'points' => 300
            ],

            // إنجازات التقدم (Progress-based)
            [
                'name_ar' => 'المبتدئ المتميز',
                'description_ar' => 'أكمل 25% من محتوى مادة',
                'icon' => 'pie-chart',
                'badge_color' => '#84CC16',
                'criteria_type' => 'SubjectProgress',
                'criteria_value' => json_encode(['percentage' => 25]),
                'points' => 50
            ],
            [
                'name_ar' => 'في منتصف الطريق',
                'description_ar' => 'أكمل 50% من محتوى مادة',
                'icon' => 'bar-chart',
                'badge_color' => '#F59E0B',
                'criteria_type' => 'SubjectProgress',
                'criteria_value' => json_encode(['percentage' => 50]),
                'points' => 100
            ],
            [
                'name_ar' => 'على وشك الإتمام',
                'description_ar' => 'أكمل 75% من محتوى مادة',
                'icon' => 'trending-up',
                'badge_color' => '#EC4899',
                'criteria_type' => 'SubjectProgress',
                'criteria_value' => json_encode(['percentage' => 75]),
                'points' => 150
            ],
            [
                'name_ar' => 'متقن المادة',
                'description_ar' => 'أكمل 100% من محتوى مادة',
                'icon' => 'award',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'SubjectProgress',
                'criteria_value' => json_encode(['percentage' => 100]),
                'points' => 250
            ],

            // إنجازات السرعة (Speed-based)
            [
                'name_ar' => 'السريع',
                'description_ar' => 'أكمل 5 دروس في يوم واحد',
                'icon' => 'zap',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'DailyContentCount',
                'criteria_value' => json_encode(['count' => 5]),
                'points' => 75
            ],
            [
                'name_ar' => 'العاصفة',
                'description_ar' => 'أكمل 10 دروس في يوم واحد',
                'icon' => 'wind',
                'badge_color' => '#06B6D4',
                'criteria_type' => 'DailyContentCount',
                'criteria_value' => json_encode(['count' => 10]),
                'points' => 150
            ],

            // إنجازات الصباح الباكر والليل (Time of day)
            [
                'name_ar' => 'الطائر المبكر',
                'description_ar' => 'أكمل جلسة دراسية قبل الساعة 7 صباحا',
                'icon' => 'sunrise',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'EarlyBird',
                'criteria_value' => json_encode(['hour' => 7]),
                'points' => 50
            ],
            [
                'name_ar' => 'البومة الليلية',
                'description_ar' => 'أكمل جلسة دراسية بعد الساعة 10 مساء',
                'icon' => 'moon',
                'badge_color' => '#6366F1',
                'criteria_type' => 'NightOwl',
                'criteria_value' => json_encode(['hour' => 22]),
                'points' => 50
            ],

            // إنجازات التحدي (Challenge-based)
            [
                'name_ar' => 'المتحدي',
                'description_ar' => 'ادرس 7 أيام متتالية',
                'icon' => 'flame',
                'badge_color' => '#EF4444',
                'criteria_type' => 'ConsecutiveDays',
                'criteria_value' => json_encode(['days' => 7]),
                'points' => 100
            ],
            [
                'name_ar' => 'المثابرة الأسطورية',
                'description_ar' => 'ادرس 30 يوما متتاليا',
                'icon' => 'fire',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'ConsecutiveDays',
                'criteria_value' => json_encode(['days' => 30]),
                'points' => 500
            ],

            // إنجازات التفوق (Excellence)
            [
                'name_ar' => 'المتفوق',
                'description_ar' => 'احصل على معدل أكثر من 90% في 10 اختبارات',
                'icon' => 'star',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'HighAverageScore',
                'criteria_value' => json_encode(['score' => 90, 'count' => 10]),
                'points' => 200
            ],
            [
                'name_ar' => 'الأول في الفصل',
                'description_ar' => 'احصل على أعلى درجة في 5 اختبارات متتالية',
                'icon' => 'medal',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'TopScore',
                'criteria_value' => json_encode(['count' => 5]),
                'points' => 300
            ],

            // إنجازات المشاركة (Engagement)
            [
                'name_ar' => 'المستكشف',
                'description_ar' => 'جرب 5 أنواع مختلفة من المحتوى',
                'icon' => 'compass',
                'badge_color' => '#84CC16',
                'criteria_type' => 'ContentTypeVariety',
                'criteria_value' => json_encode(['types' => 5]),
                'points' => 50
            ],
            [
                'name_ar' => 'المتنوع',
                'description_ar' => 'ادرس في 3 مواد مختلفة في يوم واحد',
                'icon' => 'grid',
                'badge_color' => '#14B8A6',
                'criteria_type' => 'SubjectVariety',
                'criteria_value' => json_encode(['subjects' => 3]),
                'points' => 75
            ],

            // إنجازات خاصة (Special)
            [
                'name_ar' => 'عضو مؤسس',
                'description_ar' => 'انضم إلى المنصة في الشهر الأول',
                'icon' => 'users',
                'badge_color' => '#6366F1',
                'criteria_type' => 'FoundingMember',
                'criteria_value' => json_encode([]),
                'points' => 100
            ],
            [
                'name_ar' => 'مستخدم نشط',
                'description_ar' => 'استخدم المنصة لمدة 90 يوما',
                'icon' => 'activity',
                'badge_color' => '#8B5CF6',
                'criteria_type' => 'ActiveUser',
                'criteria_value' => json_encode(['days' => 90]),
                'points' => 200
            ],
            [
                'name_ar' => 'المخضرم',
                'description_ar' => 'استخدم المنصة لمدة 180 يوما',
                'icon' => 'shield',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'ActiveUser',
                'criteria_value' => json_encode(['days' => 180]),
                'points' => 400
            ],

            // إنجازات نهائية (Ultimate)
            [
                'name_ar' => 'أسطورة الدراسة',
                'description_ar' => 'اجمع 5000 نقطة',
                'icon' => 'crown',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'TotalPoints',
                'criteria_value' => json_encode(['points' => 5000]),
                'points' => 1000
            ],
            [
                'name_ar' => 'المتفوق الأكاديمي',
                'description_ar' => 'أتقن جميع المواد الأساسية',
                'icon' => 'graduation-cap',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'AllCoreSubjects',
                'criteria_value' => json_encode([]),
                'points' => 1000
            ],
            [
                'name_ar' => 'ملك البكالوريا',
                'description_ar' => 'أكمل 50 محاكاة بكالوريا بمعدل فوق 15',
                'icon' => 'crown',
                'badge_color' => '#FCD34D',
                'criteria_type' => 'BacKing',
                'criteria_value' => json_encode(['count' => 50, 'score' => 15]),
                'points' => 2000
            ],
        ];

        foreach ($achievements as $achievement) {
            $achievement['created_at'] = now();
            $achievement['updated_at'] = now();
            DB::table('achievements')->insert($achievement);
        }

        $this->command->info('Achievements seeded successfully!');
        $this->command->info('- ' . count($achievements) . ' achievements created');
        $this->command->info('- Total possible points: ' . array_sum(array_column($achievements, 'points')));
    }
}
