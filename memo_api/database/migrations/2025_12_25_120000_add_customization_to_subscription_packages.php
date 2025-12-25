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
        Schema::table('subscription_packages', function (Blueprint $table) {
            $table->string('image_url')->nullable()->after('description_ar');
            $table->string('badge_text', 100)->nullable()->after('image_url');
            $table->string('background_color', 7)->nullable()->after('badge_text');
            $table->boolean('is_featured')->default(false)->after('is_active');
            $table->integer('sort_order')->default(0)->after('is_featured');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription_packages', function (Blueprint $table) {
            $table->dropColumn(['image_url', 'badge_text', 'background_color', 'is_featured', 'sort_order']);
        });
    }
};
