<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Clean up all duplicate BAC sessions and keep only 2 global sessions
     */
    public function up(): void
    {
        // Step 1: Ensure we have the canonical "normal" session (ID 20 based on current data)
        $normalSession = DB::table('bac_sessions')->where('slug', 'normal')->first();
        $makeupSession = DB::table('bac_sessions')->where('slug', 'makeup')->first();

        if (!$normalSession) {
            // Create it if it doesn't exist
            $normalId = DB::table('bac_sessions')->insertGetId([
                'name_ar' => 'الدورة العادية',
                'slug' => 'normal',
                'session_type' => 'main',
                'exam_date' => null,
            ]);
        } else {
            $normalId = $normalSession->id;
            // Update to ensure correct name
            DB::table('bac_sessions')
                ->where('id', $normalId)
                ->update([
                    'name_ar' => 'الدورة العادية',
                    'session_type' => 'main',
                ]);
        }

        if (!$makeupSession) {
            $makeupId = DB::table('bac_sessions')->insertGetId([
                'name_ar' => 'دورة الاستدراك',
                'slug' => 'makeup',
                'session_type' => 'makeup',
                'exam_date' => null,
            ]);
        } else {
            $makeupId = $makeupSession->id;
            // Update to ensure correct name
            DB::table('bac_sessions')
                ->where('id', $makeupId)
                ->update([
                    'name_ar' => 'دورة الاستدراك',
                    'session_type' => 'makeup',
                ]);
        }

        // Step 2: Get all "main" type sessions that are NOT the canonical "normal" one
        $duplicateMainSessions = DB::table('bac_sessions')
            ->where('session_type', 'main')
            ->where('id', '!=', $normalId)
            ->pluck('id')
            ->toArray();

        // Step 3: Update all bac_subjects referencing duplicate sessions to use the canonical one
        if (!empty($duplicateMainSessions)) {
            DB::table('bac_subjects')
                ->whereIn('bac_session_id', $duplicateMainSessions)
                ->update(['bac_session_id' => $normalId]);
        }

        // Step 4: Get all "makeup" type sessions that are NOT the canonical one
        // Also include sessions like "regular-session" and "makeup-session"
        $duplicateMakeupSessions = DB::table('bac_sessions')
            ->where('session_type', 'makeup')
            ->where('id', '!=', $makeupId)
            ->pluck('id')
            ->toArray();

        // Handle the "makeup-session" slug specifically
        $makeupSessionOld = DB::table('bac_sessions')->where('slug', 'makeup-session')->first();
        if ($makeupSessionOld && $makeupSessionOld->id != $makeupId) {
            $duplicateMakeupSessions[] = $makeupSessionOld->id;
        }

        if (!empty($duplicateMakeupSessions)) {
            DB::table('bac_subjects')
                ->whereIn('bac_session_id', $duplicateMakeupSessions)
                ->update(['bac_session_id' => $makeupId]);
        }

        // Step 5: Handle "regular-session" - merge into normal
        $regularSession = DB::table('bac_sessions')->where('slug', 'regular-session')->first();
        if ($regularSession && $regularSession->id != $normalId) {
            DB::table('bac_subjects')
                ->where('bac_session_id', $regularSession->id)
                ->update(['bac_session_id' => $normalId]);
        }

        // Step 6: Delete all duplicate sessions (keep only normal and makeup)
        DB::table('bac_sessions')
            ->whereNotIn('id', [$normalId, $makeupId])
            ->delete();

        // Step 7: Verify final state
        $finalCount = DB::table('bac_sessions')->count();
        if ($finalCount != 2) {
            throw new \Exception("Expected 2 sessions after cleanup, got {$finalCount}");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Cannot reliably reverse data cleanup
        // The sessions structure remains the same
    }
};
