<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Sponsors table for "هاد التطبيق برعاية" section
     * Tracks teachers/professors who sponsor the app
     */
    public function up(): void
    {
        Schema::create('sponsors', function (Blueprint $table) {
            $table->id();
            $table->string('name_ar');                          // Arabic name (e.g., "أ. محمد")
            $table->string('photo_url');                        // Photo URL
            $table->string('external_link');                    // YouTube/Facebook/etc link
            $table->string('title')->nullable();                // e.g., "أستاذ الرياضيات"
            $table->string('specialty')->nullable();            // e.g., "الرياضيات"
            $table->unsignedBigInteger('click_count')->default(0);  // Track clicks
            $table->boolean('is_active')->default(true);        // Active/visible status
            $table->unsignedInteger('display_order')->default(0);   // Display order (lower = first)
            $table->timestamps();

            // Index for efficient queries
            $table->index(['is_active', 'display_order']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sponsors');
    }
};
