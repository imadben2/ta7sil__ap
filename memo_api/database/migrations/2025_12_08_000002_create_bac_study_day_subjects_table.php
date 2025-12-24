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
        Schema::create('bac_study_day_subjects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bac_study_day_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->integer('order')->default(1);
            $table->timestamps();

            $table->unique(['bac_study_day_id', 'subject_id']);
            $table->index('bac_study_day_id');
            $table->index('subject_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_study_day_subjects');
    }
};
