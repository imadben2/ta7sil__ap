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
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code', 50)->unique();

            // Discount configuration
            $table->enum('discount_type', ['percentage', 'fixed'])->default('percentage');
            $table->decimal('discount_value', 10, 2); // 15 for 15%, or 750 for fixed
            $table->integer('min_purchase_amount')->default(0);
            $table->integer('max_discount_amount')->nullable(); // Cap for percentage discounts

            // Usage limits
            $table->integer('max_uses')->nullable(); // NULL = unlimited
            $table->integer('max_uses_per_user')->default(1);
            $table->integer('current_uses')->default(0);

            // Validity period
            $table->timestamp('valid_from')->nullable();
            $table->timestamp('valid_until')->nullable();
            $table->boolean('is_active')->default(true);

            // Restrictions (JSON arrays for flexibility)
            $table->json('course_ids')->nullable(); // NULL = all courses, [1,2,3] = specific
            $table->json('package_ids')->nullable();
            $table->json('user_ids')->nullable(); // For user-specific coupons
            $table->boolean('first_purchase_only')->default(false);

            // Audit
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();

            // Indexes
            $table->index('code');
            $table->index(['is_active', 'valid_until']);
        });

        // Coupon usages tracking table
        Schema::create('coupon_usages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('coupon_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('order_id')->nullable(); // FK added later after orders table exists
            $table->integer('discount_applied_dzd');
            $table->timestamp('used_at')->useCurrent();
            $table->timestamps();

            // Indexes
            $table->index(['coupon_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coupon_usages');
        Schema::dropIfExists('coupons');
    }
};
