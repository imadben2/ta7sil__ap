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
            // allowed_video_type: 'youtube', 'upload', 'both'
            $table->enum('allowed_video_type', ['youtube', 'upload', 'both'])
                  ->default('both')
                  ->after('trailer_video_type')
                  ->comment('Allowed video type for lessons: youtube, upload, or both');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('courses', function (Blueprint $table) {
            $table->dropColumn('allowed_video_type');
        });
    }
};
