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
        Schema::create('bac_topic_content_mapping', function (Blueprint $table) {
            $table->id();

            // Foreign Keys
            $table->foreignId('bac_study_day_topic_id')
                ->constrained('bac_study_day_topics')
                ->onDelete('cascade')
                ->comment('Reference to BAC study day topic');

            $table->foreignId('subject_planner_content_id')
                ->constrained('subject_planner_content')
                ->onDelete('cascade')
                ->comment('Reference to curriculum content');

            // Relevance Score
            $table->unsignedTinyInteger('relevance_score')
                ->default(100)
                ->comment('0-100, how relevant this content is to the BAC topic');

            $table->timestamp('created_at')->useCurrent();

            // Unique Constraint
            $table->unique(['bac_study_day_topic_id', 'subject_planner_content_id'], 'unique_mapping');

            // Index
            $table->index('relevance_score', 'idx_relevance');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_topic_content_mapping');
    }
};
