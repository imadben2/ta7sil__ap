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
        // Check if the column 'used_count' exists, and rename it to 'current_uses'
        if (Schema::hasColumn('subscription_codes', 'used_count')) {
            Schema::table('subscription_codes', function (Blueprint $table) {
                $table->renameColumn('used_count', 'current_uses');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Rename back to used_count
        if (Schema::hasColumn('subscription_codes', 'current_uses')) {
            Schema::table('subscription_codes', function (Blueprint $table) {
                $table->renameColumn('current_uses', 'used_count');
            });
        }
    }
};
