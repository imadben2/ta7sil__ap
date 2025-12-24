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
        Schema::table('user_content_progress', function (Blueprint $table) {
            // Add is_completed boolean column
            $table->boolean('is_completed')->default(false)->after('status');

            // Add started_at timestamp
            $table->timestamp('started_at')->nullable()->after('last_accessed_at');

            // Rename time_spent_minutes to time_spent_seconds
            $table->renameColumn('time_spent_minutes', 'time_spent_seconds');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_content_progress', function (Blueprint $table) {
            $table->dropColumn(['is_completed', 'started_at']);
            $table->renameColumn('time_spent_seconds', 'time_spent_minutes');
        });
    }
};
