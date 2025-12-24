<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SubjectPlannerContent;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Models\Subject;
use Illuminate\Support\Facades\DB;

class SubjectPlannerContentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * This seeder populates the curriculum content based on the actual curriculum images.
     * Data is organized hierarchically: Learning Axis → Unit → Topic → Subtopic → Learning Objective
     */
    public function run(): void
    {
        // Clear existing data
        try {
            DB::statement('SET FOREIGN_KEY_CHECKS=0;');
            SubjectPlannerContent::truncate();
            DB::statement('SET FOREIGN_KEY_CHECKS=1;');
        } catch (\Exception $e) {
            $this->command->warn('Could not truncate table: ' . $e->getMessage());
        }

        // Get academic structure IDs
        $secondaryPhase = AcademicPhase::where('slug', 'secondary')->first();

        if (!$secondaryPhase) {
            $this->command->error('Secondary phase not found. Please run AcademicStructureSeeder first.');
            return;
        }

        $thirdYear = AcademicYear::where('level_number', 3)->where('academic_phase_id', $secondaryPhase->id)->first();

        if (!$thirdYear) {
            $this->command->warn('Third year not found. Using first available year.');
            $thirdYear = AcademicYear::where('academic_phase_id', $secondaryPhase->id)->first();
        }

        // Get streams - BAC year streams
        $sciencesStream = AcademicStream::where('slug', 'sciences-exp')->first();
        $mathStream = AcademicStream::where('slug', 'mathematics')->first();

        // Get subjects for Sciences stream
        $mathSubject = Subject::where('slug', 'sciences-exp-mathematics')->first()
            ?? Subject::where('slug', 'mathematics-mathematics')->first();
        $physicsSubject = Subject::where('slug', 'sciences-exp-physics')->first();
        $naturalSciencesSubject = Subject::where('slug', 'sciences-exp-biology')->first();
        $islamicSubject = Subject::where('slug', 'sciences-exp-islamic')->first();
        $historySubject = Subject::where('slug', 'sciences-exp-history-geo')->first();

        // Seed Mathematics (الرياضيات) - From image 3.jpg
        if ($mathSubject) {
            $this->seedMathematics($secondaryPhase->id, $thirdYear->id, $mathStream?->id, $mathSubject->id);
        }

        // Seed Physical Sciences (العلوم الفيزيائية) - From images 4.jpg and 6.jpg
        if ($physicsSubject) {
            $this->seedPhysicalSciences($secondaryPhase->id, $thirdYear->id, $sciencesStream?->id, $physicsSubject->id);
        }

        // Seed Natural Sciences and Life (علوم الطبيعة و الحياة) - From images 5.jpg, 7.jpg, and 8.jpg
        if ($naturalSciencesSubject) {
            $this->seedNaturalSciences($secondaryPhase->id, $thirdYear->id, $sciencesStream?->id, $naturalSciencesSubject->id);
        }

        // Seed Islamic Sciences (العلوم الإسلامية) - From images 9.jpg and islamique.jpg
        if ($islamicSubject) {
            $this->seedIslamicSciences($secondaryPhase->id, $thirdYear->id, null, $islamicSubject->id);
        }

        // Seed History and Geography (التاريخ و الجغرافيا) - From image 9.jpg
        if ($historySubject) {
            $this->seedHistoryGeography($secondaryPhase->id, $thirdYear->id, null, $historySubject->id);
        }

        $this->command->info('Subject planner content seeded successfully!');
    }

    /**
     * Seed Social Studies curriculum (الاجتماعيات) - From image 2.jpg
     * Note: Commented out - subject mapping needs to be verified
     */
    private function seedSocialStudies($phaseId, $yearId, $streamId, $subjectId): void
    {
        return; // Temporarily disabled
        // الوحدة الأولى
        $unit1 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'unit',
            'code' => 'U1',
            'title_ar' => 'الوحدة الأولى',
            'order' => 1,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        $topics = [
            'بروز الصراع وتشكل العالم',
            'معايير تشكل العالم',
            'طبيعة العلاقات بين الكتلتين',
            'الاستراتيجيات الخاصة بكل كتلة',
            'مساعي الانفراج الدولي',
            'عوامل الجنوح إلى السلم',
            'الظروف الدولية السائدة',
            'من الثنائية إلى الأحادية القطبية',
            'تفكك الكتلة الشرقية وسياسة التطويق',
            'من الثنائية إلى الأحادية القطبية',
            'ملامح النظام الدولي الجديد و مؤسساته',
        ];

        foreach ($topics as $index => $topicTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $unit1->id,
                'level' => 'topic',
                'title_ar' => $topicTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 45,
                'is_active' => true,
                'is_published' => true,
            ]);
        }

        // الوحدة الثانية
        $unit2 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'unit',
            'code' => 'U2',
            'title_ar' => 'الوحدة الثانية',
            'order' => 2,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        $unit2Topics = [
            'العمل المسلح ورد فعل الاستعمار',
            'إستراتيجية الثورة على المستوى الداخلي',
            'إستراتيجية الثورة على المستوى الخارجي',
            'رد فعل واستراتيجية الاستعمار',
            'استعادة السيادة الوطنية وبناء الدولة الجزائرية',
            'ظروف قيام الدولة الجزائرية',
            'الاختيارات الكبرى لإعادة بناء الدولة الجزائرية',
        ];

        foreach ($unit2Topics as $index => $topicTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $unit2->id,
                'level' => 'topic',
                'title_ar' => $topicTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 45,
                'is_active' => true,
                'is_published' => true,
            ]);
        }
    }

    /**
     * Seed Mathematics curriculum (الرياضيات) - From image 3.jpg
     */
    private function seedMathematics($phaseId, $yearId, $streamId, $subjectId): void
    {
        // المحور الأول: الدوال العددية
        $axis1 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA1',
            'title_ar' => 'المحور الأول: الدوال العددية',
            'order' => 1,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        // المحور الثاني: المتتاليات
        $axis2 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA2',
            'title_ar' => 'المحور الثاني: المتتاليات',
            'order' => 2,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        // المحور الثالث: الدوال الأصلية
        $axis3 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA3',
            'title_ar' => 'المحور الثالث: الدوال الأصلية',
            'order' => 3,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        // المحور الرابع: الاحتماليات
        $axis4 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA4',
            'title_ar' => 'المحور الرابع: الاحتماليات',
            'order' => 4,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        // المحور الخامس: الأعداد المركبة
        $axis5 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA5',
            'title_ar' => 'المحور الخامس: الأعداد المركبة',
            'order' => 5,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);
    }

    /**
     * Seed Physical Sciences curriculum (العلوم الفيزيائية) - From images 4.jpg and 6.jpg
     */
    private function seedPhysicalSciences($phaseId, $yearId, $streamId, $subjectId): void
    {
        // الوحدة الأولى: المتابعة الزمنية لتحول كيميائي
        $unit1 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'unit',
            'code' => 'U1',
            'title_ar' => 'الوحدة الأولى: المتابعة الزمنية لتحول كيميائي',
            'order' => 1,
            'content_type' => 'theory',
            'requires_theory_practice' => true,
            'requires_exercise_practice' => true,
            'is_active' => true,
            'is_published' => true,
            'is_bac_priority' => true,
            'bac_frequency' => 5,
        ]);

        // الوحدة الثانية: نطور جملة ميكانيكية
        $unit2 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'unit',
            'code' => 'U2',
            'title_ar' => 'الوحدة الثانية: تطور جملة ميكانيكية',
            'order' => 2,
            'content_type' => 'theory',
            'requires_theory_practice' => true,
            'requires_exercise_practice' => true,
            'is_active' => true,
            'is_published' => true,
            'is_bac_priority' => true,
            'bac_frequency' => 7,
        ]);

        $unit2Topics = [
            'المناعة الرزمية',
            'قياس التقلقلية',
            'حجم و ضغط غاز',
            'الكواكب و الأقمار',
            'دراسة تطور جملة ميكانيكية',
            'السقوط الشاقولي',
            'الحركة',
        ];

        foreach ($unit2Topics as $index => $topicTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $unit2->id,
                'level' => 'topic',
                'title_ar' => $topicTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 60,
                'requires_theory_practice' => true,
                'requires_exercise_practice' => true,
                'is_active' => true,
                'is_published' => true,
            ]);
        }

        // Additional units from detailed table (image 6.jpg)
        $units = [
            ['title' => 'المناعة الرزمية لتحول كيميائي وسط مائي', 'order' => 3],
            ['title' => 'قياس التقلقلية', 'order' => 4],
            ['title' => 'حجم و ضغط غاز', 'order' => 5],
            ['title' => 'الكواكب و الأقمار', 'order' => 6],
            ['title' => 'دراسة تطور جملة ميكانيكية', 'order' => 7],
            ['title' => 'السقوط الشاقولي', 'order' => 8],
            ['title' => 'الحركة', 'order' => 9],
            ['title' => 'المستوى المائل و الأفقي', 'order' => 10],
            ['title' => 'دراسة ظواهر كهربائية', 'order' => 11],
            ['title' => 'الدارة RC', 'order' => 12],
            ['title' => 'الدارة RL', 'order' => 13],
            ['title' => 'تطور و كيميائية نحو حالة التوازن', 'order' => 14],
            ['title' => 'التحولات النووية', 'order' => 15],
            ['title' => 'مراقبة تطور ج كيميائية', 'order' => 16],
            ['title' => 'التطورات المهتزة', 'order' => 17],
            ['title' => 'مفهوم الموجة', 'order' => 18],
        ];

        foreach ($units as $unitData) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'level' => 'unit',
                'code' => 'U' . $unitData['order'],
                'title_ar' => $unitData['title'],
                'order' => $unitData['order'],
                'content_type' => 'theory',
                'difficulty_level' => 'hard',
                'requires_theory_practice' => true,
                'requires_exercise_practice' => true,
                'is_active' => true,
                'is_published' => true,
                'is_bac_priority' => true,
                'bac_frequency' => rand(3, 8),
            ]);
        }
    }

    /**
     * Seed Natural Sciences curriculum (علوم الطبيعة و الحياة) - From images 5.jpg, 7.jpg, and 8.jpg
     */
    private function seedNaturalSciences($phaseId, $yearId, $streamId, $subjectId): void
    {
        // المجال التعلمي الأول: التخصص الوظيفي للبروتين
        $axis1 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA1',
            'title_ar' => 'المجال التعلمي الأول: التخصص الوظيفي للبروتين',
            'order' => 1,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        $axis1Units = [
            'الوحدة الأولى: آليات تركيب البروتين',
            'الوحدة الثانية: العلاقة بين بنية ووظيفة البروتين',
            'الوحدة الثالثة: دور البروتينات في التخبر الانزيمي',
            'الوحدة الرابعة: دور البروتينات في الدفاع عن الذات',
            'الوحدة الخامسة: دور البروتينات في الإتصال العصبي',
        ];

        foreach ($axis1Units as $index => $unitTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $axis1->id,
                'level' => 'unit',
                'code' => 'LA1.U' . ($index + 1),
                'title_ar' => $unitTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 90,
                'is_active' => true,
                'is_published' => true,
            ]);
        }

        // المجال التعلمي الثاني: التخصص الوظيفي للبروتين
        $axis2 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA2',
            'title_ar' => 'المجال التعلمي الثاني: التخصص الوظيفي للبروتين',
            'order' => 2,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        $axis2Units = [
            'الوحدة الأولى: آليات تحويل الطاقة الضوئية إلى طاقة كيميائية كامنة',
            'الوحدة الثانية: آليات تحويل الطاقة الكيميائية الكامنة في الجزيئات العضوية إلى طاقة قابلة للإستعمال ATP',
            'الوحدة الثالثة: حوصلة التحولات الطاقوية على المستوى الخلوي',
        ];

        foreach ($axis2Units as $index => $unitTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $axis2->id,
                'level' => 'unit',
                'code' => 'LA2.U' . ($index + 1),
                'title_ar' => $unitTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 90,
                'is_active' => true,
                'is_published' => true,
            ]);
        }

        // المجال التعلمي الثالث: الذكتونية العامة
        $axis3 = SubjectPlannerContent::create([
            'academic_phase_id' => $phaseId,
            'academic_year_id' => $yearId,
            'academic_stream_id' => $streamId,
            'subject_id' => $subjectId,
            'level' => 'learning_axis',
            'code' => 'LA3',
            'title_ar' => 'المجال التعلمي الثالث: الذكتونية العامة',
            'order' => 3,
            'content_type' => 'theory',
            'is_active' => true,
            'is_published' => true,
        ]);

        $axis3Units = [
            'الوحدة الأولى: بنية الكرة الأرضية',
            'الوحدة الثانية: النشاط التكتوني والظواهر الجيولوجية المرتبطة به',
        ];

        foreach ($axis3Units as $index => $unitTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'parent_id' => $axis3->id,
                'level' => 'unit',
                'code' => 'LA3.U' . ($index + 1),
                'title_ar' => $unitTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 75,
                'is_active' => true,
                'is_published' => true,
            ]);
        }

        // Add detailed topics from image 8.jpg
        $detailedTopics = [
            ['parent' => 'LA1', 'title' => 'الإستنساخ', 'type' => 'تركيب البروتين'],
            ['parent' => 'LA1', 'title' => 'الترجمة', 'type' => 'تركيب البروتين'],
            ['parent' => 'LA1', 'title' => 'الأحماض الأمنية', 'type' => 'العلاقة بين بنية و وظيفة البروتين'],
            ['parent' => 'LA1', 'title' => 'سلوك الأحماض الأمينية', 'type' => 'العلاقة بين بنية و وظيفة البروتين'],
            ['parent' => 'LA1', 'title' => 'مستويات البنية الفراغية', 'type' => 'العلاقة بين بنية و وظيفة البروتين'],
        ];

        // We'll add these as subtopics to the relevant units
    }

    /**
     * Seed Islamic Sciences curriculum (العلوم الإسلامية) - From images 9.jpg and islamique.jpg
     */
    private function seedIslamicSciences($phaseId, $yearId, $streamId, $subjectId): void
    {
        $topics = [
            'العقيدة الإسلامية و أثرها على الفرد و المجتمع',
            'وسائل القرآن في تثبيت العقيدة الإسلامية',
            'الإسلام و الرسالات السماوية',
            'العقل في القرآن الكريم',
            'مقاصد الشريعة الإسلامية',
            'منهج الإسلام في محاربة الإنحراف و الجريمة',
            'المساواة أمام أحكام الشريعة الإسلامية في العقوبات',
            'الصحة النفسية و الجسمية في القرآن الكريم',
            'من مصادر التشريع الإسلامي: الإجماع، القياس، المصلحة المرسلة',
            'القيم في القرآن الكريم',
            'الوقف في الإسلام',
            'من أحكام الأسرة في الإسلام: مدخل إلى علم الميراث',
            'الربا و أحكامه',
            'من المعاملات المالية الجائزة: بيع العرف، المراببحة، التقسيط',
            'الحرية الشخصية و مدى ارتباطها بحرية الأخرين',
            'من أحكام الأسرة في الإسلام: النسب، التبني، الكفالة',
            'العلاقات الاجتماعية بين المسلمين و غيرهم',
            'خطبة الرسول ﷺ في حجة الوداع',
        ];

        foreach ($topics as $index => $topicTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'level' => 'topic',
                'code' => 'T' . ($index + 1),
                'title_ar' => $topicTitle,
                'order' => $index + 1,
                'content_type' => 'memorization',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 45,
                'requires_understanding' => true,
                'requires_review' => true,
                'is_active' => true,
                'is_published' => true,
            ]);
        }
    }

    /**
     * Seed History and Geography curriculum (التاريخ و الجغرافيا) - From image 9.jpg
     */
    private function seedHistoryGeography($phaseId, $yearId, $streamId, $subjectId): void
    {
        // History topics (الدروس المقررة - التاريخ)
        $historyTopics = [
            'بروز الصراع و تشكل العالم',
            'مساعي الإنفراج الدولي',
            'من الثنائية إلى الأحادية القطبية',
            'العمل المسلح و رد فعل الاستعمار',
            'استعادة السيادة الوطنية و بناء الدولة الجزائرية',
            'ظروف قيام الدولة الجزائرية',
            'العالم الثالث بين تراجع الاستعمار التقليدي و استمرار حركات التحرر',
            'فلسطين و من تصفية الاستعمار التقليدي و استمرارية التحرر',
            'إشكالية التقدم و التخلف',
            'الميادين و الثقافات في العالم',
            'مصادر القوة الأمريكية و تأثيرها على الإقتصاد العالمي',
            'ظاهرة التكتل و أثرها في قوة الإتحاد الأوروبي',
            'العلاقة بين السكان و التنمية في شرق و جنوب شرق آسيا',
            'الإقتصاد الجزائري في العالم',
            'التنمية في البرازيل',
        ];

        foreach ($historyTopics as $index => $topicTitle) {
            SubjectPlannerContent::create([
                'academic_phase_id' => $phaseId,
                'academic_year_id' => $yearId,
                'academic_stream_id' => $streamId,
                'subject_id' => $subjectId,
                'level' => 'topic',
                'code' => 'H' . ($index + 1),
                'title_ar' => $topicTitle,
                'order' => $index + 1,
                'content_type' => 'theory',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 45,
                'is_active' => true,
                'is_published' => true,
            ]);
        }
    }
}
