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
        Schema::create('user_quiz_performance', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
            $table->integer('total_attempts')->default(0);
            $table->integer('total_correct')->default(0);
            $table->integer('total_incorrect')->default(0);
            $table->decimal('average_score', 5, 2);
            $table->decimal('best_score', 5, 2);
            $table->json('weak_concepts')->nullable();
            $table->timestamp('updated_at');

            $table->unique(['user_id', 'subject_id', 'chapter_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_quiz_performance');
    }
};
