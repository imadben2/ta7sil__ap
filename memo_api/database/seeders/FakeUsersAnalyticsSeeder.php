<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\UserStats;
use App\Models\UserActivityLog;
use App\Models\UserAcademicProfile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class FakeUsersAnalyticsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create 50 fake users with analytics data
        $academicYears = \App\Models\AcademicYear::all();
        $academicStreams = \App\Models\AcademicStream::all();

        if ($academicYears->isEmpty()) {
            $this->command->error('No academic years found. Please run AcademicStructureSeeder first.');
            return;
        }

        // Remove existing fake users first
        $existingFakeUsers = User::where('email', 'LIKE', 'student%@example.com')->get();
        if ($existingFakeUsers->isNotEmpty()) {
            $this->command->info('Removing ' . $existingFakeUsers->count() . ' existing fake users...');
            foreach ($existingFakeUsers as $fakeUser) {
                $fakeUser->stats()->delete();
                $fakeUser->academicProfile()->delete();
                $fakeUser->activityLogs()->delete();
                $fakeUser->delete();
            }
        }

        $this->command->info('Creating 50 fake users with analytics data...');

        for ($i = 1; $i <= 50; $i++) {
            // Create user
            $user = User::create([
                'name' => $this->generateArabicName(),
                'email' => "student{$i}@example.com",
                'password' => Hash::make('password'),
                'role' => 'student',
                'is_active' => rand(0, 10) > 1, // 90% active
                'email_verified_at' => now()->subDays(rand(1, 365)),
                'created_at' => now()->subDays(rand(1, 365)),
            ]);

            // Create academic profile
            $academicYear = $academicYears->random();
            UserAcademicProfile::create([
                'user_id' => $user->id,
                'academic_phase_id' => $academicYear->academic_phase_id,
                'academic_year_id' => $academicYear->id,
                'academic_stream_id' => $academicStreams->isNotEmpty() ? $academicStreams->random()->id : null,
            ]);

            // Create user stats
            $totalMinutes = rand(0, 10000);
            $currentStreak = rand(0, 120);
            $longestStreak = max($currentStreak, rand(0, 200));
            $level = min(10, floor($totalMinutes / 600) + 1);
            $points = $totalMinutes * 10 + $currentStreak * 50;

            UserStats::create([
                'user_id' => $user->id,
                'total_study_minutes' => $totalMinutes,
                'total_sessions' => rand(0, 500),
                'total_sessions_completed' => rand(0, 450),
                'total_contents_completed' => rand(0, 200),
                'total_quizzes_completed' => rand(0, 150),
                'total_quizzes_taken' => rand(0, 200),
                'total_quizzes_passed' => rand(0, 150),
                'average_quiz_score' => rand(40, 100),
                'total_simulations_completed' => rand(0, 50),
                'total_content_viewed' => rand(0, 300),
                'average_daily_study_minutes' => rand(0, 180),
                'current_week_minutes' => rand(0, 1200),
                'current_month_minutes' => rand(0, 5000),
                'current_streak_days' => $currentStreak,
                'longest_streak_days' => $longestStreak,
                'last_study_date' => rand(0, 10) > 3 ? now()->subDays(rand(0, 7)) : now()->subDays(rand(8, 60)),
                'level' => $level,
                'experience_points' => $points,
                'gamification_points' => $points,
                'total_achievements_unlocked' => rand(0, 30),
            ]);

            // Create activity logs (last 30 days)
            $activityTypes = [
                UserActivityLog::TYPE_LOGIN,
                UserActivityLog::TYPE_STUDY_SESSION_START,
                UserActivityLog::TYPE_STUDY_SESSION_END,
                UserActivityLog::TYPE_QUIZ_ATTEMPT,
                UserActivityLog::TYPE_QUIZ_COMPLETE,
                UserActivityLog::TYPE_CONTENT_VIEW,
                UserActivityLog::TYPE_CONTENT_DOWNLOAD,
            ];

            $numActivities = rand(5, 50);
            for ($j = 0; $j < $numActivities; $j++) {
                UserActivityLog::create([
                    'user_id' => $user->id,
                    'activity_type' => $activityTypes[array_rand($activityTypes)],
                    'activity_description' => 'Fake activity for seeding',
                    'metadata' => null,
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Mozilla/5.0 (Seeder)',
                    'created_at' => now()->subDays(rand(0, 30))->subHours(rand(0, 23)),
                ]);
            }

            if ($i % 10 == 0) {
                $this->command->info("Created {$i} users...");
            }
        }

        $this->command->info('✅ Successfully created 50 fake users with analytics data!');
    }

    /**
     * Generate random Arabic names.
     */
    private function generateArabicName(): string
    {
        $firstNames = [
            'محمد', 'أحمد', 'علي', 'حسن', 'حسين', 'عبد الله', 'عمر', 'خالد', 'يوسف', 'إبراهيم',
            'فاطمة', 'عائشة', 'خديجة', 'مريم', 'زينب', 'سارة', 'نور', 'ياسمين', 'هدى', 'أمل',
            'كريم', 'رضا', 'سعيد', 'طارق', 'وليد', 'سمير', 'نبيل', 'رشيد', 'فريد', 'عادل',
            'ليلى', 'سلمى', 'نادية', 'هالة', 'سميرة', 'لبنى', 'رانيا', 'دينا', 'منى', 'سهام'
        ];

        $lastNames = [
            'بن علي', 'بن محمد', 'بن عبد الله', 'العربي', 'المغربي', 'التونسي', 'الجزائري',
            'بوعلام', 'بوزيد', 'بن عيسى', 'الحسني', 'السعيدي', 'الأمين', 'الكريم', 'المبارك',
            'الشريف', 'الطاهر', 'البشير', 'المنصور', 'العزيز', 'الرحمن', 'الحكيم', 'العليم',
            'بن عمر', 'بن يوسف', 'بن إبراهيم', 'الفاضل', 'النجار', 'الصالح', 'الحميد'
        ];

        return $firstNames[array_rand($firstNames)] . ' ' . $lastNames[array_rand($lastNames)];
    }
}
