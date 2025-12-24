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
        Schema::create('quiz_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_id')->constrained()->onDelete('cascade');
            $table->enum('question_type', [
                'mcq_single',
                'mcq_multiple',
                'true_false',
                'matching',
                'fill_blank',
                'sequence',
                'short_answer',
                'long_answer'
            ]);
            $table->text('question_text_ar');
            $table->string('question_image_url')->nullable();
            $table->json('options')->nullable(); // for MCQ, matching, sequence
            $table->json('correct_answer');
            $table->integer('points')->default(1);
            $table->text('explanation_ar')->nullable();
            $table->integer('order');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quiz_questions');
    }
};
