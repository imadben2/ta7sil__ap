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
        Schema::table('user_achievements', function (Blueprint $table) {
            if (!Schema::hasColumn('user_achievements', 'progress')) {
                $table->integer('progress')->default(0)->after('unlocked_at');
            }
            if (!Schema::hasColumn('user_achievements', 'updated_at')) {
                $table->timestamp('updated_at')->nullable()->after('created_at');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_achievements', function (Blueprint $table) {
            if (Schema::hasColumn('user_achievements', 'progress')) {
                $table->dropColumn('progress');
            }
            if (Schema::hasColumn('user_achievements', 'updated_at')) {
                $table->dropColumn('updated_at');
            }
        });
    }
};
