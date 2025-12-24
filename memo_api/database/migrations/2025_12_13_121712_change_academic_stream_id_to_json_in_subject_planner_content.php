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
        // Step 1: Add new JSON column
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->json('academic_stream_ids')->nullable()->after('academic_year_id');
        });

        // Step 2: Migrate existing data - convert single ID to array
        DB::statement("
            UPDATE subject_planner_content
            SET academic_stream_ids = CASE
                WHEN academic_stream_id IS NOT NULL THEN JSON_ARRAY(academic_stream_id)
                ELSE NULL
            END
        ");

        // Step 3: Drop old column and its foreign key
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->dropForeign(['academic_stream_id']);
            $table->dropColumn('academic_stream_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Step 1: Add back the old column
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->foreignId('academic_stream_id')->nullable()->after('academic_year_id')
                ->constrained('academic_streams')->nullOnDelete();
        });

        // Step 2: Migrate data back - get first ID from array
        DB::statement("
            UPDATE subject_planner_content
            SET academic_stream_id = JSON_EXTRACT(academic_stream_ids, '$[0]')
            WHERE academic_stream_ids IS NOT NULL
        ");

        // Step 3: Drop JSON column
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->dropColumn('academic_stream_ids');
        });
    }
};
