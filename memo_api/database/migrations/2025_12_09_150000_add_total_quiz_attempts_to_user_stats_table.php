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
        Schema::table('user_stats', function (Blueprint $table) {
            if (!Schema::hasColumn('user_stats', 'total_quiz_attempts')) {
                $table->integer('total_quiz_attempts')->default(0)->after('total_quizzes_completed');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_stats', function (Blueprint $table) {
            $table->dropColumn('total_quiz_attempts');
        });
    }
};
