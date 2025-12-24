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
        Schema::create('bac_simulations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('bac_subject_id')->constrained()->onDelete('cascade');
            $table->datetime('started_at');
            $table->datetime('submitted_at')->nullable();
            $table->integer('duration_seconds');
            $table->enum('status', ['started', 'completed', 'abandoned']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_simulations');
    }
};
