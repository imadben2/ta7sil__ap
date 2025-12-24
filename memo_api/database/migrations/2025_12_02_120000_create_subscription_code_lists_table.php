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
        Schema::create('subscription_code_lists', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code_type'); // single_course, package, general
            $table->foreignId('course_id')->nullable()->constrained()->onDelete('cascade');
            $table->foreignId('package_id')->nullable()->constrained('subscription_packages')->onDelete('cascade');
            $table->integer('total_codes')->default(0);
            $table->integer('max_uses_per_code')->default(1);
            $table->datetime('expires_at')->nullable();
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();

            // Indexes for better query performance
            $table->index(['code_type', 'created_by']);
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscription_code_lists');
    }
};
