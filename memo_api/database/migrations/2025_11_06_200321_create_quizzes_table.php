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
        Schema::create('quizzes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
            $table->string('title_ar');
            $table->string('slug');
            $table->text('description_ar')->nullable();
            $table->enum('quiz_type', ['practice', 'timed', 'exam']);
            $table->integer('time_limit_minutes')->nullable();
            $table->integer('passing_score')->default(50);
            $table->enum('difficulty_level', ['easy', 'medium', 'hard']);
            $table->boolean('is_published')->default(false);
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quizzes');
    }
};
