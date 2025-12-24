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
        Schema::create('planner_subjects', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('subject_id');

            // Subject configuration
            $table->tinyInteger('difficulty_level')->default(3)->comment('1=Very Easy, 2=Easy, 3=Medium, 4=Hard, 5=Very Hard');
            $table->enum('priority', ['low', 'medium', 'high', 'critical'])->default('medium');
            $table->tinyInteger('progress_percentage')->default(0)->comment('0-100');

            // Status
            $table->boolean('is_active')->default(true);

            $table->timestamps();

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');

            $table->foreign('subject_id')
                ->references('id')
                ->on('subjects')
                ->onDelete('cascade');

            // Unique constraint: user can only have one planner entry per subject
            $table->unique(['user_id', 'subject_id']);

            // Indexes for performance
            $table->index('user_id');
            $table->index('subject_id');
            $table->index(['user_id', 'is_active']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_subjects');
    }
};
