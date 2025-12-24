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
        Schema::create('bac_weekly_rewards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('academic_stream_id')->constrained()->onDelete('cascade');
            $table->integer('week_number'); // 1-14
            $table->string('title_ar');
            $table->text('description_ar')->nullable();
            $table->string('movie_title')->nullable();
            $table->string('movie_image')->nullable();
            $table->timestamps();

            $table->unique(['academic_stream_id', 'week_number']);
            $table->index('academic_stream_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_weekly_rewards');
    }
};
