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
        Schema::table('planner_settings', function (Blueprint $table) {
            // Algorithm settings from promt.md
            $table->float('buffer_rate')->default(0.20)->after('smart_content_suggestions')
                  ->comment('Buffer rate for available time (0.20 = 20%)');
            $table->integer('max_coef7_per_day')->default(1)->after('buffer_rate')
                  ->comment('Max sessions per day for coefficient 7 subjects');
            $table->integer('max_hard_per_day')->default(2)->after('max_coef7_per_day')
                  ->comment('Max HARD_CORE sessions per day');
            $table->string('mock_day_of_week')->default('saturday')->after('max_hard_per_day')
                  ->comment('Day of week for mock tests (saturday, sunday, etc.)');
            $table->integer('mock_duration_minutes')->default(100)->after('mock_day_of_week')
                  ->comment('Duration of weekly mock test in minutes');
            $table->boolean('language_daily_guarantee')->default(true)->after('mock_duration_minutes')
                  ->comment('Guarantee at least 1 language session per day');
            $table->boolean('no_consecutive_hard')->default(true)->after('language_daily_guarantee')
                  ->comment('Prevent consecutive HARD_CORE sessions');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_settings', function (Blueprint $table) {
            $table->dropColumn([
                'buffer_rate',
                'max_coef7_per_day',
                'max_hard_per_day',
                'mock_day_of_week',
                'mock_duration_minutes',
                'language_daily_guarantee',
                'no_consecutive_hard',
            ]);
        });
    }
};
