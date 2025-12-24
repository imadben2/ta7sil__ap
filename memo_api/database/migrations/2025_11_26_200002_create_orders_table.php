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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number', 50)->unique(); // ORD-XXXXXX
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // What is being purchased
            $table->foreignId('course_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('package_id')->nullable()->constrained('subscription_packages')->onDelete('set null');

            // Pricing
            $table->integer('subtotal_dzd'); // Original price
            $table->integer('discount_dzd')->default(0); // Coupon discount
            $table->integer('total_dzd'); // Final price after discount
            $table->foreignId('coupon_id')->nullable()->constrained()->onDelete('set null');

            // Payment info
            $table->enum('payment_method', ['baridimob', 'ccp', 'credit_card', 'code', 'receipt'])->default('baridimob');
            $table->string('payment_reference')->nullable(); // External payment reference
            $table->string('payment_url', 500)->nullable(); // Payment gateway URL

            // Status tracking
            $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'cancelled', 'expired', 'refunded'])->default('pending');
            $table->timestamp('expires_at')->nullable(); // For pending orders
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamp('refunded_at')->nullable();

            // Metadata
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->json('metadata')->nullable(); // For additional data
            $table->text('notes')->nullable(); // Admin notes

            $table->timestamps();

            // Indexes
            $table->index('order_number');
            $table->index('user_id');
            $table->index('status');
            $table->index('created_at');
        });

        // Add foreign key to coupon_usages table now that orders table exists
        Schema::table('coupon_usages', function (Blueprint $table) {
            $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop foreign key from coupon_usages first
        Schema::table('coupon_usages', function (Blueprint $table) {
            $table->dropForeign(['order_id']);
        });

        Schema::dropIfExists('orders');
    }
};
