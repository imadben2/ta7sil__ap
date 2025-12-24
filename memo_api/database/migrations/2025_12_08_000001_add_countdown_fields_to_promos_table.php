<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Add countdown support to promos table for exam countdown displays
     */
    public function up(): void
    {
        Schema::table('promos', function (Blueprint $table) {
            // Promo type: 'default' for regular promos, 'countdown' for countdown timer
            $table->string('promo_type')->default('default')->after('is_active');

            // Target date for countdown (e.g., exam date)
            $table->timestamp('target_date')->nullable()->after('promo_type');

            // Custom label for countdown (e.g., "يوم على البكالوريا")
            $table->string('countdown_label')->nullable()->after('target_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('promos', function (Blueprint $table) {
            $table->dropColumn(['promo_type', 'target_date', 'countdown_label']);
        });
    }
};
