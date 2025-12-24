<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Create pivot table for FlashcardDeck and AcademicStream many-to-many relationship.
     * A flashcard deck can belong to multiple streams (like subjects).
     */
    public function up(): void
    {
        Schema::create('flashcard_deck_stream', function (Blueprint $table) {
            $table->id();
            $table->foreignId('flashcard_deck_id')->constrained('flashcard_decks')->onDelete('cascade');
            $table->foreignId('academic_stream_id')->constrained('academic_streams')->onDelete('cascade');
            $table->timestamps();

            // Unique constraint to prevent duplicates
            $table->unique(['flashcard_deck_id', 'academic_stream_id'], 'deck_stream_unique');
        });

        // Remove the single academic_stream_id column from flashcard_decks
        // We'll keep it for backward compatibility but will use the pivot table going forward
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flashcard_deck_stream');
    }
};
