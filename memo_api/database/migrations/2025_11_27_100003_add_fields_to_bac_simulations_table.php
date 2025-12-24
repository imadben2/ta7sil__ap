<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add missing fields from specification to bac_simulations table
     */
    public function up(): void
    {
        Schema::table('bac_simulations', function (Blueprint $table) {
            // Time limit in seconds (matches exam duration)
            $table->unsignedInteger('time_limit_seconds')->nullable()->after('duration_seconds');

            // User's final score after self-evaluation
            $table->decimal('user_score', 5, 2)->nullable()->after('status');

            // Whether the score was self-evaluated by the student
            $table->boolean('self_evaluated')->default(false)->after('user_score');

            // JSON object storing scores per chapter
            // Format: {"chapter_id": {"points": 5, "total": 7, "percentage": 71.4}}
            $table->json('chapter_scores')->nullable()->after('self_evaluated');

            // Difficulty felt by the student
            $table->enum('difficulty_felt', ['easy', 'medium', 'hard'])->nullable()->after('chapter_scores');

            // Student's notes about the exam
            $table->text('user_notes')->nullable()->after('difficulty_felt');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bac_simulations', function (Blueprint $table) {
            $table->dropColumn([
                'time_limit_seconds',
                'user_score',
                'self_evaluated',
                'chapter_scores',
                'difficulty_felt',
                'user_notes'
            ]);
        });
    }
};
