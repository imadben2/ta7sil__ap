<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Mapping from old subject_id to new subject_id
     * Based on title_ar analysis from bac_subjects table
     */
    private array $mapping = [
        // Old ID => New ID
        1 => 64,   // الرياضيات => الرياضيات (64)
        2 => 67,   // العلوم الفيزيائية => العلوم الفيزيائية (67)
        3 => 68,   // العلوم الطبيعية => العلوم الطبيعية (68)
        4 => 59,   // اللغة العربية => اللغة العربية (59)
        5 => 60,   // اللغة الفرنسية => اللغة الفرنسية (60)
        6 => 61,   // اللغة الانجليزية => اللغة الإنجليزية (61)
        7 => 65,   // الفلسفة => الفلسفة (65)
        8 => 63,   // التاريخ و الجغرافيا => التاريخ والجغرافيا (63)
        9 => 62,   // العلوم الإسلامية => التربية الإسلامية (62)
        21 => 73,  // الهندسة الكهربائية => الهندسة الكهربائية (73)
        29 => 69,  // الاقتصاد و المناجمنت => الاقتصاد (69)
        30 => 70,  // القانون => القانون (70)
        31 => 71,  // التسيير المحاسبي والمالي => المحاسبة (71)
        53 => 73,  // الهندسة المدنية => الهندسة الكهربائية (73) - closest match
        54 => 74,  // الهندسة الميكانيكية => الهندسة الميكانيكية (74)
        55 => 75,  // هندسة الطرائق => هندسة الطرائق (75)
        56 => 72,  // اللغة الألمانية => لغة أجنبية (الاختيار الثالث) (72)
        57 => 72,  // اللغة الإسبانية => لغة أجنبية (الاختيار الثالث) (72)
    ];

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Update bac_subjects table with new subject_id mapping
        foreach ($this->mapping as $oldId => $newId) {
            $affected = DB::table('bac_subjects')
                ->where('subject_id', $oldId)
                ->update(['subject_id' => $newId]);

            if ($affected > 0) {
                echo "Updated {$affected} rows: subject_id {$oldId} => {$newId}\n";
            }
        }

        // Log any unmapped subject_ids
        $unmapped = DB::table('bac_subjects')
            ->whereNotIn('subject_id', array_values($this->mapping))
            ->distinct()
            ->pluck('subject_id')
            ->toArray();

        if (!empty($unmapped)) {
            echo "Warning: Unmapped subject_ids found: " . implode(', ', $unmapped) . "\n";
        }

        echo "Migration completed successfully!\n";
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reverse mapping
        $reverseMapping = array_flip($this->mapping);

        foreach ($reverseMapping as $newId => $oldId) {
            DB::table('bac_subjects')
                ->where('subject_id', $newId)
                ->update(['subject_id' => $oldId]);
        }
    }
};
