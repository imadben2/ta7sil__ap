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
        Schema::create('bac_subjects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bac_year_id')->constrained()->onDelete('cascade');
            $table->foreignId('bac_session_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->foreignId('academic_stream_id')->constrained()->onDelete('cascade');
            $table->string('title_ar');
            $table->string('file_path');
            $table->string('correction_file_path')->nullable();
            $table->integer('duration_minutes');
            $table->integer('views_count')->default(0);
            $table->integer('downloads_count')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_subjects');
    }
};
