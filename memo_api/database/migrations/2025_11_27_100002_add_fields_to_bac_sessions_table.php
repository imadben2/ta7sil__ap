<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add missing fields from specification to bac_sessions table
     */
    public function up(): void
    {
        Schema::table('bac_sessions', function (Blueprint $table) {
            // Link to BAC year (optional FK to allow sessions to be year-specific)
            $table->foreignId('bac_year_id')->nullable()->after('id')->constrained('bac_years')->onDelete('set null');

            // Session type: main (June), makeup (September), foreign
            $table->enum('session_type', ['main', 'makeup', 'foreign'])->default('main')->after('slug');

            // Actual exam date for this session
            $table->date('exam_date')->nullable()->after('session_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bac_sessions', function (Blueprint $table) {
            $table->dropForeign(['bac_year_id']);
            $table->dropColumn([
                'bac_year_id',
                'session_type',
                'exam_date'
            ]);
        });
    }
};
