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
        Schema::create('planner_exams', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects');

            $table->string('title');
            $table->text('description')->nullable();
            $table->date('exam_date');
            $table->time('exam_time')->nullable();
            $table->integer('duration_minutes')->nullable();
            $table->string('location')->nullable();

            // Result tracking
            $table->float('score')->nullable();
            $table->float('max_score')->nullable();
            $table->float('percentage')->nullable();
            $table->enum('grade', ['A', 'B', 'C', 'D', 'E', 'F'])->nullable();
            $table->text('notes')->nullable();

            // Schedule adaptation trigger
            $table->boolean('triggered_adaptation')->default(false);
            $table->timestamp('adaptation_triggered_at')->nullable();

            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'exam_date']);
            $table->index('subject_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_exams');
    }
};
