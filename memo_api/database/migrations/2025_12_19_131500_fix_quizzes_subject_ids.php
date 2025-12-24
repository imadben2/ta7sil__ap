<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Fix quiz subject_id mapping to correct subject IDs
     */
    public function up(): void
    {
        // Old subject_id => New subject_id mapping
        // Based on the quiz content and subject names
        $mapping = [
            1 => 64,  // الرياضيات (Math)
            2 => 67,  // العلوم الفيزيائية (Physics)
            3 => 66,  // علوم الطبيعة والحياة (Natural Sciences)
            5 => 60,  // اللغة الفرنسية (French)
            7 => 59,  // اللغة العربية (Arabic)
            8 => 63,  // التاريخ والجغرافيا (History & Geography)
        ];

        foreach ($mapping as $oldId => $newId) {
            $count = DB::table('quizzes')
                ->where('subject_id', $oldId)
                ->update(['subject_id' => $newId]);

            echo "Updated subject_id {$oldId} => {$newId}: {$count} quizzes\n";
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reverse mapping
        $mapping = [
            64 => 1,  // الرياضيات
            67 => 2,  // العلوم الفيزيائية
            66 => 3,  // علوم الطبيعة والحياة
            60 => 5,  // اللغة الفرنسية
            59 => 7,  // اللغة العربية
            63 => 8,  // التاريخ والجغرافيا
        ];

        foreach ($mapping as $newId => $oldId) {
            DB::table('quizzes')
                ->where('subject_id', $newId)
                ->update(['subject_id' => $oldId]);
        }
    }
};
