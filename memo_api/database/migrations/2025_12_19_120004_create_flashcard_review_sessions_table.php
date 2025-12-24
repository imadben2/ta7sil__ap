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
        Schema::create('flashcard_review_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('deck_id')->nullable()->constrained('flashcard_decks')->onDelete('set null');

            // Session timing
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->unsignedInteger('duration_seconds')->default(0);

            // Session statistics
            $table->unsignedInteger('total_cards_reviewed')->default(0);
            $table->unsignedInteger('new_cards_studied')->default(0);
            $table->unsignedInteger('review_cards_studied')->default(0);

            // Quality distribution (SM-2 ratings)
            $table->unsignedInteger('again_count')->default(0);  // Quality 0-1
            $table->unsignedInteger('hard_count')->default(0);   // Quality 2
            $table->unsignedInteger('good_count')->default(0);   // Quality 3-4
            $table->unsignedInteger('easy_count')->default(0);   // Quality 5

            // Performance metrics
            $table->decimal('average_response_time_seconds', 8, 2)->nullable();
            $table->decimal('session_retention_rate', 5, 2)->default(0);

            // Session state
            $table->enum('status', ['in_progress', 'completed', 'abandoned'])->default('in_progress');

            // Array of card IDs reviewed in this session
            $table->json('cards_reviewed')->nullable();

            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'status']);
            $table->index(['user_id', 'deck_id']);
            $table->index('started_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flashcard_review_sessions');
    }
};
