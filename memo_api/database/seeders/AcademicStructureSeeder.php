<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AcademicStructureSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Academic Phases (الأطوار التعليمية)
        $phases = [
            ['name_ar' => 'الطور الابتدائي', 'slug' => 'primary', 'order' => 1],
            ['name_ar' => 'الطور المتوسط', 'slug' => 'middle', 'order' => 2],
            ['name_ar' => 'الطور الثانوي', 'slug' => 'secondary', 'order' => 3],
        ];

        foreach ($phases as $phase) {
            DB::table('academic_phases')->insert($phase);
        }

        // Get phase IDs
        $primaryPhaseId = DB::table('academic_phases')->where('slug', 'primary')->value('id');
        $middlePhaseId = DB::table('academic_phases')->where('slug', 'middle')->value('id');
        $secondaryPhaseId = DB::table('academic_phases')->where('slug', 'secondary')->value('id');

        // 2. Academic Years (السنوات الدراسية)
        $years = [
            // Primary
            ['academic_phase_id' => $primaryPhaseId, 'name_ar' => 'السنة الأولى ابتدائي', 'level_number' => 1, 'order' => 1],
            ['academic_phase_id' => $primaryPhaseId, 'name_ar' => 'السنة الثانية ابتدائي', 'level_number' => 2, 'order' => 2],
            ['academic_phase_id' => $primaryPhaseId, 'name_ar' => 'السنة الثالثة ابتدائي', 'level_number' => 3, 'order' => 3],
            ['academic_phase_id' => $primaryPhaseId, 'name_ar' => 'السنة الرابعة ابتدائي', 'level_number' => 4, 'order' => 4],
            ['academic_phase_id' => $primaryPhaseId, 'name_ar' => 'السنة الخامسة ابتدائي', 'level_number' => 5, 'order' => 5],

            // Middle
            ['academic_phase_id' => $middlePhaseId, 'name_ar' => 'السنة الأولى متوسط', 'level_number' => 1, 'order' => 1],
            ['academic_phase_id' => $middlePhaseId, 'name_ar' => 'السنة الثانية متوسط', 'level_number' => 2, 'order' => 2],
            ['academic_phase_id' => $middlePhaseId, 'name_ar' => 'السنة الثالثة متوسط', 'level_number' => 3, 'order' => 3],
            ['academic_phase_id' => $middlePhaseId, 'name_ar' => 'السنة الرابعة متوسط', 'level_number' => 4, 'order' => 4],

            // Secondary
            ['academic_phase_id' => $secondaryPhaseId, 'name_ar' => 'السنة الأولى ثانوي', 'level_number' => 1, 'order' => 1],
            ['academic_phase_id' => $secondaryPhaseId, 'name_ar' => 'السنة الثانية ثانوي', 'level_number' => 2, 'order' => 2],
            ['academic_phase_id' => $secondaryPhaseId, 'name_ar' => 'السنة الثالثة ثانوي', 'level_number' => 3, 'order' => 3],
        ];

        foreach ($years as $year) {
            DB::table('academic_years')->insert($year);
        }

        // Get year ID for BAC (3rd year secondary)
        $bacYearId = DB::table('academic_years')
            ->where('academic_phase_id', $secondaryPhaseId)
            ->where('level_number', 3)
            ->value('id');

        // 3. Academic Streams (الشعب) - For 3rd year secondary (BAC)
        $streams = [
            ['academic_year_id' => $bacYearId, 'name_ar' => 'علوم تجريبية', 'slug' => 'sciences-exp', 'description_ar' => 'شعبة العلوم التجريبية', 'order' => 1],
            ['academic_year_id' => $bacYearId, 'name_ar' => 'رياضيات', 'slug' => 'mathematics', 'description_ar' => 'شعبة الرياضيات', 'order' => 2],
            ['academic_year_id' => $bacYearId, 'name_ar' => 'تقني رياضي', 'slug' => 'tech-math', 'description_ar' => 'شعبة التقني الرياضي', 'order' => 3],
            ['academic_year_id' => $bacYearId, 'name_ar' => 'تسيير واقتصاد', 'slug' => 'management-economics', 'description_ar' => 'شعبة التسيير والاقتصاد', 'order' => 4],
            ['academic_year_id' => $bacYearId, 'name_ar' => 'آداب وفلسفة', 'slug' => 'literature-philosophy', 'description_ar' => 'شعبة الآداب والفلسفة', 'order' => 5],
            ['academic_year_id' => $bacYearId, 'name_ar' => 'لغات أجنبية', 'slug' => 'foreign-languages', 'description_ar' => 'شعبة اللغات الأجنبية', 'order' => 6],
        ];

        foreach ($streams as $stream) {
            DB::table('academic_streams')->insert($stream);
        }

        // Get stream IDs
        $streamIds = [
            'sciences-exp' => DB::table('academic_streams')->where('slug', 'sciences-exp')->value('id'),
            'mathematics' => DB::table('academic_streams')->where('slug', 'mathematics')->value('id'),
            'tech-math' => DB::table('academic_streams')->where('slug', 'tech-math')->value('id'),
            'management-economics' => DB::table('academic_streams')->where('slug', 'management-economics')->value('id'),
            'literature-philosophy' => DB::table('academic_streams')->where('slug', 'literature-philosophy')->value('id'),
            'foreign-languages' => DB::table('academic_streams')->where('slug', 'foreign-languages')->value('id'),
        ];

        // 4. Subjects with BAC Coefficients (المواد الدراسية حسب الشعبة)
        // Note: coefficient and academic_stream_id are in the subjects table directly

        $subjectOrder = 0;
        $subjects = [];

        // Sciences Expérimentales (علوم تجريبية)
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الرياضيات', 'slug' => 'sciences-exp-mathematics', 'description_ar' => 'مادة الرياضيات', 'coefficient' => 5, 'icon' => 'calculator', 'color' => '#3B82F6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفيزياء', 'slug' => 'sciences-exp-physics', 'description_ar' => 'مادة الفيزياء', 'coefficient' => 6, 'icon' => 'atom', 'color' => '#8B5CF6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'علوم الطبيعة والحياة', 'slug' => 'sciences-exp-biology', 'description_ar' => 'مادة علوم الطبيعة والحياة', 'coefficient' => 6, 'icon' => 'leaf', 'color' => '#10B981', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'sciences-exp-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 2, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'sciences-exp-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 2, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'sciences-exp-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 2, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'sciences-exp-philosophy', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 2, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'sciences-exp-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 2, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['sciences-exp'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'sciences-exp-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
        ]);

        // Mathematics (رياضيات)
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الرياضيات', 'slug' => 'mathematics-mathematics', 'description_ar' => 'مادة الرياضيات', 'coefficient' => 7, 'icon' => 'calculator', 'color' => '#3B82F6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفيزياء', 'slug' => 'mathematics-physics', 'description_ar' => 'مادة الفيزياء', 'coefficient' => 6, 'icon' => 'atom', 'color' => '#8B5CF6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'علوم الطبيعة والحياة', 'slug' => 'mathematics-biology', 'description_ar' => 'مادة علوم الطبيعة والحياة', 'coefficient' => 3, 'icon' => 'leaf', 'color' => '#10B981', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'mathematics-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 2, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'mathematics-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 2, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'mathematics-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 2, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'mathematics-philosophy', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 2, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'mathematics-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 2, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['mathematics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'mathematics-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
        ]);

        // Technique Mathématique (تقني رياضي) - simplified to one engineering type
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الرياضيات', 'slug' => 'tech-math-mathematics', 'description_ar' => 'مادة الرياضيات', 'coefficient' => 5, 'icon' => 'calculator', 'color' => '#3B82F6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفيزياء', 'slug' => 'tech-math-physics', 'description_ar' => 'مادة الفيزياء', 'coefficient' => 5, 'icon' => 'atom', 'color' => '#8B5CF6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الهندسة الكهربائية', 'slug' => 'tech-math-engineering', 'description_ar' => 'مادة الهندسة (كهربائية، ميكانيكية، مدنية، أو طرائق)', 'coefficient' => 5, 'icon' => 'cog', 'color' => '#F97316', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'tech-math-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 2, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'tech-math-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 2, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'tech-math-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 2, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'tech-math-philosophy', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 2, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'tech-math-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 2, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['tech-math'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'tech-math-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
        ]);

        // Gestion et Économie (تسيير واقتصاد)
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الرياضيات', 'slug' => 'management-mathematics', 'description_ar' => 'مادة الرياضيات', 'coefficient' => 3, 'icon' => 'calculator', 'color' => '#3B82F6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الاقتصاد والمانجمنت', 'slug' => 'management-economics-main', 'description_ar' => 'مادة الاقتصاد والمانجمنت', 'coefficient' => 5, 'icon' => 'briefcase', 'color' => '#22C55E', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'القانون', 'slug' => 'management-law', 'description_ar' => 'مادة القانون', 'coefficient' => 3, 'icon' => 'scale', 'color' => '#DC2626', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'المحاسبة والمالية', 'slug' => 'management-accounting', 'description_ar' => 'مادة المحاسبة والمالية', 'coefficient' => 4, 'icon' => 'chart', 'color' => '#059669', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'management-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 2, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'management-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 2, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'management-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 2, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'management-philosophy', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 2, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'management-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 2, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['management-economics'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'management-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
        ]);

        // Lettres et Philosophie (آداب وفلسفة)
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'literature-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 5, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'literature-philosophy-main', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 7, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'literature-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 3, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'literature-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 4, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'literature-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 2, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'literature-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['literature-philosophy'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الرياضيات', 'slug' => 'literature-mathematics', 'description_ar' => 'مادة الرياضيات', 'coefficient' => 2, 'icon' => 'calculator', 'color' => '#3B82F6', 'order' => ++$subjectOrder],
        ]);

        // Langues Étrangères (لغات أجنبية)
        $subjects = array_merge($subjects, [
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الفرنسية', 'slug' => 'languages-french', 'description_ar' => 'مادة اللغة الفرنسية', 'coefficient' => 5, 'icon' => 'language', 'color' => '#06B6D4', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الإنجليزية', 'slug' => 'languages-english', 'description_ar' => 'مادة اللغة الإنجليزية', 'coefficient' => 5, 'icon' => 'globe', 'color' => '#F59E0B', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة الأجنبية الثالثة', 'slug' => 'languages-third-language', 'description_ar' => 'مادة اللغة الأجنبية الثالثة (إسبانية، ألمانية، أو إيطالية)', 'coefficient' => 4, 'icon' => 'language', 'color' => '#EAB308', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'اللغة العربية', 'slug' => 'languages-arabic', 'description_ar' => 'مادة اللغة العربية', 'coefficient' => 3, 'icon' => 'book', 'color' => '#EF4444', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'الفلسفة', 'slug' => 'languages-philosophy', 'description_ar' => 'مادة الفلسفة', 'coefficient' => 2, 'icon' => 'brain', 'color' => '#6366F1', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'التاريخ والجغرافيا', 'slug' => 'languages-history-geo', 'description_ar' => 'مادة التاريخ والجغرافيا', 'coefficient' => 3, 'icon' => 'map', 'color' => '#84CC16', 'order' => ++$subjectOrder],
            ['academic_stream_id' => $streamIds['foreign-languages'], 'academic_year_id' => $bacYearId, 'name_ar' => 'العلوم الإسلامية', 'slug' => 'languages-islamic', 'description_ar' => 'مادة العلوم الإسلامية', 'coefficient' => 2, 'icon' => 'mosque', 'color' => '#14B8A6', 'order' => ++$subjectOrder],
        ]);

        foreach ($subjects as $subject) {
            DB::table('subjects')->insert($subject);
        }

        $this->command->info('Academic structure seeded successfully!');
        $this->command->info('- 3 phases');
        $this->command->info('- 12 academic years');
        $this->command->info('- 6 BAC streams');
        $this->command->info('- ' . count($subjects) . ' subjects with coefficients');
    }
}
