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
            $table->json('coefficient_durations')->nullable()->after('no_consecutive_hard')
                  ->comment('Session duration in minutes per coefficient: {7:90, 6:80, 5:75, 4:60, 3:50, 2:40, 1:30}');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_settings', function (Blueprint $table) {
            $table->dropColumn('coefficient_durations');
        });
    }
};
