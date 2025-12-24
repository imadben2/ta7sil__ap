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
            $table->string('device_id')->nullable()->after('email');
            $table->string('phone')->nullable()->after('email');
            $table->integer('academic_phase_id')->nullable()->after('password');
            $table->integer('academic_year_id')->nullable()->after('academic_phase_id');
            $table->integer('stream_id')->nullable()->after('academic_year_id');

            $table->index('device_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['device_id']);
            $table->dropColumn([
                'device_id',
                'phone',
                'academic_phase_id',
                'academic_year_id',
                'stream_id'
            ]);
        });
    }
};
