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
        Schema::create('session_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('study_session_id')->constrained()->onDelete('cascade');
            $table->enum('activity_type', ['start', 'pause', 'resume', 'complete']); // Start, pause, resume, complete
            $table->timestamp('activity_timestamp');
            $table->json('metadata')->nullable(); // {break_type: 'short', pomodoro_round: 2}
            $table->timestamp('created_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('session_activities');
    }
};
