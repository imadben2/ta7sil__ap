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
        Schema::create('bac_study_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('academic_stream_id')->constrained()->onDelete('cascade');
            $table->integer('day_number'); // 1-98
            $table->enum('day_type', ['study', 'review', 'reward'])->default('study');
            $table->string('title_ar')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['academic_stream_id', 'day_number']);
            $table->index(['academic_stream_id', 'day_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_study_days');
    }
};
