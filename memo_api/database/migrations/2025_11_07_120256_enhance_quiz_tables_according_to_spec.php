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
        // Enhance quizzes table
        Schema::table('quizzes', function (Blueprint $table) {
            // Add missing columns from spec
            $table->integer('estimated_duration_minutes')->after('difficulty_level')->nullable();
            $table->boolean('shuffle_questions')->after('passing_score')->default(true);
            $table->boolean('shuffle_answers')->after('shuffle_questions')->default(true);
            $table->boolean('show_correct_answers')->after('shuffle_answers')->default(true);
            $table->boolean('allow_review')->after('show_correct_answers')->default(true);

            // Add metadata
            $table->json('tags')->after('allow_review')->nullable();
            $table->integer('total_questions')->after('tags')->default(0);
            $table->decimal('average_score', 5, 2)->after('total_questions')->default(0);
            $table->integer('total_attempts')->after('average_score')->default(0);

            // Add premium flag
            $table->boolean('is_premium')->after('is_published')->default(false);

            // Make subject_id nullable (quiz can be standalone)
            $table->foreignId('subject_id')->nullable()->change();
        });

        // Enhance quiz_questions table
        Schema::table('quiz_questions', function (Blueprint $table) {
            // Add missing metadata
            $table->enum('difficulty', ['easy', 'medium', 'hard'])->after('points')->nullable();
            $table->json('tags')->after('difficulty')->nullable();

            // Rename order to question_order for clarity
            if (Schema::hasColumn('quiz_questions', 'order')) {
                $table->renameColumn('order', 'question_order');
            }

            $table->softDeletes();
        });

        // Enhance quiz_attempts table
        Schema::table('quiz_attempts', function (Blueprint $table) {
            // Rename columns to match spec
            if (Schema::hasColumn('quiz_attempts', 'submitted_at')) {
                $table->renameColumn('submitted_at', 'completed_at');
            }
            if (Schema::hasColumn('quiz_attempts', 'duration_seconds')) {
                $table->renameColumn('duration_seconds', 'time_spent_seconds');
            }
            if (Schema::hasColumn('quiz_attempts', 'is_completed')) {
                $table->dropColumn('is_completed');
            }

            // Add status enum
            $table->enum('status', ['in_progress', 'completed', 'abandoned'])->after('user_id')->default('in_progress');

            // Add detailed results
            $table->integer('total_questions')->after('status');
            $table->integer('correct_answers')->after('total_questions')->default(0);
            $table->integer('incorrect_answers')->after('correct_answers')->default(0);
            $table->integer('skipped_answers')->after('incorrect_answers')->default(0);

            // Rename score to score_percentage
            if (Schema::hasColumn('quiz_attempts', 'score')) {
                $table->renameColumn('score', 'score_percentage');
            }

            // Add total_points
            $table->integer('total_points')->after('score_percentage')->default(0);

            // Add answers JSON field
            $table->json('answers')->after('max_score')->nullable();
        });

        // Create indexes
        Schema::table('quizzes', function (Blueprint $table) {
            $table->index(['subject_id', 'difficulty_level', 'is_published'], 'quizzes_filtering_index');
        });

        Schema::table('quiz_questions', function (Blueprint $table) {
            $table->index(['quiz_id', 'question_type'], 'questions_quiz_type_index');
        });

        Schema::table('quiz_attempts', function (Blueprint $table) {
            $table->index(['user_id', 'quiz_id', 'status'], 'attempts_user_quiz_status_index');
            $table->index(['user_id', 'completed_at'], 'attempts_user_completed_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropIndex('quizzes_filtering_index');
            $table->dropColumn([
                'estimated_duration_minutes',
                'shuffle_questions',
                'shuffle_answers',
                'show_correct_answers',
                'allow_review',
                'tags',
                'total_questions',
                'average_score',
                'total_attempts',
                'is_premium'
            ]);
        });

        Schema::table('quiz_questions', function (Blueprint $table) {
            $table->dropIndex('questions_quiz_type_index');
            $table->dropColumn(['difficulty', 'tags']);
            $table->dropSoftDeletes();
            if (Schema::hasColumn('quiz_questions', 'question_order')) {
                $table->renameColumn('question_order', 'order');
            }
        });

        Schema::table('quiz_attempts', function (Blueprint $table) {
            $table->dropIndex('attempts_user_quiz_status_index');
            $table->dropIndex('attempts_user_completed_index');
            $table->dropColumn([
                'status',
                'total_questions',
                'correct_answers',
                'incorrect_answers',
                'skipped_answers',
                'total_points',
                'answers'
            ]);
            if (Schema::hasColumn('quiz_attempts', 'completed_at')) {
                $table->renameColumn('completed_at', 'submitted_at');
            }
            if (Schema::hasColumn('quiz_attempts', 'time_spent_seconds')) {
                $table->renameColumn('time_spent_seconds', 'duration_seconds');
            }
            if (Schema::hasColumn('quiz_attempts', 'score_percentage')) {
                $table->renameColumn('score_percentage', 'score');
            }
            $table->boolean('is_completed')->default(false);
        });
    }
};
