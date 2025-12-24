<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Promos table for dynamic promotional slider on home page
     * Supports various action types (route, url, none) and custom gradients
     */
    public function up(): void
    {
        Schema::create('promos', function (Blueprint $table) {
            $table->id();
            $table->string('title');                              // Promo title (Arabic)
            $table->string('subtitle')->nullable();               // Optional subtitle
            $table->string('badge')->nullable();                  // Badge text (e.g., "جديد", "تحدي")
            $table->string('action_text')->nullable();            // Button text (e.g., "اكتشف الآن")
            $table->string('icon_name')->nullable();              // Flutter icon name (e.g., "school")
            $table->string('image_url')->nullable();              // Optional image URL
            $table->json('gradient_colors')->nullable();          // Array of hex colors ["#2196F3", "#1565C0"]
            $table->enum('action_type', ['route', 'url', 'none'])->default('none');  // Action type
            $table->string('action_value')->nullable();           // Route path or external URL
            $table->unsignedBigInteger('click_count')->default(0);  // Track clicks for analytics
            $table->unsignedInteger('display_order')->default(0);   // Display order (lower = first)
            $table->boolean('is_active')->default(true);          // Active/visible status
            $table->timestamp('starts_at')->nullable();           // Optional start date
            $table->timestamp('ends_at')->nullable();             // Optional end date
            $table->timestamps();

            // Indexes for efficient queries
            $table->index(['is_active', 'display_order']);
            $table->index(['starts_at', 'ends_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('promos');
    }
};
