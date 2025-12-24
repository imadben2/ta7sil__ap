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
            $table->enum('role', ['admin', 'teacher', 'student'])->default('student')->after('password');
            $table->string('device_uuid')->nullable()->unique()->after('role');
            $table->string('device_name')->nullable()->after('device_uuid');
            $table->timestamp('device_last_seen')->nullable()->after('device_name');
            $table->boolean('is_active')->default(true)->after('device_last_seen');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'role',
                'device_uuid',
                'device_name',
                'device_last_seen',
                'is_active'
            ]);
        });
    }
};
