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
        Schema::create('contents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->foreignId('content_type_id')->constrained()->onDelete('cascade');
            $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');

            // Content Basic Info
            $table->string('title_ar');
            $table->string('slug');
            $table->text('description_ar')->nullable();
            $table->longText('content_body_ar')->nullable();

            // Metadata
            $table->enum('difficulty_level', ['easy', 'medium', 'hard'])->default('medium');
            $table->integer('estimated_duration_minutes')->nullable();
            $table->integer('order')->default(0);
            $table->json('prerequisites')->nullable(); // IDs of prerequisite contents

            // Files
            $table->boolean('has_file')->default(false);
            $table->string('file_path')->nullable();
            $table->string('file_type')->nullable();
            $table->integer('file_size')->nullable(); // bytes

            // Video
            $table->boolean('has_video')->default(false);
            $table->enum('video_type', ['youtube', 'upload'])->nullable();
            $table->string('video_url')->nullable();
            $table->integer('video_duration_seconds')->nullable();

            // Publication Status
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->boolean('is_premium')->default(false);

            // Tags & Search
            $table->json('tags')->nullable();
            $table->text('search_keywords')->nullable();

            // Stats
            $table->integer('views_count')->default(0);
            $table->integer('downloads_count')->default(0);

            // Audit
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('updated_by')->nullable()->constrained('users')->onDelete('set null');

            $table->timestamps();
            $table->softDeletes();

            $table->index(['subject_id', 'content_type_id', 'chapter_id', 'is_published'], 'idx_contents_main');
            // fullText index only for MySQL/PostgreSQL - skip for SQLite
            if (config('database.default') !== 'sqlite') {
                $table->fullText(['title_ar', 'description_ar', 'search_keywords'], 'ft_contents_search');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contents');
    }
};
