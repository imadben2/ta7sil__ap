<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Adds academic_stream_id to contents and content_chapters tables
     * to allow filtering content by academic stream.
     *
     * - When academic_stream_id is set: content is specific to that stream
     * - When academic_stream_id is null: content is shared across all streams
     */
    public function up(): void
    {
        // Add academic_stream_id to contents table if not exists
        // Note: Using unsignedBigInteger without FK constraint because academic_streams uses MyISAM
        if (!Schema::hasColumn('contents', 'academic_stream_id')) {
            Schema::table('contents', function (Blueprint $table) {
                $table->unsignedBigInteger('academic_stream_id')
                    ->nullable()
                    ->after('subject_id');
            });
        }

        // Add index if not exists (use try-catch to handle existing index)
        try {
            Schema::table('contents', function (Blueprint $table) {
                $table->index(['subject_id', 'academic_stream_id'], 'idx_contents_subject_stream');
            });
        } catch (\Exception $e) {
            // Index already exists, ignore
        }

        // Add academic_stream_id to content_chapters table if not exists
        // Note: Using unsignedBigInteger without FK constraint because academic_streams uses MyISAM
        if (!Schema::hasColumn('content_chapters', 'academic_stream_id')) {
            Schema::table('content_chapters', function (Blueprint $table) {
                $table->unsignedBigInteger('academic_stream_id')
                    ->nullable()
                    ->after('subject_id');
            });
        }

        // Add index if not exists (use try-catch to handle existing index)
        try {
            Schema::table('content_chapters', function (Blueprint $table) {
                $table->index(['subject_id', 'academic_stream_id'], 'idx_chapters_subject_stream');
            });
        } catch (\Exception $e) {
            // Index already exists, ignore
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('contents', function (Blueprint $table) {
            $table->dropIndex('idx_contents_subject_stream');
            $table->dropColumn('academic_stream_id');
        });

        Schema::table('content_chapters', function (Blueprint $table) {
            $table->dropIndex('idx_chapters_subject_stream');
            $table->dropColumn('academic_stream_id');
        });
    }
};
