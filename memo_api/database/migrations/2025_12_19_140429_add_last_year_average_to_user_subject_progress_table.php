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
        Schema::table('user_subject_progress', function (Blueprint $table) {
            $table->decimal('last_year_average', 4, 2)
                ->nullable()
                ->after('average_score')
                ->comment('معدل السنة الماضية (0-20 scale)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_subject_progress', function (Blueprint $table) {
            $table->dropColumn('last_year_average');
        });
    }
};
