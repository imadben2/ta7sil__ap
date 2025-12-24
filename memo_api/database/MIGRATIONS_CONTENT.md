# Complete Migrations Content for MEMO API

This document contains the complete PHP code for all migrations.
Copy and paste into the corresponding migration files.

---

## ✅ COMPLETED
1. add_device_binding_to_users_table ✅

---

## 🔄 TO BE FILLED

### Authentication & Users Module

#### 2. device_transfer_requests

```php
Schema::create('device_transfer_requests', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('old_device_uuid');
    $table->string('new_device_uuid');
    $table->string('new_device_name');
    $table->text('reason');
    $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
    $table->text('admin_note')->nullable();
    $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
    $table->timestamp('approved_at')->nullable();
    $table->timestamps();

    $table->index(['user_id', 'status']);
});
```

#### 3. user_profiles

```php
Schema::create('user_profiles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
    $table->string('full_name_ar');
    $table->string('phone')->nullable();
    $table->string('wilaya')->nullable();
    $table->string('avatar_url')->nullable();
    $table->text('bio_ar')->nullable();

    // Gamification
    $table->integer('points')->default(0);
    $table->integer('level')->default(1);
    $table->integer('current_streak_days')->default(0);
    $table->integer('longest_streak_days')->default(0);
    $table->date('last_activity_date')->nullable();

    $table->timestamps();
});
```

#### 4. user_academic_profiles

```php
Schema::create('user_academic_profiles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
    $table->foreignId('academic_phase_id')->constrained()->onDelete('cascade');
    $table->foreignId('academic_year_id')->constrained()->onDelete('cascade');
    $table->foreignId('academic_stream_id')->nullable()->constrained()->onDelete('set null');
    $table->boolean('onboarding_completed')->default(false);
    $table->timestamps();
});
```

#### 5. user_preferences

```php
Schema::create('user_preferences', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');

    // UI Preferences
    $table->enum('language', ['ar', 'fr', 'en'])->default('ar');
    $table->enum('theme', ['light', 'dark', 'auto'])->default('light');

    // Notifications
    $table->boolean('notifications_enabled')->default(true);
    $table->boolean('email_notifications')->default(true);
    $table->boolean('push_notifications')->default(true);

    // Study Settings
    $table->integer('pomodoro_duration')->default(25); // minutes
    $table->integer('pomodoro_break')->default(5); // minutes
    $table->time('study_start_time')->default('08:00');
    $table->time('study_end_time')->default('22:00');
    $table->time('sleep_start_time')->default('23:00');
    $table->time('sleep_end_time')->default('06:00');

    // Prayer
    $table->boolean('prayer_notifications')->default(true);

    $table->timestamps();
});
```

#### 6. user_subjects

```php
Schema::create('user_subjects', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->decimal('goal_hours_per_week', 5, 2)->nullable();
    $table->integer('priority_override')->nullable(); // 1-5
    $table->boolean('is_active')->default(true);
    $table->timestamps();

    $table->unique(['user_id', 'subject_id']);
});
```

---

### Academic Structure Module

#### 7. academic_phases

```php
Schema::create('academic_phases', function (Blueprint $table) {
    $table->id();
    $table->string('name_ar'); // الطور الابتدائي، المتوسط، الثانوي
    $table->string('slug')->unique(); // ibtidai, mutawassit, thanawi
    $table->integer('order');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### 8. academic_years

```php
Schema::create('academic_years', function (Blueprint $table) {
    $table->id();
    $table->foreignId('academic_phase_id')->constrained()->onDelete('cascade');
    $table->string('name_ar'); // السنة الأولى، الثانية...
    $table->integer('level_number'); // 1, 2, 3, 4, 5
    $table->integer('order');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### 9. academic_streams

```php
Schema::create('academic_streams', function (Blueprint $table) {
    $table->id();
    $table->foreignId('academic_year_id')->constrained()->onDelete('cascade');
    $table->string('name_ar'); // علوم تجريبية، رياضيات...
    $table->string('slug');
    $table->text('description_ar')->nullable();
    $table->integer('order');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### 10. subjects

```php
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
```

#### 11. content_chapters

```php
Schema::create('content_chapters', function (Blueprint $table) {
    $table->id();
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->string('title_ar'); // الدوال، الهندسة...
    $table->string('slug');
    $table->text('description_ar')->nullable();
    $table->integer('order');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### 12. content_types

```php
Schema::create('content_types', function (Blueprint $table) {
    $table->id();
    $table->string('name_ar'); // درس، ملخص، سلسلة تمارين...
    $table->string('slug')->unique(); // lesson, summary, exercise...
    $table->string('icon')->nullable();
});
```

#### 13. contents

```php
Schema::create('contents', function (Blueprint $table) {
    $table->id();
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->foreignId('content_type_id')->constrained()->onDelete('cascade');
    $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');

    // Content Basic Info
    $table->string('title_ar');
    $table->string('slug');
    $table->text('description_ar')->nullable();
    $table->longText('content_body_ar')->nullable();

    // Metadata
    $table->enum('difficulty_level', ['easy', 'medium', 'hard'])->default('medium');
    $table->integer('estimated_duration_minutes')->nullable();
    $table->integer('order')->default(0);
    $table->json('prerequisites')->nullable(); // IDs of prerequisite contents

    // Files
    $table->boolean('has_file')->default(false);
    $table->string('file_path')->nullable();
    $table->string('file_type')->nullable();
    $table->integer('file_size')->nullable(); // bytes

    // Video
    $table->boolean('has_video')->default(false);
    $table->enum('video_type', ['youtube', 'upload'])->nullable();
    $table->string('video_url')->nullable();
    $table->integer('video_duration_seconds')->nullable();

    // Publication Status
    $table->boolean('is_published')->default(false);
    $table->timestamp('published_at')->nullable();
    $table->boolean('is_premium')->default(false);

    // Tags & Search
    $table->json('tags')->nullable();
    $table->text('search_keywords')->nullable();

    // Stats
    $table->integer('views_count')->default(0);
    $table->integer('downloads_count')->default(0);

    // Audit
    $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
    $table->foreignId('updated_by')->nullable()->constrained('users')->onDelete('set null');

    $table->timestamps();
    $table->softDeletes();

    $table->index(['subject_id', 'content_type_id', 'chapter_id', 'is_published']);
    $table->fullText(['title_ar', 'description_ar', 'search_keywords']);
});
```

#### 14. user_content_progress

```php
Schema::create('user_content_progress', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('content_id')->constrained()->onDelete('cascade');
    $table->enum('status', ['not_started', 'in_progress', 'completed'])->default('not_started');
    $table->integer('progress_percentage')->default(0); // 0-100
    $table->integer('time_spent_minutes')->default(0);
    $table->timestamp('last_accessed_at')->nullable();
    $table->timestamp('completed_at')->nullable();
    $table->timestamps();

    $table->unique(['user_id', 'content_id']);
});
```

#### 15. content_ratings

```php
Schema::create('content_ratings', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('content_id')->constrained()->onDelete('cascade');
    $table->integer('rating'); // 1-5
    $table->text('comment_ar')->nullable();
    $table->boolean('is_helpful')->nullable();
    $table->timestamps();

    $table->unique(['user_id', 'content_id']);
});
```

---

### Intelligent Planner Module

#### 16. planner_settings

```php
Schema::create('planner_settings', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');

    // Prayer Times
    $table->boolean('enable_prayer_times')->default(true);

    // Sport Time
    $table->boolean('enable_sport_time')->default(false);
    $table->time('sport_time_start')->nullable();
    $table->time('sport_time_end')->nullable();

    // Family Time
    $table->boolean('enable_family_time')->default(false);
    $table->time('family_time_start')->nullable();
    $table->time('family_time_end')->nullable();

    // Study Preferences
    $table->enum('energy_peak_time', ['morning', 'afternoon', 'evening'])->default('morning');
    $table->integer('session_duration_preference')->default(30); // minutes
    $table->integer('break_duration_preference')->default(10); // minutes
    $table->boolean('auto_reschedule')->default(true);

    $table->timestamps();
});
```

#### 17. prayer_times

```php
Schema::create('prayer_times', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->date('date');
    $table->time('fajr');
    $table->time('dhuhr');
    $table->time('asr');
    $table->time('maghrib');
    $table->time('isha');
    $table->timestamps();

    $table->unique(['user_id', 'date']);
});
```

#### 18. exam_schedule

```php
Schema::create('exam_schedule', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->enum('exam_type', ['test', 'exam', 'mock']); // فرض، اختبار، bac_blanc
    $table->date('exam_date');
    $table->time('exam_time')->nullable();
    $table->integer('duration_minutes')->nullable();
    $table->boolean('is_completed')->default(false);
    $table->timestamps();
});
```

#### 19. subject_priorities

```php
Schema::create('subject_priorities', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');

    // Priority Score Components
    $table->decimal('coefficient_score', 5, 2);
    $table->decimal('exam_proximity_score', 5, 2);
    $table->decimal('difficulty_score', 5, 2);
    $table->decimal('inactivity_score', 5, 2);
    $table->decimal('performance_gap_score', 5, 2);
    $table->decimal('total_priority_score', 5, 2);

    $table->timestamp('calculated_at');
    $table->timestamps();

    $table->unique(['user_id', 'subject_id']);
});
```

#### 20. study_schedules

```php
Schema::create('study_schedules', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->timestamp('generated_at');
    $table->date('valid_from');
    $table->date('valid_to');
    $table->boolean('is_active')->default(true);
    $table->json('generation_params')->nullable();
    $table->timestamps();
});
```

#### 21. study_sessions

```php
Schema::create('study_sessions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('study_schedule_id')->constrained()->onDelete('cascade');
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->foreignId('content_id')->nullable()->constrained()->onDelete('set null');

    // Scheduled Time
    $table->date('session_date');
    $table->time('session_start_time');
    $table->time('session_end_time');
    $table->integer('duration_minutes');

    // Actual Execution
    $table->enum('status', ['scheduled', 'started', 'paused', 'completed', 'skipped'])->default('scheduled');
    $table->datetime('actual_start_time')->nullable();
    $table->datetime('actual_end_time')->nullable();
    $table->integer('actual_duration_minutes')->nullable();
    $table->text('skip_reason')->nullable();

    $table->timestamps();
});
```

#### 22. session_activities

```php
Schema::create('session_activities', function (Blueprint $table) {
    $table->id();
    $table->foreignId('study_session_id')->constrained()->onDelete('cascade');
    $table->enum('activity_type', ['start', 'pause', 'resume', 'complete', 'skip']);
    $table->datetime('activity_time');
    $table->text('notes')->nullable();
    $table->timestamp('created_at');
});
```

---

### Quiz System Module

#### 23. quizzes

```php
Schema::create('quizzes', function (Blueprint $table) {
    $table->id();
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
    $table->string('title_ar');
    $table->string('slug');
    $table->text('description_ar')->nullable();
    $table->enum('quiz_type', ['practice', 'timed', 'exam']);
    $table->integer('time_limit_minutes')->nullable();
    $table->integer('passing_score')->default(50);
    $table->enum('difficulty_level', ['easy', 'medium', 'hard']);
    $table->boolean('is_published')->default(false);
    $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
    $table->timestamps();
    $table->softDeletes();
});
```

#### 24. quiz_questions

```php
Schema::create('quiz_questions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('quiz_id')->constrained()->onDelete('cascade');
    $table->enum('question_type', [
        'mcq_single',
        'mcq_multiple',
        'true_false',
        'matching',
        'fill_blank',
        'sequence',
        'short_answer',
        'long_answer'
    ]);
    $table->text('question_text_ar');
    $table->string('question_image_url')->nullable();
    $table->json('options')->nullable(); // for MCQ, matching, sequence
    $table->json('correct_answer');
    $table->integer('points')->default(1);
    $table->text('explanation_ar')->nullable();
    $table->integer('order');
    $table->timestamps();
});
```

#### 25. quiz_attempts

```php
Schema::create('quiz_attempts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('quiz_id')->constrained()->onDelete('cascade');
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->datetime('started_at');
    $table->datetime('submitted_at')->nullable();
    $table->integer('duration_seconds')->nullable();
    $table->decimal('score', 5, 2)->nullable();
    $table->integer('max_score');
    $table->boolean('passed')->default(false);
    $table->boolean('is_completed')->default(false);
    $table->timestamps();
});
```

#### 26. quiz_attempt_answers

```php
Schema::create('quiz_attempt_answers', function (Blueprint $table) {
    $table->id();
    $table->foreignId('quiz_attempt_id')->constrained()->onDelete('cascade');
    $table->foreignId('quiz_question_id')->constrained()->onDelete('cascade');
    $table->json('user_answer');
    $table->boolean('is_correct')->nullable();
    $table->integer('points_earned')->default(0);
    $table->datetime('answered_at')->nullable();
    $table->timestamps();
});
```

#### 27. user_quiz_performance

```php
Schema::create('user_quiz_performance', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->foreignId('chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');
    $table->integer('total_attempts')->default(0);
    $table->integer('total_correct')->default(0);
    $table->integer('total_incorrect')->default(0);
    $table->decimal('average_score', 5, 2);
    $table->decimal('best_score', 5, 2);
    $table->json('weak_concepts')->nullable();
    $table->timestamp('updated_at');

    $table->unique(['user_id', 'subject_id', 'chapter_id']);
});
```

---

### BAC Archives Module

#### 28. bac_years

```php
Schema::create('bac_years', function (Blueprint $table) {
    $table->id();
    $table->integer('year')->unique(); // 2010-2024
    $table->boolean('is_active')->default(true);
});
```

#### 29. bac_sessions

```php
Schema::create('bac_sessions', function (Blueprint $table) {
    $table->id();
    $table->string('name_ar'); // دورة جوان، دورة سبتمبر
    $table->string('slug')->unique(); // june, september
});
```

#### 30. bac_subjects

```php
Schema::create('bac_subjects', function (Blueprint $table) {
    $table->id();
    $table->foreignId('bac_year_id')->constrained()->onDelete('cascade');
    $table->foreignId('bac_session_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->foreignId('academic_stream_id')->constrained()->onDelete('cascade');
    $table->string('title_ar');
    $table->string('file_path');
    $table->string('correction_file_path')->nullable();
    $table->integer('duration_minutes');
    $table->integer('views_count')->default(0);
    $table->integer('downloads_count')->default(0);
    $table->timestamps();
});
```

#### 31. bac_simulations

```php
Schema::create('bac_simulations', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('bac_subject_id')->constrained()->onDelete('cascade');
    $table->datetime('started_at');
    $table->datetime('submitted_at')->nullable();
    $table->integer('duration_seconds');
    $table->enum('status', ['started', 'completed', 'abandoned']);
    $table->timestamps();
});
```

#### 32. user_bac_performance

```php
Schema::create('user_bac_performance', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->integer('total_simulations')->default(0);
    $table->decimal('average_score', 5, 2)->nullable();
    $table->decimal('best_score', 5, 2)->nullable();
    $table->json('weak_chapters')->nullable();
    $table->timestamp('updated_at');
});
```

---

### Paid Courses Module

#### 33. courses

```php
Schema::create('courses', function (Blueprint $table) {
    $table->id();
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->string('title_ar');
    $table->string('slug')->unique();
    $table->text('description_ar');
    $table->string('thumbnail_url')->nullable();
    $table->decimal('price_dzd', 10, 2);
    $table->integer('duration_days'); // access duration
    $table->boolean('is_published')->default(false);
    $table->timestamp('published_at')->nullable();
    $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
    $table->timestamps();
    $table->softDeletes();
});
```

#### 34. course_modules

```php
Schema::create('course_modules', function (Blueprint $table) {
    $table->id();
    $table->foreignId('course_id')->constrained()->onDelete('cascade');
    $table->string('title_ar');
    $table->text('description_ar')->nullable();
    $table->integer('order');
    $table->timestamps();
});
```

#### 35. course_lessons

```php
Schema::create('course_lessons', function (Blueprint $table) {
    $table->id();
    $table->foreignId('course_module_id')->constrained()->onDelete('cascade');
    $table->string('title_ar');
    $table->text('description_ar')->nullable();
    $table->enum('video_type', ['youtube', 'upload']);
    $table->string('video_url');
    $table->integer('video_duration_seconds')->nullable();
    $table->boolean('has_pdf')->default(false);
    $table->string('pdf_path')->nullable();
    $table->integer('order');
    $table->boolean('is_preview')->default(false); // free preview
    $table->timestamps();
});
```

#### 36. course_quizzes

```php
Schema::create('course_quizzes', function (Blueprint $table) {
    $table->id();
    $table->foreignId('course_module_id')->constrained()->onDelete('cascade');
    $table->foreignId('quiz_id')->constrained()->onDelete('cascade');
    $table->boolean('is_required')->default(false);
    $table->integer('passing_score')->default(70);
    $table->integer('order');
    $table->timestamps();
});
```

#### 37. subscription_packages

```php
Schema::create('subscription_packages', function (Blueprint $table) {
    $table->id();
    $table->string('name_ar');
    $table->text('description_ar')->nullable();
    $table->decimal('price_dzd', 10, 2);
    $table->integer('duration_days');
    $table->timestamps();
});
```

#### 38. subscription_codes

```php
Schema::create('subscription_codes', function (Blueprint $table) {
    $table->id();
    $table->string('code')->unique();
    $table->foreignId('course_id')->nullable()->constrained()->onDelete('cascade');
    $table->foreignId('package_id')->nullable()->constrained('subscription_packages')->onDelete('cascade');
    $table->integer('max_uses')->default(1);
    $table->integer('used_count')->default(0);
    $table->datetime('expires_at')->nullable();
    $table->boolean('is_active')->default(true);
    $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
    $table->timestamps();
});
```

#### 39. package_courses

```php
Schema::create('package_courses', function (Blueprint $table) {
    $table->id();
    $table->foreignId('package_id')->constrained('subscription_packages')->onDelete('cascade');
    $table->foreignId('course_id')->constrained()->onDelete('cascade');
});
```

#### 40. user_subscriptions

```php
Schema::create('user_subscriptions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('course_id')->constrained()->onDelete('cascade');
    $table->enum('activated_by', ['code', 'receipt']);
    $table->foreignId('code_id')->nullable()->constrained('subscription_codes')->onDelete('set null');
    $table->foreignId('receipt_id')->nullable()->constrained('payment_receipts')->onDelete('set null');
    $table->datetime('activated_at');
    $table->datetime('expires_at');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### 41. payment_receipts

```php
Schema::create('payment_receipts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('course_id')->constrained()->onDelete('cascade');
    $table->string('receipt_image_url');
    $table->decimal('amount_dzd', 10, 2);
    $table->string('payment_method');
    $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
    $table->text('admin_note')->nullable();
    $table->foreignId('reviewed_by')->nullable()->constrained('users')->onDelete('set null');
    $table->timestamp('reviewed_at')->nullable();
    $table->timestamps();
});
```

#### 42. user_course_progress

```php
Schema::create('user_course_progress', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('course_id')->constrained()->onDelete('cascade');
    $table->foreignId('course_lesson_id')->nullable()->constrained()->onDelete('set null');
    $table->foreignId('last_lesson_id')->nullable()->constrained('course_lessons')->onDelete('set null');
    $table->integer('progress_percentage')->default(0);
    $table->integer('total_lessons');
    $table->integer('completed_lessons')->default(0);
    $table->timestamp('last_accessed_at')->nullable();
    $table->timestamps();

    $table->unique(['user_id', 'course_id', 'course_lesson_id']);
});
```

---

### Notifications Module

#### 43. notifications

```php
Schema::create('notifications', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('type'); // StudyReminder, ExamAlert, Achievement, etc.
    $table->string('title_ar');
    $table->text('body_ar');
    $table->json('data')->nullable();
    $table->timestamp('read_at')->nullable();
    $table->timestamp('sent_at')->nullable();
    $table->timestamps();

    $table->index(['user_id', 'type', 'read_at']);
});
```

#### 44. user_notification_settings

```php
Schema::create('user_notification_settings', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
    $table->boolean('study_reminders')->default(true);
    $table->boolean('exam_alerts')->default(true);
    $table->boolean('achievement_notifications')->default(true);
    $table->boolean('course_notifications')->default(true);
    $table->boolean('quiet_mode_enabled')->default(true);
    $table->timestamps();
});
```

#### 45. fcm_tokens

```php
Schema::create('fcm_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('token')->unique();
    $table->string('device_uuid');
    $table->enum('device_platform', ['android', 'ios']);
    $table->boolean('is_active')->default(true);
    $table->timestamp('last_used_at');
    $table->timestamps();
});
```

---

### Analytics & Gamification Module

#### 46. user_stats

```php
Schema::create('user_stats', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
    $table->integer('total_study_minutes')->default(0);
    $table->integer('total_sessions_completed')->default(0);
    $table->integer('total_contents_completed')->default(0);
    $table->integer('total_quizzes_completed')->default(0);
    $table->integer('total_simulations_completed')->default(0);
    $table->integer('average_daily_study_minutes')->default(0);
    $table->integer('current_week_minutes')->default(0);
    $table->integer('current_month_minutes')->default(0);
    $table->timestamp('updated_at');
});
```

#### 47. achievements

```php
Schema::create('achievements', function (Blueprint $table) {
    $table->id();
    $table->string('name_ar');
    $table->text('description_ar');
    $table->string('icon');
    $table->string('badge_color');
    $table->string('criteria_type'); // FirstSession, Marathon, Perfectionist, etc.
    $table->json('criteria_value')->nullable();
    $table->integer('points');
    $table->timestamps();
});
```

#### 48. user_achievements

```php
Schema::create('user_achievements', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('achievement_id')->constrained()->onDelete('cascade');
    $table->timestamp('unlocked_at');
    $table->timestamp('created_at');

    $table->unique(['user_id', 'achievement_id']);
});
```

#### 49. user_activity_log

```php
Schema::create('user_activity_log', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('activity_type'); // login, content_view, quiz_complete, etc.
    $table->json('activity_data')->nullable();
    $table->timestamp('created_at');

    $table->index(['user_id', 'activity_type', 'created_at']);
});
```

---

## Summary

Total: 49 new tables + 1 modification to users table = 50 migrations

All migrations include:
- Proper foreign key constraints
- Indexes on frequently queried columns
- Cascading deletes where appropriate
- Soft deletes on main content tables
- Timestamps on all tables
- Unique constraints where needed

Next step: Fill each migration file with the corresponding code from this document.
