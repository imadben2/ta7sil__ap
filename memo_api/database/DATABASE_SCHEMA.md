# MEMO API - Complete Database Schema

## Overview
This document lists all database tables needed for the MEMO educational platform.
Total: 35+ tables organized by module.

---

## Module 1: Authentication & Users

### 1. users (already exists - will be modified)
- id (bigint, PK, auto)
- name (string)
- email (string, unique)
- email_verified_at (timestamp, nullable)
- password (string)
- role (enum: admin, teacher, student) default 'student'
- device_uuid (string, nullable, unique) **CRITICAL**
- device_name (string, nullable)
- device_last_seen (timestamp, nullable)
- is_active (boolean, default true)
- remember_token
- created_at, updated_at

### 2. password_reset_tokens (already exists)
- email (string, PK)
- token (string)
- created_at

### 3. device_transfer_requests
- id (bigint, PK)
- user_id (FK users)
- old_device_uuid (string)
- new_device_uuid (string)
- new_device_name (string)
- reason (text)
- status (enum: pending, approved, rejected) default 'pending'
- admin_note (text, nullable)
- approved_by (FK users, nullable)
- approved_at (timestamp, nullable)
- created_at, updated_at
- Index: user_id, status

---

## Module 2: User Profiles & Preferences

### 4. user_profiles
- id (bigint, PK)
- user_id (FK users, unique)
- full_name_ar (string)
- phone (string, nullable)
- wilaya (string, nullable)
- avatar_url (string, nullable)
- bio_ar (text, nullable)
- points (int, default 0) **gamification**
- level (int, default 1)
- current_streak_days (int, default 0)
- longest_streak_days (int, default 0)
- last_activity_date (date, nullable)
- created_at, updated_at

### 5. user_academic_profiles
- id (bigint, PK)
- user_id (FK users, unique)
- academic_phase_id (FK academic_phases)
- academic_year_id (FK academic_years)
- academic_stream_id (FK academic_streams, nullable)
- onboarding_completed (boolean, default false)
- created_at, updated_at

### 6. user_preferences
- id (bigint, PK)
- user_id (FK users, unique)
- language (enum: ar, fr, en) default 'ar'
- theme (enum: light, dark, auto) default 'light'
- notifications_enabled (boolean, default true)
- email_notifications (boolean, default true)
- push_notifications (boolean, default true)
- pomodoro_duration (int, default 25) **minutes**
- pomodoro_break (int, default 5)
- study_start_time (time, default '08:00')
- study_end_time (time, default '22:00')
- sleep_start_time (time, default '23:00')
- sleep_end_time (time, default '06:00')
- prayer_notifications (boolean, default true)
- created_at, updated_at

### 7. user_subjects
- id (bigint, PK)
- user_id (FK users)
- subject_id (FK subjects)
- goal_hours_per_week (decimal 5,2, nullable)
- priority_override (int, nullable) 1-5
- is_active (boolean, default true)
- created_at, updated_at
- Unique: user_id + subject_id

---

## Module 3: Academic Structure & Contents

### 8. academic_phases
- id (int, PK)
- name_ar (string)
- slug (string, unique)
- order (int)
- is_active (boolean, default true)
- created_at, updated_at

### 9. academic_years
- id (int, PK)
- academic_phase_id (FK academic_phases)
- name_ar (string)
- level_number (int)
- order (int)
- is_active (boolean, default true)
- created_at, updated_at

### 10. academic_streams
- id (int, PK)
- academic_year_id (FK academic_years)
- name_ar (string)
- slug (string)
- description_ar (text, nullable)
- order (int)
- is_active (boolean, default true)
- created_at, updated_at

### 11. subjects
- id (bigint, PK)
- academic_stream_id (FK academic_streams, nullable)
- academic_year_id (FK academic_years)
- name_ar (string)
- slug (string)
- description_ar (text, nullable)
- color (string, nullable)
- icon (string, nullable)
- coefficient (decimal 3,1)
- order (int)
- is_active (boolean, default true)
- created_at, updated_at
- Index: academic_stream_id, academic_year_id

### 12. content_chapters
- id (bigint, PK)
- subject_id (FK subjects)
- title_ar (string)
- slug (string)
- description_ar (text, nullable)
- order (int)
- is_active (boolean, default true)
- created_at, updated_at

### 13. content_types
- id (int, PK)
- name_ar (string) **درس، ملخص، سلسلة تمارين، فرض، اختبار**
- slug (string, unique) **lesson, summary, exercise, test, exam**
- icon (string, nullable)

### 14. contents
- id (bigint, PK)
- subject_id (FK subjects)
- content_type_id (FK content_types)
- chapter_id (FK content_chapters, nullable)
- title_ar (string)
- slug (string)
- description_ar (text, nullable)
- content_body_ar (longtext, nullable)
- difficulty_level (enum: easy, medium, hard)
- estimated_duration_minutes (int, nullable)
- order (int, default 0)
- prerequisites (json, nullable)
- has_file (boolean, default false)
- file_path (string, nullable)
- file_type (string, nullable)
- file_size (int, nullable)
- has_video (boolean, default false)
- video_type (enum: youtube, upload, null)
- video_url (string, nullable)
- video_duration_seconds (int, nullable)
- is_published (boolean, default false)
- published_at (timestamp, nullable)
- is_premium (boolean, default false)
- tags (json, nullable)
- search_keywords (text, nullable)
- views_count (int, default 0)
- downloads_count (int, default 0)
- created_by (FK users, nullable)
- updated_by (FK users, nullable)
- created_at, updated_at, deleted_at
- Index: subject_id, content_type_id, chapter_id, is_published
- Fulltext: title_ar, description_ar, search_keywords

### 15. user_content_progress
- id (bigint, PK)
- user_id (FK users)
- content_id (FK contents)
- status (enum: not_started, in_progress, completed)
- progress_percentage (int, default 0)
- time_spent_minutes (int, default 0)
- last_accessed_at (timestamp, nullable)
- completed_at (timestamp, nullable)
- created_at, updated_at
- Unique: user_id + content_id

### 16. content_ratings
- id (bigint, PK)
- user_id (FK users)
- content_id (FK contents)
- rating (int) 1-5
- comment_ar (text, nullable)
- is_helpful (boolean, nullable)
- created_at, updated_at
- Unique: user_id + content_id

---

## Module 4: Intelligent Planner

### 17. planner_settings
- id (bigint, PK)
- user_id (FK users, unique)
- enable_prayer_times (boolean, default true)
- enable_sport_time (boolean, default false)
- sport_time_start (time, nullable)
- sport_time_end (time, nullable)
- enable_family_time (boolean, default false)
- family_time_start (time, nullable)
- family_time_end (time, nullable)
- energy_peak_time (enum: morning, afternoon, evening) default 'morning'
- session_duration_preference (int, default 30) **minutes**
- break_duration_preference (int, default 10)
- auto_reschedule (boolean, default true)
- created_at, updated_at

### 18. prayer_times
- id (bigint, PK)
- user_id (FK users)
- date (date)
- fajr (time)
- dhuhr (time)
- asr (time)
- maghrib (time)
- isha (time)
- created_at, updated_at
- Unique: user_id + date

### 19. exam_schedule
- id (bigint, PK)
- user_id (FK users)
- subject_id (FK subjects)
- exam_type (enum: فرض, اختبار, bac_blanc) **test, exam, mock**
- exam_date (date)
- exam_time (time, nullable)
- duration_minutes (int, nullable)
- is_completed (boolean, default false)
- created_at, updated_at

### 20. subject_priorities
- id (bigint, PK)
- user_id (FK users)
- subject_id (FK subjects)
- coefficient_score (decimal 5,2)
- exam_proximity_score (decimal 5,2)
- difficulty_score (decimal 5,2)
- inactivity_score (decimal 5,2)
- performance_gap_score (decimal 5,2)
- total_priority_score (decimal 5,2)
- calculated_at (timestamp)
- created_at, updated_at
- Unique: user_id + subject_id

### 21. study_schedules
- id (bigint, PK)
- user_id (FK users)
- generated_at (timestamp)
- valid_from (date)
- valid_to (date)
- is_active (boolean, default true)
- generation_params (json)
- created_at, updated_at

### 22. study_sessions
- id (bigint, PK)
- study_schedule_id (FK study_schedules)
- user_id (FK users)
- subject_id (FK subjects)
- content_id (FK contents, nullable)
- session_date (date)
- session_start_time (time)
- session_end_time (time)
- duration_minutes (int)
- status (enum: scheduled, started, paused, completed, skipped)
- actual_start_time (datetime, nullable)
- actual_end_time (datetime, nullable)
- actual_duration_minutes (int, nullable)
- skip_reason (text, nullable)
- created_at, updated_at

### 23. session_activities
- id (bigint, PK)
- study_session_id (FK study_sessions)
- activity_type (enum: start, pause, resume, complete, skip)
- activity_time (datetime)
- notes (text, nullable)
- created_at

---

## Module 5: Quiz System

### 24. quizzes
- id (bigint, PK)
- subject_id (FK subjects)
- chapter_id (FK content_chapters, nullable)
- title_ar (string)
- slug (string)
- description_ar (text, nullable)
- quiz_type (enum: practice, timed, exam)
- time_limit_minutes (int, nullable)
- passing_score (int, default 50)
- difficulty_level (enum: easy, medium, hard)
- is_published (boolean, default false)
- created_by (FK users, nullable)
- created_at, updated_at, deleted_at

### 25. quiz_questions
- id (bigint, PK)
- quiz_id (FK quizzes)
- question_type (enum: mcq_single, mcq_multiple, true_false, matching, fill_blank, sequence, short_answer, long_answer)
- question_text_ar (text)
- question_image_url (string, nullable)
- options (json, nullable) **for MCQ, matching, sequence**
- correct_answer (json)
- points (int, default 1)
- explanation_ar (text, nullable)
- order (int)
- created_at, updated_at

### 26. quiz_attempts
- id (bigint, PK)
- quiz_id (FK quizzes)
- user_id (FK users)
- started_at (datetime)
- submitted_at (datetime, nullable)
- duration_seconds (int, nullable)
- score (decimal 5,2, nullable)
- max_score (int)
- passed (boolean, default false)
- is_completed (boolean, default false)
- created_at, updated_at

### 27. quiz_attempt_answers
- id (bigint, PK)
- quiz_attempt_id (FK quiz_attempts)
- quiz_question_id (FK quiz_questions)
- user_answer (json)
- is_correct (boolean, nullable)
- points_earned (int, default 0)
- answered_at (datetime, nullable)
- created_at, updated_at

### 28. user_quiz_performance
- id (bigint, PK)
- user_id (FK users)
- subject_id (FK subjects)
- chapter_id (FK content_chapters, nullable)
- total_attempts (int, default 0)
- total_correct (int, default 0)
- total_incorrect (int, default 0)
- average_score (decimal 5,2)
- best_score (decimal 5,2)
- weak_concepts (json, nullable)
- updated_at
- Unique: user_id + subject_id + chapter_id

---

## Module 6: BAC Archives

### 29. bac_years
- id (int, PK)
- year (int, unique) **2010-2024**
- is_active (boolean, default true)

### 30. bac_sessions
- id (int, PK)
- name_ar (string) **دورة جوان، دورة سبتمبر**
- slug (string, unique) **june, september**

### 31. bac_subjects
- id (bigint, PK)
- bac_year_id (FK bac_years)
- bac_session_id (FK bac_sessions)
- subject_id (FK subjects)
- academic_stream_id (FK academic_streams)
- title_ar (string)
- file_path (string)
- correction_file_path (string, nullable)
- duration_minutes (int)
- views_count (int, default 0)
- downloads_count (int, default 0)
- created_at, updated_at

### 32. bac_simulations
- id (bigint, PK)
- user_id (FK users)
- bac_subject_id (FK bac_subjects)
- started_at (datetime)
- submitted_at (datetime, nullable)
- duration_seconds (int)
- status (enum: started, completed, abandoned)
- created_at, updated_at

### 33. user_bac_performance
- id (bigint, PK)
- user_id (FK users)
- subject_id (FK subjects)
- total_simulations (int, default 0)
- average_score (decimal 5,2, nullable)
- best_score (decimal 5,2, nullable)
- weak_chapters (json, nullable)
- updated_at

---

## Module 7: Paid Courses

### 34. courses
- id (bigint, PK)
- subject_id (FK subjects)
- title_ar (string)
- slug (string, unique)
- description_ar (text)
- thumbnail_url (string, nullable)
- price_dzd (decimal 10,2)
- duration_days (int) **access duration**
- is_published (boolean, default false)
- published_at (timestamp, nullable)
- created_by (FK users)
- created_at, updated_at, deleted_at

### 35. course_modules
- id (bigint, PK)
- course_id (FK courses)
- title_ar (string)
- description_ar (text, nullable)
- order (int)
- created_at, updated_at

### 36. course_lessons
- id (bigint, PK)
- course_module_id (FK course_modules)
- title_ar (string)
- description_ar (text, nullable)
- video_type (enum: youtube, upload)
- video_url (string)
- video_duration_seconds (int, nullable)
- has_pdf (boolean, default false)
- pdf_path (string, nullable)
- order (int)
- is_preview (boolean, default false) **free preview**
- created_at, updated_at

### 37. course_quizzes
- id (bigint, PK)
- course_module_id (FK course_modules)
- quiz_id (FK quizzes)
- is_required (boolean, default false)
- passing_score (int, default 70)
- order (int)
- created_at, updated_at

### 38. subscription_codes
- id (bigint, PK)
- code (string, unique) **generated unique code**
- course_id (FK courses, nullable)
- package_id (FK subscription_packages, nullable)
- max_uses (int, default 1)
- used_count (int, default 0)
- expires_at (datetime, nullable)
- is_active (boolean, default true)
- created_by (FK users)
- created_at, updated_at

### 39. subscription_packages
- id (bigint, PK)
- name_ar (string)
- description_ar (text, nullable)
- price_dzd (decimal 10,2)
- duration_days (int)
- created_at, updated_at

### 40. package_courses
- id (bigint, PK)
- package_id (FK subscription_packages)
- course_id (FK courses)

### 41. user_subscriptions
- id (bigint, PK)
- user_id (FK users)
- course_id (FK courses)
- activated_by (enum: code, receipt)
- code_id (FK subscription_codes, nullable)
- receipt_id (FK payment_receipts, nullable)
- activated_at (datetime)
- expires_at (datetime)
- is_active (boolean, default true)
- created_at, updated_at

### 42. payment_receipts
- id (bigint, PK)
- user_id (FK users)
- course_id (FK courses)
- receipt_image_url (string)
- amount_dzd (decimal 10,2)
- payment_method (string)
- status (enum: pending, approved, rejected)
- admin_note (text, nullable)
- reviewed_by (FK users, nullable)
- reviewed_at (timestamp, nullable)
- created_at, updated_at

### 43. user_course_progress
- id (bigint, PK)
- user_id (FK users)
- course_id (FK courses)
- course_lesson_id (FK course_lessons, nullable)
- last_lesson_id (FK course_lessons, nullable)
- progress_percentage (int, default 0)
- total_lessons (int)
- completed_lessons (int, default 0)
- last_accessed_at (timestamp, nullable)
- created_at, updated_at
- Unique: user_id + course_id + course_lesson_id

---

## Module 8: Notifications

### 44. notifications
- id (bigint, PK)
- user_id (FK users)
- type (string) **StudyReminder, ExamAlert, Achievement, CourseActivated, etc.**
- title_ar (string)
- body_ar (text)
- data (json, nullable)
- read_at (timestamp, nullable)
- sent_at (timestamp, nullable)
- created_at, updated_at
- Index: user_id, type, read_at

### 45. user_notification_settings
- id (bigint, PK)
- user_id (FK users, unique)
- study_reminders (boolean, default true)
- exam_alerts (boolean, default true)
- achievement_notifications (boolean, default true)
- course_notifications (boolean, default true)
- quiet_mode_enabled (boolean, default true)
- created_at, updated_at

### 46. fcm_tokens
- id (bigint, PK)
- user_id (FK users)
- token (string, unique)
- device_uuid (string)
- device_platform (enum: android, ios)
- is_active (boolean, default true)
- last_used_at (timestamp)
- created_at, updated_at

---

## Module 9: Analytics & Gamification

### 47. user_stats
- id (bigint, PK)
- user_id (FK users, unique)
- total_study_minutes (int, default 0)
- total_sessions_completed (int, default 0)
- total_contents_completed (int, default 0)
- total_quizzes_completed (int, default 0)
- total_simulations_completed (int, default 0)
- average_daily_study_minutes (int, default 0)
- current_week_minutes (int, default 0)
- current_month_minutes (int, default 0)
- updated_at

### 48. user_achievements
- id (bigint, PK)
- user_id (FK users)
- achievement_id (FK achievements)
- unlocked_at (timestamp)
- created_at
- Unique: user_id + achievement_id

### 49. achievements
- id (int, PK)
- name_ar (string)
- description_ar (text)
- icon (string)
- badge_color (string)
- criteria_type (string) **FirstSession, Marathon, Perfectionist, etc.**
- criteria_value (json, nullable)
- points (int)
- created_at, updated_at

### 50. user_activity_log
- id (bigint, PK)
- user_id (FK users)
- activity_type (string) **login, content_view, quiz_complete, session_complete, etc.**
- activity_data (json, nullable)
- created_at
- Index: user_id, activity_type, created_at

---

## System Tables (already exist from Laravel)

### cache (already exists)
### cache_locks (already exists)
### jobs (already exists)
### job_batches (already exists)
### failed_jobs (already exists)
### sessions (will be added)

---

## Summary

**Total Custom Tables: 50**
- Authentication & Users: 3 tables
- User Profiles: 4 tables
- Academic Structure: 9 tables
- Planner: 7 tables
- Quiz System: 5 tables
- BAC Archives: 5 tables
- Paid Courses: 10 tables
- Notifications: 3 tables
- Analytics: 4 tables

**Next Steps:**
1. Create migrations for all tables in proper order (respecting foreign keys)
2. Create Model classes with relationships
3. Create seeders for reference data
