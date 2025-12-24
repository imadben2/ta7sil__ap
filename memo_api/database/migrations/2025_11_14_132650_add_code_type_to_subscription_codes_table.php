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
        Schema::table('subscription_codes', function (Blueprint $table) {
            $table->enum('code_type', ['single_course', 'package'])
                ->after('code')
                ->default('single_course')
                ->comment('Type of subscription code: single course or package');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription_codes', function (Blueprint $table) {
            $table->dropColumn('code_type');
        });
    }
};
