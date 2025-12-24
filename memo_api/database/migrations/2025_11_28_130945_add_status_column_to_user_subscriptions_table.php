<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('user_subscriptions', function (Blueprint $table) {
            $table->enum('status', ['active', 'expired', 'cancelled'])->default('active')->after('is_active');
            $table->datetime('started_at')->nullable()->after('expires_at');
        });

        // Migrate existing data: set status based on is_active and expires_at
        DB::statement("
            UPDATE user_subscriptions
            SET status = CASE
                WHEN is_active = 1 AND (expires_at IS NULL OR expires_at > NOW()) THEN 'active'
                WHEN expires_at <= NOW() THEN 'expired'
                ELSE 'cancelled'
            END,
            started_at = COALESCE(activated_at, created_at)
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_subscriptions', function (Blueprint $table) {
            $table->dropColumn(['status', 'started_at']);
        });
    }
};
