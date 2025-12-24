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
        Schema::create('flashcard_review_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('flashcard_id')->constrained('flashcards')->onDelete('cascade');
            $table->foreignId('session_id')->nullable()->constrained('flashcard_review_sessions')->onDelete('set null');

            // Review data
            // Quality rating: 0-5 SM-2 scale
            // 0: Complete blackout
            // 1: Wrong, but recognized after seeing answer
            // 2: Wrong, but close / Correct with serious difficulty
            // 3: Correct with some hesitation
            // 4: Correct with slight hesitation
            // 5: Perfect response
            $table->tinyInteger('quality_rating')->unsigned();
            $table->unsignedInteger('response_time_seconds')->nullable();

            // SM-2 state before/after this review
            $table->decimal('ease_factor_before', 4, 2);
            $table->decimal('ease_factor_after', 4, 2);
            $table->unsignedInteger('interval_before');
            $table->unsignedInteger('interval_after');
            $table->date('next_review_before')->nullable();
            $table->date('next_review_after');

            // Learning state transition
            $table->string('state_before', 20)->nullable();
            $table->string('state_after', 20)->nullable();

            $table->timestamp('reviewed_at');

            // Indexes
            $table->index(['user_id', 'reviewed_at']);
            $table->index('flashcard_id');
            $table->index('session_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flashcard_review_logs');
    }
};
