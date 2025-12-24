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
        Schema::create('device_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Device Information
            $table->string('device_name'); // e.g., "iPhone 12 Pro"
            $table->string('device_type'); // mobile, tablet, web
            $table->string('device_os'); // iOS, Android, Web
            $table->string('os_version')->nullable(); // e.g., "15.2"
            $table->string('app_version')->nullable(); // e.g., "1.2.3"

            // Session Information
            $table->string('token_id')->unique(); // Sanctum token ID or session ID
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->string('location')->nullable(); // e.g., "Cairo, Egypt"
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();

            // Status
            $table->boolean('is_current')->default(false); // Current device
            $table->timestamp('last_active_at')->nullable();
            $table->timestamp('expires_at')->nullable();

            $table->timestamps();

            // Indexes
            $table->index('user_id');
            $table->index('token_id');
            $table->index('is_current');
            $table->index('last_active_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('device_sessions');
    }
};
