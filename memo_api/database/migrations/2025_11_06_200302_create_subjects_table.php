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
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('academic_stream_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('academic_year_id')->constrained()->onDelete('cascade');
            $table->string('name_ar'); // الرياضيات، الفيزياء...
            $table->string('slug');
            $table->text('description_ar')->nullable();
            $table->string('color')->nullable(); // #FF5733
            $table->string('icon')->nullable();
            $table->decimal('coefficient', 3, 1); // معامل المادة
            $table->integer('order');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['academic_stream_id', 'academic_year_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};
