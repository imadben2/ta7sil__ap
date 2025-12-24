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
        Schema::create('content_bookmarks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('content_id')->constrained('contents')->onDelete('cascade');

            // Optional: page number for PDF bookmarks
            $table->integer('page_number')->nullable()->comment('For PDF content - specific page bookmarked');

            // Optional: timestamp for video bookmarks
            $table->integer('timestamp_seconds')->nullable()->comment('For video content - specific timestamp bookmarked');

            // Notes for the bookmark
            $table->text('notes')->nullable();

            $table->timestamps();

            // Ensure one bookmark per user per content
            $table->unique(['user_id', 'content_id']);

            // Index for performance
            $table->index('user_id');
            $table->index('content_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_bookmarks');
    }
};
