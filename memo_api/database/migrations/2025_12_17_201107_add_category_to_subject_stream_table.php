<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('subject_stream', function (Blueprint $table) {
            // Add category column - each subject can have different category per stream
            $table->enum('category', ['HARD_CORE', 'LANGUAGE', 'MEMORIZATION', 'OTHER'])
                ->default('OTHER')
                ->after('coefficient')
                ->comment('Subject category for this specific stream');
        });

        // Migrate existing data from subjects.category to subject_stream.category
        DB::statement("
            UPDATE subject_stream ss
            INNER JOIN subjects s ON s.id = ss.subject_id
            SET ss.category = COALESCE(s.category, 'OTHER')
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subject_stream', function (Blueprint $table) {
            $table->dropColumn('category');
        });
    }
};
