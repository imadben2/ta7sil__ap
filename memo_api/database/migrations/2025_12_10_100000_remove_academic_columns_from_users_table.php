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
        Schema::table('users', function (Blueprint $table) {
            // Remove academic columns since data is stored in user_academic_profiles table
            if (Schema::hasColumn('users', 'academic_phase_id')) {
                $table->dropColumn('academic_phase_id');
            }
            if (Schema::hasColumn('users', 'academic_year_id')) {
                $table->dropColumn('academic_year_id');
            }
            if (Schema::hasColumn('users', 'stream_id')) {
                $table->dropColumn('stream_id');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('academic_phase_id')->nullable()->constrained('academic_phases')->nullOnDelete();
            $table->foreignId('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
            $table->foreignId('stream_id')->nullable()->constrained('academic_streams')->nullOnDelete();
        });
    }
};
