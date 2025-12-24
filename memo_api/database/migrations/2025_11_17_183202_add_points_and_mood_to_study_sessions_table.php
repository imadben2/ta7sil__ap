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
        Schema::table('study_sessions', function (Blueprint $table) {
            $table->integer('points_earned')->nullable()->after('completion_percentage');
            $table->enum('mood', ['happy', 'neutral', 'sad'])->nullable()->after('points_earned');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('study_sessions', function (Blueprint $table) {
            $table->dropColumn(['points_earned', 'mood']);
        });
    }
};
