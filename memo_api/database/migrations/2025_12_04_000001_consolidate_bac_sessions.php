<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Consolidate BAC sessions to be global (not year-specific)
     * Make "الدورة العادية" a single session shared across all years
     */
    public function up(): void
    {
        // Step 1: Define the canonical sessions we want to keep
        $canonicalSessions = [
            ['name_ar' => 'الدورة العادية', 'slug' => 'normal', 'session_type' => 'main'],
            ['name_ar' => 'دورة الاستدراك', 'slug' => 'makeup', 'session_type' => 'makeup'],
        ];

        // Step 2: For each canonical session, ensure it exists and merge duplicates
        foreach ($canonicalSessions as $sessionData) {
            // Check if this session exists
            $existing = DB::table('bac_sessions')
                ->where('slug', $sessionData['slug'])
                ->first();

            if (!$existing) {
                // Create it if it doesn't exist
                DB::table('bac_sessions')->insert([
                    'name_ar' => $sessionData['name_ar'],
                    'slug' => $sessionData['slug'],
                    'session_type' => $sessionData['session_type'],
                    'bac_year_id' => null,
                    'exam_date' => null,
                ]);
            } else {
                // Update to canonical name if needed
                DB::table('bac_sessions')
                    ->where('id', $existing->id)
                    ->update([
                        'name_ar' => $sessionData['name_ar'],
                        'session_type' => $sessionData['session_type'],
                        'bac_year_id' => null,
                    ]);
            }
        }

        // Step 3: Handle "june" slug - merge it into "normal" if both exist
        $juneSession = DB::table('bac_sessions')->where('slug', 'june')->first();
        $normalSession = DB::table('bac_sessions')->where('slug', 'normal')->first();

        if ($juneSession && $normalSession && $juneSession->id !== $normalSession->id) {
            // Update all bac_subjects referencing "june" to use "normal"
            DB::table('bac_subjects')
                ->where('bac_session_id', $juneSession->id)
                ->update(['bac_session_id' => $normalSession->id]);

            // Delete the duplicate "june" session
            DB::table('bac_sessions')->where('id', $juneSession->id)->delete();
        } elseif ($juneSession && !$normalSession) {
            // Rename "june" to "normal"
            DB::table('bac_sessions')
                ->where('id', $juneSession->id)
                ->update([
                    'name_ar' => 'الدورة العادية',
                    'slug' => 'normal',
                    'session_type' => 'main',
                    'bac_year_id' => null,
                ]);
        }

        // Step 4: Handle "september" slug - merge it into "makeup" if both exist
        $septemberSession = DB::table('bac_sessions')->where('slug', 'september')->first();
        $makeupSession = DB::table('bac_sessions')->where('slug', 'makeup')->first();

        if ($septemberSession && $makeupSession && $septemberSession->id !== $makeupSession->id) {
            // Update all bac_subjects referencing "september" to use "makeup"
            DB::table('bac_subjects')
                ->where('bac_session_id', $septemberSession->id)
                ->update(['bac_session_id' => $makeupSession->id]);

            // Delete the duplicate "september" session
            DB::table('bac_sessions')->where('id', $septemberSession->id)->delete();
        } elseif ($septemberSession && !$makeupSession) {
            // Rename "september" to "makeup"
            DB::table('bac_sessions')
                ->where('id', $septemberSession->id)
                ->update([
                    'name_ar' => 'دورة الاستدراك',
                    'slug' => 'makeup',
                    'session_type' => 'makeup',
                    'bac_year_id' => null,
                ]);
        }

        // Step 5: Handle "exceptional" - keep it or merge based on your needs
        $exceptionalSession = DB::table('bac_sessions')->where('slug', 'exceptional')->first();
        if ($exceptionalSession) {
            // Keep it but ensure bac_year_id is null
            DB::table('bac_sessions')
                ->where('id', $exceptionalSession->id)
                ->update(['bac_year_id' => null]);
        }

        // Step 6: Set all remaining sessions' bac_year_id to null
        DB::table('bac_sessions')->update(['bac_year_id' => null]);

        // Step 7: Remove the bac_year_id column from bac_sessions
        Schema::table('bac_sessions', function (Blueprint $table) {
            $table->dropForeign(['bac_year_id']);
            $table->dropColumn('bac_year_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Re-add the bac_year_id column
        Schema::table('bac_sessions', function (Blueprint $table) {
            $table->foreignId('bac_year_id')
                ->nullable()
                ->after('id')
                ->constrained('bac_years')
                ->onDelete('set null');
        });
    }
};
