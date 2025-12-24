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
            $table->foreignId('list_id')->nullable()->after('id')
                ->constrained('subscription_code_lists')
                ->onDelete('set null');

            $table->index('list_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription_codes', function (Blueprint $table) {
            $table->dropForeign(['list_id']);
            $table->dropIndex(['list_id']);
            $table->dropColumn('list_id');
        });
    }
};
