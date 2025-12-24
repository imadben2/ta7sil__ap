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
        Schema::table('user_quiz_performance', function (Blueprint $table) {
            // Drop the existing unique constraint
            $table->dropUnique(['user_id', 'subject_id', 'chapter_id']);

            // Drop columns that don't exist in the model
            if (Schema::hasColumn('user_quiz_performance', 'chapter_id')) {
                $table->dropForeign(['chapter_id']);
                $table->dropColumn('chapter_id');
            }
            if (Schema::hasColumn('user_quiz_performance', 'total_correct')) {
                $table->dropColumn('total_correct');
            }
            if (Schema::hasColumn('user_quiz_performance', 'total_incorrect')) {
                $table->dropColumn('total_incorrect');
            }

            // Add missing columns
            $table->foreignId('quiz_id')->after('subject_id')->constrained()->onDelete('cascade');
            $table->integer('total_time_spent_minutes')->default(0)->after('average_score');
            $table->timestamp('last_attempt_date')->nullable()->after('total_time_spent_minutes');
            $table->timestamp('created_at')->nullable()->after('weak_concepts');

            // Add new unique constraint
            $table->unique(['user_id', 'quiz_id', 'subject_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_quiz_performance', function (Blueprint $table) {
            // Drop new unique constraint
            $table->dropUnique(['user_id', 'quiz_id', 'subject_id']);

            // Drop added columns
            $table->dropForeign(['quiz_id']);
            $table->dropColumn('quiz_id');
            $table->dropColumn('total_time_spent_minutes');
            $table->dropColumn('last_attempt_date');
            $table->dropColumn('created_at');

            // Re-add dropped columns
            $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
            $table->integer('total_correct')->default(0);
            $table->integer('total_incorrect')->default(0);

            // Re-add original unique constraint
            $table->unique(['user_id', 'subject_id', 'chapter_id']);
        });
    }
};
