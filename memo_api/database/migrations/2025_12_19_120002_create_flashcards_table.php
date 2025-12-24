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
        Schema::create('flashcards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('deck_id')->constrained('flashcard_decks')->onDelete('cascade');

            // Card type: basic, cloze, image, audio
            $table->enum('card_type', ['basic', 'cloze', 'image', 'audio'])->default('basic');

            // Front side content
            $table->text('front_text_ar');
            $table->text('front_text_fr')->nullable();
            $table->string('front_image_url')->nullable();
            $table->string('front_audio_url')->nullable();

            // Back side content
            $table->text('back_text_ar');
            $table->text('back_text_fr')->nullable();
            $table->string('back_image_url')->nullable();
            $table->string('back_audio_url')->nullable();

            // For cloze deletion cards
            // Template format: "الجواب هو {{c1::الحل}} في المعادلة"
            $table->text('cloze_template')->nullable();
            // Array of cloze items: [{"id": "c1", "answer": "الحل", "hint": "..."}]
            $table->json('cloze_deletions')->nullable();

            // Additional content
            $table->text('hint_ar')->nullable();
            $table->text('hint_fr')->nullable();
            $table->text('explanation_ar')->nullable();
            $table->text('explanation_fr')->nullable();

            // Metadata
            $table->json('tags')->nullable();
            $table->enum('difficulty_level', ['easy', 'medium', 'hard'])->default('medium');
            $table->unsignedInteger('order')->default(0);
            $table->boolean('is_active')->default(true);

            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['deck_id', 'is_active']);
            $table->index('card_type');
            $table->index('order');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flashcards');
    }
};
