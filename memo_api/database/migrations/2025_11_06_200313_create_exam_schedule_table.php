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
        Schema::create('exam_schedule', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->enum('exam_type', ['test', 'exam', 'final']); // فرض، اختبار، بكالوريا
            $table->date('exam_date');
            $table->time('exam_time')->nullable();
            $table->integer('estimated_duration_minutes')->default(120);
            $table->integer('importance_level')->default(5); // 1-10
            $table->integer('preparation_days_before')->default(7); // Days before to start intensive prep
            $table->boolean('is_completed')->default(false);
            $table->decimal('actual_score', 5, 2)->nullable(); // Actual score /20
            $table->timestamps();

            $table->index(['user_id', 'exam_date']);
            $table->index(['user_id', 'subject_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exam_schedule');
    }
};
