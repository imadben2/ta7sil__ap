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
        Schema::create('subject_priorities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');

            // Priority Score Components
            $table->decimal('coefficient_score', 5, 2);
            $table->decimal('exam_proximity_score', 5, 2);
            $table->decimal('difficulty_score', 5, 2);
            $table->decimal('inactivity_score', 5, 2);
            $table->decimal('performance_gap_score', 5, 2);
            $table->decimal('total_priority_score', 5, 2);

            $table->timestamp('calculated_at');
            $table->timestamps();

            $table->unique(['user_id', 'subject_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subject_priorities');
    }
};
