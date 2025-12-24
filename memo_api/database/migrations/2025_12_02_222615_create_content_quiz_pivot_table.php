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
        Schema::create('content_quiz', function (Blueprint $table) {
            $table->id();
            $table->foreignId('content_id')->constrained('contents')->onDelete('cascade');
            $table->foreignId('quiz_id')->constrained('quizzes')->onDelete('cascade');
            $table->timestamps();

            // Prevent duplicate assignments
            $table->unique(['content_id', 'quiz_id']);
        });

        // Migrate existing quiz_id data if the column exists
        if (Schema::hasColumn('contents', 'quiz_id')) {
            DB::statement('
                INSERT INTO content_quiz (content_id, quiz_id, created_at, updated_at)
                SELECT id, quiz_id, created_at, updated_at
                FROM contents
                WHERE quiz_id IS NOT NULL
            ');
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_quiz');
    }
};
