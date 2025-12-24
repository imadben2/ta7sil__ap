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
        Schema::create('bac_subject_bookmarks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('bac_subject_id')->constrained()->onDelete('cascade');
            $table->integer('page_number')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            // Each user can only bookmark a bac_subject once
            $table->unique(['user_id', 'bac_subject_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bac_subject_bookmarks');
    }
};
