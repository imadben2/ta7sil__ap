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
        Schema::create('flashcard_decks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');
            $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
            $table->foreignId('academic_stream_id')->nullable()->constrained('academic_streams')->onDelete('set null');

            // Content
            $table->string('title_ar');
            $table->string('title_fr')->nullable();
            $table->string('slug')->unique();
            $table->text('description_ar')->nullable();
            $table->text('description_fr')->nullable();

            // Display
            $table->string('cover_image_url')->nullable();
            $table->string('color', 20)->default('#6366F1');
            $table->string('icon', 50)->nullable();

            // Stats (denormalized for performance)
            $table->unsignedInteger('total_cards')->default(0);
            $table->unsignedInteger('estimated_study_minutes')->nullable();

            // Metadata
            $table->enum('difficulty_level', ['easy', 'medium', 'hard'])->default('medium');
            $table->json('tags')->nullable();
            $table->boolean('is_published')->default(false);
            $table->boolean('is_premium')->default(false);
            $table->unsignedInteger('order')->default(0);

            // Audit
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['subject_id', 'is_published']);
            $table->index(['chapter_id', 'is_published']);
            $table->index('academic_stream_id');
            $table->index('is_premium');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flashcard_decks');
    }
};
