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
        Schema::table('payment_receipts', function (Blueprint $table) {
            // Add missing columns
            if (!Schema::hasColumn('payment_receipts', 'package_id')) {
                $table->foreignId('package_id')->nullable()->after('course_id')->constrained('subscription_packages')->onDelete('cascade');
            }
            if (!Schema::hasColumn('payment_receipts', 'transaction_reference')) {
                $table->string('transaction_reference')->nullable()->after('payment_method');
            }
            if (!Schema::hasColumn('payment_receipts', 'user_notes')) {
                $table->text('user_notes')->nullable()->after('transaction_reference');
            }
            if (!Schema::hasColumn('payment_receipts', 'admin_notes')) {
                $table->text('admin_notes')->nullable()->after('status');
            }
            if (!Schema::hasColumn('payment_receipts', 'rejection_reason')) {
                $table->text('rejection_reason')->nullable()->after('admin_notes');
            }
            if (!Schema::hasColumn('payment_receipts', 'submitted_at')) {
                $table->timestamp('submitted_at')->useCurrent()->after('reviewed_at');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payment_receipts', function (Blueprint $table) {
            $columns = ['package_id', 'transaction_reference', 'user_notes', 'admin_notes', 'rejection_reason', 'submitted_at'];
            foreach ($columns as $column) {
                if (Schema::hasColumn('payment_receipts', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
