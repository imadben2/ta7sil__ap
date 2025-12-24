<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Sync contents.academic_stream_id from subjects.academic_stream_ids
     */
    public function up(): void
    {
        // Get all contents with their subjects
        $contents = DB::table('contents')
            ->join('subjects', 'contents.subject_id', '=', 'subjects.id')
            ->select('contents.id', 'contents.academic_stream_id', 'subjects.academic_stream_ids')
            ->get();

        foreach ($contents as $content) {
            // Parse the academic_stream_ids JSON array
            $streamIds = json_decode($content->academic_stream_ids, true);

            // If subject has stream(s), use the first one for content
            // (or keep existing if content already has one)
            if (!empty($streamIds) && empty($content->academic_stream_id)) {
                DB::table('contents')
                    ->where('id', $content->id)
                    ->update(['academic_stream_id' => $streamIds[0]]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Set academic_stream_id to null (optional rollback)
        // We don't actually want to lose data, so this is a no-op
    }
};
