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
        Schema::create('user_stats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            $table->integer('total_study_minutes')->default(0);
            $table->integer('total_sessions_completed')->default(0);
            $table->integer('total_contents_completed')->default(0);
            $table->integer('total_quizzes_completed')->default(0);
            $table->integer('total_simulations_completed')->default(0);
            $table->integer('average_daily_study_minutes')->default(0);
            $table->integer('current_week_minutes')->default(0);
            $table->integer('current_month_minutes')->default(0);
            $table->timestamp('updated_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_stats');
    }
};
