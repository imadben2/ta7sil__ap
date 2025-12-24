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
        Schema::create('user_subject_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');

            // User-specific subject metrics
            $table->integer('difficulty_level')->default(5); // 1-10 scale (user's perceived difficulty)
            $table->decimal('progress_percentage', 5, 2)->default(0.00); // 0.00 - 100.00
            $table->timestamp('last_studied_at')->nullable();

            // Chapter progress
            $table->integer('total_chapters')->default(0);
            $table->integer('completed_chapters')->default(0);

            // Performance
            $table->decimal('average_score', 5, 2)->nullable(); // Average score out of 20

            $table->timestamps();

            // Ensure unique user-subject combination
            $table->unique(['user_id', 'subject_id']);

            // Indexes for common queries
            $table->index('user_id');
            $table->index(['user_id', 'progress_percentage']);
            $table->index(['user_id', 'last_studied_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_subject_progress');
    }
};
