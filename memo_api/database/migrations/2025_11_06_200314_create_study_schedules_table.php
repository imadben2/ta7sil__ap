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
        Schema::create('study_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('schedule_type', ['daily', 'weekly'])->default('weekly');
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['draft', 'active', 'completed', 'archived'])->default('draft');

            // Generation metadata
            $table->string('generation_algorithm_version')->default('v1.0');
            $table->decimal('total_study_hours', 5, 2)->default(0);
            $table->json('subjects_covered')->nullable(); // Array of subject IDs
            $table->decimal('feasibility_score', 3, 2)->default(0); // 0-10 score

            $table->timestamp('generated_at');
            $table->timestamp('activated_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status', 'start_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_schedules');
    }
};
