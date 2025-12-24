<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Creates the subject_stream pivot table to store stream-specific data like coefficient.
     */
    public function up(): void
    {
        Schema::create('subject_stream', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('subject_id');
            $table->unsignedBigInteger('academic_stream_id');
            $table->decimal('coefficient', 3, 1)->default(1);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            // Unique constraint - one subject per stream
            $table->unique(['subject_id', 'academic_stream_id'], 'subject_stream_unique');

            // Indexes for performance
            $table->index('subject_id');
            $table->index('academic_stream_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subject_stream');
    }
};
