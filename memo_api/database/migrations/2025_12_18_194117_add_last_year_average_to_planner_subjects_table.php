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
        Schema::table('planner_subjects', function (Blueprint $table) {
            $table->decimal('last_year_average', 4, 2)
                ->nullable()
                ->after('difficulty_level')
                ->comment('معدل السنة الماضية (0-20 scale)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_subjects', function (Blueprint $table) {
            $table->dropColumn('last_year_average');
        });
    }
};
