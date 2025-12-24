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
        Schema::create('planner_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('academic_year_id')->constrained();
            $table->foreignId('academic_stream_id')->constrained();

            // Schedule metadata
            $table->date('start_date');
            $table->date('end_date');
            $table->boolean('is_active')->default(true);

            // Adaptation tracking
            $table->integer('adaptation_count')->default(0);
            $table->timestamp('last_adapted_at')->nullable();
            $table->json('adaptation_reasons')->nullable();

            // Statistics
            $table->integer('total_sessions')->default(0);
            $table->integer('completed_sessions')->default(0);
            $table->float('completion_rate')->default(0);

            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'is_active']);
            $table->index('start_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_schedules');
    }
};
