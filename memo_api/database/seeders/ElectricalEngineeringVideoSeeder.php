<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Subject;
use App\Models\Content;
use App\Models\ContentType;
use App\Models\ContentChapter;
use Illuminate\Support\Str;

class ElectricalEngineeringVideoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Adds fake video lessons for الهندسة الكهربائية subject
     */
    public function run(): void
    {
        // Find the subject "الهندسة الكهربائية"
        $subject = Subject::where('name_ar', 'الهندسة الكهربائية')->first();

        if (!$subject) {
            $this->command->error('Subject "الهندسة الكهربائية" not found!');
            return;
        }

        // Find content type for video lessons (درس or فيديو شرح)
        $videoContentType = ContentType::where('slug', 'lesson')->first();

        if (!$videoContentType) {
            $videoContentType = ContentType::where('slug', 'video')->first();
        }

        if (!$videoContentType) {
            $videoContentType = ContentType::where('name_ar', 'درس')->first();
        }

        if (!$videoContentType) {
            $this->command->error('Content type for lessons not found! Please run ContentTypesSeeder first.');
            return;
        }

        $this->command->info("Using content type: {$videoContentType->name_ar} (ID: {$videoContentType->id})");

        // Find or create a chapter for the subject
        $chapter = ContentChapter::where('subject_id', $subject->id)->first();

        if (!$chapter) {
            $chapter = ContentChapter::create([
                'subject_id' => $subject->id,
                'name_ar' => 'الدارات الكهربائية',
                'slug' => 'electrical-circuits',
                'description_ar' => 'فصل الدارات الكهربائية الأساسية',
                'order' => 1,
                'is_published' => true,
            ]);
        }

        // Sample YouTube videos for electrical engineering lessons
        $lessons = [
            [
                'title_ar' => 'مقدمة في الدارات الكهربائية',
                'description_ar' => 'درس تمهيدي حول أساسيات الدارات الكهربائية والمكونات الأساسية مثل المقاومات والمكثفات والملفات',
                'video_url' => 'https://www.youtube.com/watch?v=mc979OhitAg',
                'video_duration_seconds' => 1245, // ~20 min
                'difficulty_level' => 'easy',
                'estimated_duration_minutes' => 25,
            ],
            [
                'title_ar' => 'قانون أوم وتطبيقاته',
                'description_ar' => 'شرح مفصل لقانون أوم والعلاقة بين التيار والجهد والمقاومة مع تمارين تطبيقية',
                'video_url' => 'https://www.youtube.com/watch?v=HsLLq6Rm5tU',
                'video_duration_seconds' => 1520, // ~25 min
                'difficulty_level' => 'easy',
                'estimated_duration_minutes' => 30,
            ],
            [
                'title_ar' => 'قوانين كيرشوف للتيار والجهد',
                'description_ar' => 'دراسة قانون كيرشوف الأول (قانون التيار) وقانون كيرشوف الثاني (قانون الجهد) مع أمثلة محلولة',
                'video_url' => 'https://www.youtube.com/watch?v=76OrWqY7JRk',
                'video_duration_seconds' => 1890, // ~31 min
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 35,
            ],
            [
                'title_ar' => 'تحليل الدارات بطريقة العقد',
                'description_ar' => 'طريقة تحليل الدارات الكهربائية باستخدام معادلات العقد وحساب الجهود في النقاط المختلفة',
                'video_url' => 'https://www.youtube.com/watch?v=AbYxIeHvp0Y',
                'video_duration_seconds' => 2100, // ~35 min
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 40,
            ],
            [
                'title_ar' => 'تحليل الدارات بطريقة الحلقات',
                'description_ar' => 'شرح طريقة الحلقات (Mesh Analysis) لتحليل الدارات الكهربائية المعقدة',
                'video_url' => 'https://www.youtube.com/watch?v=9pqT3LlRX9w',
                'video_duration_seconds' => 1980, // ~33 min
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 38,
            ],
            [
                'title_ar' => 'نظرية ثيفنن ونورتن',
                'description_ar' => 'تبسيط الدارات الكهربائية باستخدام نظرية ثيفنن ونظرية نورتن مع تطبيقات عملية',
                'video_url' => 'https://www.youtube.com/watch?v=Q4zTLvAg1eY',
                'video_duration_seconds' => 2250, // ~37 min
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 45,
            ],
            [
                'title_ar' => 'المكثفات وخصائصها',
                'description_ar' => 'دراسة المكثفات الكهربائية وطرق توصيلها على التوالي والتوازي وحساب السعة الكلية',
                'video_url' => 'https://www.youtube.com/watch?v=X4EUwTwZ110',
                'video_duration_seconds' => 1650, // ~27 min
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 32,
            ],
            [
                'title_ar' => 'الملفات والحث الكهرومغناطيسي',
                'description_ar' => 'شرح الملفات الكهربائية والحث الذاتي والحث المتبادل مع تطبيقات في المحولات',
                'video_url' => 'https://www.youtube.com/watch?v=NnlAI4ZiUrQ',
                'video_duration_seconds' => 1800, // ~30 min
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 35,
            ],
            [
                'title_ar' => 'دارات التيار المتناوب RC',
                'description_ar' => 'تحليل دارات التيار المتناوب التي تحتوي على مقاومات ومكثفات وحساب الممانعة',
                'video_url' => 'https://www.youtube.com/watch?v=kYHoJPdPj0A',
                'video_duration_seconds' => 2050, // ~34 min
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 40,
            ],
            [
                'title_ar' => 'دارات التيار المتناوب RLC',
                'description_ar' => 'دراسة شاملة لدارات RLC والرنين الكهربائي وتطبيقاته في الفلاتر والدوائر الإلكترونية',
                'video_url' => 'https://www.youtube.com/watch?v=hQaVBVUdPsg',
                'video_duration_seconds' => 2400, // ~40 min
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 50,
            ],
        ];

        $order = 1;
        foreach ($lessons as $lessonData) {
            // Check if content already exists
            $exists = Content::where('subject_id', $subject->id)
                ->where('title_ar', $lessonData['title_ar'])
                ->exists();

            if (!$exists) {
                Content::create([
                    'subject_id' => $subject->id,
                    'content_type_id' => $videoContentType->id,
                    'chapter_id' => $chapter->id,
                    'title_ar' => $lessonData['title_ar'],
                    'slug' => Str::slug($lessonData['title_ar'], '-'),
                    'description_ar' => $lessonData['description_ar'],
                    'difficulty_level' => $lessonData['difficulty_level'],
                    'estimated_duration_minutes' => $lessonData['estimated_duration_minutes'],
                    'order' => $order,
                    'has_video' => true,
                    'video_type' => 'youtube',
                    'video_url' => $lessonData['video_url'],
                    'video_duration_seconds' => $lessonData['video_duration_seconds'],
                    'is_published' => true,
                    'published_at' => now(),
                    'is_premium' => false,
                    'views_count' => rand(50, 500),
                    'downloads_count' => rand(10, 100),
                ]);

                $order++;
                $this->command->info("Created lesson: {$lessonData['title_ar']}");
            } else {
                $this->command->warn("Lesson already exists: {$lessonData['title_ar']}");
            }
        }

        $this->command->info("Successfully seeded " . ($order - 1) . " video lessons for الهندسة الكهربائية!");
    }
}
