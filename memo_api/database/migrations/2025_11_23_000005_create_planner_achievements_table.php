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
        Schema::create('planner_achievements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            $table->string('achievement_id')->unique();
            $table->string('name');
            $table->text('description');
            $table->string('icon');
            $table->integer('points');
            $table->timestamp('unlocked_at');

            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'unlocked_at']);
            $table->index('achievement_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_achievements');
    }
};
