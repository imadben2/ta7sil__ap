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
        Schema::create('certificates', function (Blueprint $table) {
            $table->id();
            $table->string('certificate_number', 20)->unique(); // CERT-XXXXXX

            // Relationships
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('course_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_course_progress_id')->nullable()->constrained('user_course_progress')->onDelete('set null');

            // Certificate data (stored for historical purposes)
            $table->string('student_name');
            $table->string('course_title');
            $table->string('instructor_name')->nullable();
            $table->date('completion_date');
            $table->decimal('average_score', 5, 2)->nullable(); // Quiz average if applicable

            // Files
            $table->string('pdf_path', 500)->nullable();
            $table->string('pdf_url', 500)->nullable();
            $table->text('qr_code_data')->nullable();

            // Verification
            $table->string('verification_url', 500)->nullable();
            $table->boolean('is_verified')->default(true);
            $table->timestamp('revoked_at')->nullable();
            $table->text('revocation_reason')->nullable();

            // Issue date
            $table->timestamp('issued_at')->useCurrent();

            $table->timestamps();

            // Indexes
            $table->unique(['user_id', 'course_id']); // One certificate per user per course
            $table->index('certificate_number');
            $table->index('issued_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('certificates');
    }
};
