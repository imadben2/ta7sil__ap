<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->tinyInteger('trimester')->nullable()->after('academic_stream_ids')
                ->comment('Trimester: 1, 2, or 3. Null means applicable to all trimesters.');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subject_planner_content', function (Blueprint $table) {
            $table->dropColumn('trimester');
        });
    }
};
