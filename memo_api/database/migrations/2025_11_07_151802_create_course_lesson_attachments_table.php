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
        Schema::create('course_lesson_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_lesson_id')->constrained('course_lessons')->onDelete('cascade');
            $table->string('file_name_ar');
            $table->string('file_path');
            $table->string('file_type');
            $table->integer('file_size');
            $table->integer('order')->default(0);
            $table->timestamps();

            $table->index(['course_lesson_id', 'order']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('course_lesson_attachments');
    }
};
