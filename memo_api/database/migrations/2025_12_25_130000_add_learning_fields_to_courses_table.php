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
        Schema::table('courses', function (Blueprint $table) {
            // Learning content fields - stored as JSON for multiple items
            $table->json('what_you_will_learn')->nullable()->after('short_description_ar');
            $table->json('requirements')->nullable()->after('what_you_will_learn');
            $table->json('target_audience')->nullable()->after('requirements');

            // Certificate availability
            $table->boolean('certificate_available')->default(true)->after('is_featured');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('courses', function (Blueprint $table) {
            $table->dropColumn([
                'what_you_will_learn',
                'requirements',
                'target_audience',
                'certificate_available',
            ]);
        });
    }
};
