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
        Schema::create('user_flashcard_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('flashcard_id')->constrained('flashcards')->onDelete('cascade');

            // SM-2 Algorithm core fields
            // Ease Factor: multiplier for interval, starts at 2.5
            // Range: 1.30 to 3.00
            $table->decimal('ease_factor', 4, 2)->default(2.50);

            // Interval: days until next review
            $table->unsignedInteger('interval')->default(0);

            // Repetitions: successful reviews in a row (quality >= 3)
            $table->unsignedInteger('repetitions')->default(0);

            // Next review date (null = never reviewed or due now)
            $table->date('next_review_date')->nullable();
            $table->date('last_review_date')->nullable();

            // Performance tracking
            $table->unsignedInteger('total_reviews')->default(0);
            $table->unsignedInteger('correct_reviews')->default(0);
            $table->unsignedInteger('lapses')->default(0); // Times went back to "again"

            // Streak tracking
            $table->unsignedInteger('current_streak')->default(0);
            $table->unsignedInteger('longest_streak')->default(0);

            // Learning state
            // new: never reviewed
            // learning: being learned (repetitions < 2)
            // reviewing: in regular review cycle
            // relearning: lapsed and being relearned
            $table->enum('learning_state', ['new', 'learning', 'reviewing', 'relearning'])->default('new');

            $table->timestamps();

            // Constraints
            $table->unique(['user_id', 'flashcard_id']);

            // Indexes for common queries
            $table->index(['user_id', 'next_review_date']);
            $table->index(['user_id', 'learning_state']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_flashcard_progress');
    }
};
