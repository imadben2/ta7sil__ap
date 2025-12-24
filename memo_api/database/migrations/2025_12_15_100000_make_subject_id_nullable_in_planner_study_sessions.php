<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Makes subject_id nullable to allow break sessions without a subject.
     */
    public function up(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            // Drop the foreign key constraint first
            $table->dropForeign(['subject_id']);

            // Modify the column to be nullable
            $table->unsignedBigInteger('subject_id')->nullable()->change();

            // Re-add the foreign key constraint
            $table->foreign('subject_id')
                ->references('id')
                ->on('subjects')
                ->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            // Drop the foreign key constraint
            $table->dropForeign(['subject_id']);

            // Make subject_id required again (this may fail if there are null values)
            $table->unsignedBigInteger('subject_id')->nullable(false)->change();

            // Re-add the foreign key constraint
            $table->foreign('subject_id')
                ->references('id')
                ->on('subjects');
        });
    }
};
