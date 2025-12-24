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
        Schema::create('course_lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_module_id')->constrained()->onDelete('cascade');
            $table->string('title_ar');
            $table->text('description_ar')->nullable();
            $table->enum('video_type', ['youtube', 'upload']);
            $table->string('video_url');
            $table->integer('video_duration_seconds')->nullable();
            $table->boolean('has_pdf')->default(false);
            $table->string('pdf_path')->nullable();
            $table->integer('order');
            $table->boolean('is_preview')->default(false); // free preview
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('course_lessons');
    }
};
