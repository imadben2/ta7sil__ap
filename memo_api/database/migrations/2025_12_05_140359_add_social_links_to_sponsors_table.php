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
        Schema::table('sponsors', function (Blueprint $table) {
            // Social media links
            $table->string('youtube_link', 500)->nullable()->after('external_link');
            $table->string('facebook_link', 500)->nullable()->after('youtube_link');
            $table->string('instagram_link', 500)->nullable()->after('facebook_link');
            $table->string('telegram_link', 500)->nullable()->after('instagram_link');

            // Click counts per platform
            $table->unsignedInteger('youtube_clicks')->default(0)->after('click_count');
            $table->unsignedInteger('facebook_clicks')->default(0)->after('youtube_clicks');
            $table->unsignedInteger('instagram_clicks')->default(0)->after('facebook_clicks');
            $table->unsignedInteger('telegram_clicks')->default(0)->after('instagram_clicks');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sponsors', function (Blueprint $table) {
            $table->dropColumn([
                'youtube_link',
                'facebook_link',
                'instagram_link',
                'telegram_link',
                'youtube_clicks',
                'facebook_clicks',
                'instagram_clicks',
                'telegram_clicks',
            ]);
        });
    }
};
