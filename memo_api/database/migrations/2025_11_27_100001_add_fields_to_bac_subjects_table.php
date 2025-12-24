<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add missing fields from specification to bac_subjects table
     */
    public function up(): void
    {
        Schema::table('bac_subjects', function (Blueprint $table) {
            // Total points for the exam (default 20 for BAC)
            $table->decimal('total_points', 5, 2)->default(20.00)->after('duration_minutes');

            // Difficulty rating (1-10 scale, set by admins or calculated from user feedback)
            $table->decimal('difficulty_rating', 3, 2)->nullable()->after('total_points');

            // Average national score (if known)
            $table->decimal('average_score', 5, 2)->nullable()->after('difficulty_rating');

            // Counter for simulations (incremented each time a user starts a simulation)
            $table->unsignedInteger('simulations_count')->default(0)->after('downloads_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bac_subjects', function (Blueprint $table) {
            $table->dropColumn([
                'total_points',
                'difficulty_rating',
                'average_score',
                'simulations_count'
            ]);
        });
    }
};
