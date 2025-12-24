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
        Schema::create('bac_study_day_topics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bac_study_day_subject_id')->constrained()->onDelete('cascade');
            $table->string('topic_ar');
            $table->text('description_ar')->nullable();
            $table->enum('task_type', ['study', 'memorize', 'solve', 'review', 'exercise'])->default('study');
            $table->integer('order')->default(1);
            $table->timestamps();

            $table->index('bac_study_day_subject_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_study_day_topics');
    }
};
