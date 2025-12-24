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
        // Only add column if it doesn't already exist
        if (!Schema::hasColumn('quizzes', 'academic_stream_id')) {
            Schema::table('quizzes', function (Blueprint $table) {
                // Add column without FK constraint (academic_streams uses MyISAM which doesn't support FK)
                $table->unsignedBigInteger('academic_stream_id')->nullable()->after('subject_id');
                $table->index('academic_stream_id');
            });

            // Populate academic_stream_id from associated subject
            \App\Models\Quiz::whereNull('academic_stream_id')
                ->whereHas('subject', fn($q) => $q->whereNotNull('academic_stream_id'))
                ->each(function ($quiz) {
                    $quiz->update(['academic_stream_id' => $quiz->subject->academic_stream_id]);
                });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropIndex(['academic_stream_id']);
            $table->dropColumn('academic_stream_id');
        });
    }
};
