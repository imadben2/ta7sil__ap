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
        Schema::table('subject_priorities', function (Blueprint $table) {
            $table->decimal('historical_performance_gap_score', 5, 2)
                ->default(0)
                ->after('performance_gap_score')
                ->comment('Score based on last year average (0-10)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subject_priorities', function (Blueprint $table) {
            $table->dropColumn('historical_performance_gap_score');
        });
    }
};
