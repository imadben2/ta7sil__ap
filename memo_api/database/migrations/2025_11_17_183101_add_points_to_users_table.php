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
        Schema::table('users', function (Blueprint $table) {
            $table->integer('total_points')->default(0)->after('remember_token');
            $table->integer('current_level')->default(1)->after('total_points');
            $table->integer('points_to_next_level')->default(100)->after('current_level');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['total_points', 'current_level', 'points_to_next_level']);
        });
    }
};
