<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Merges duplicate subjects (same name + academic_year) into single records.
     */
    public function up(): void
    {
        // Tables that reference subject_id
        $relatedTables = [
            'contents',
            'content_chapters',
            'quizzes',
            'bac_subjects',
            'bac_study_day_subjects',
        ];

        DB::transaction(function () use ($relatedTables) {
            // Step 1: Find all duplicate subject groups (same name + year)
            $duplicateGroups = DB::table('subjects')
                ->select('name_ar', 'academic_year_id', DB::raw('MIN(id) as master_id'))
                ->groupBy('name_ar', 'academic_year_id')
                ->havingRaw('COUNT(*) > 1')
                ->get();

            foreach ($duplicateGroups as $group) {
                // Get all subjects in this group
                $subjects = DB::table('subjects')
                    ->where('name_ar', $group->name_ar)
                    ->where('academic_year_id', $group->academic_year_id)
                    ->orderBy('id')
                    ->get();

                $masterId = $group->master_id;
                $allStreamIds = [];
                $duplicateIds = [];

                // Step 2: Create subject_stream records and collect stream IDs
                foreach ($subjects as $subject) {
                    $streamIds = json_decode($subject->academic_stream_ids, true) ?? [];

                    foreach ($streamIds as $streamId) {
                        // Check if record already exists
                        $exists = DB::table('subject_stream')
                            ->where('subject_id', $masterId)
                            ->where('academic_stream_id', $streamId)
                            ->exists();

                        if (!$exists) {
                            DB::table('subject_stream')->insert([
                                'subject_id' => $masterId,
                                'academic_stream_id' => $streamId,
                                'coefficient' => $subject->coefficient ?? 1,
                                'is_active' => $subject->is_active ?? true,
                                'created_at' => now(),
                                'updated_at' => now(),
                            ]);
                        }

                        $allStreamIds[] = $streamId;
                    }

                    if ($subject->id != $masterId) {
                        $duplicateIds[] = $subject->id;
                    }
                }

                // Step 3: Update master subject with all stream IDs
                $uniqueStreamIds = array_values(array_unique($allStreamIds));
                sort($uniqueStreamIds);

                DB::table('subjects')
                    ->where('id', $masterId)
                    ->update([
                        'academic_stream_ids' => json_encode($uniqueStreamIds),
                        'updated_at' => now(),
                    ]);

                // Step 4: Update foreign keys in related tables
                if (!empty($duplicateIds)) {
                    foreach ($relatedTables as $table) {
                        if (Schema::hasTable($table) && Schema::hasColumn($table, 'subject_id')) {
                            DB::table($table)
                                ->whereIn('subject_id', $duplicateIds)
                                ->update(['subject_id' => $masterId]);
                        }
                    }

                    // Step 5: Delete duplicate subjects
                    DB::table('subjects')
                        ->whereIn('id', $duplicateIds)
                        ->delete();
                }
            }

            // Step 6: Create subject_stream records for non-duplicate subjects
            $remainingSubjects = DB::table('subjects')
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('subject_stream')
                        ->whereRaw('subject_stream.subject_id = subjects.id');
                })
                ->get();

            foreach ($remainingSubjects as $subject) {
                $streamIds = json_decode($subject->academic_stream_ids, true) ?? [];

                foreach ($streamIds as $streamId) {
                    DB::table('subject_stream')->insert([
                        'subject_id' => $subject->id,
                        'academic_stream_id' => $streamId,
                        'coefficient' => $subject->coefficient ?? 1,
                        'is_active' => $subject->is_active ?? true,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        });
    }

    /**
     * Reverse the migrations.
     * This is a complex operation - we store backup data in subject_stream for rollback.
     */
    public function down(): void
    {
        // Note: Full rollback would require recreating the duplicate subjects
        // which is complex and risky. For safety, we only clear the pivot table.
        // Manual restoration from backup is recommended if rollback is needed.

        DB::table('subject_stream')->truncate();
    }
};
