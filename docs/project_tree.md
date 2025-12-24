# Project Tree - Ta7sil Memo App

Complete file and folder structure for the Ta7sil education platform.

**Last Updated:** 2025-12-18

---

## Overview

This document maps the complete structure of:
1. **Flutter Mobile App** (`memo_app/lib`) - ~728 Dart files
2. **Laravel API Backend** (`memo_api/app`) - ~275 PHP files

---

## 1. Flutter Mobile App (`d:\ta7sil\memo_app\lib`)

### Root Level Files (2 files)
```
lib/
├── app_router.dart                    # Main navigation router configuration
├── main.dart                          # Application entry point
├── debug_*.dart                       # Debug utilities (3 files)
```

### Core Infrastructure (`lib/core`) - 68 files

```
core/
├── constants/                         # App-wide constants (7 files)
│   ├── api_constants.dart            # API endpoints and configuration
│   ├── app_colors.dart               # Color palette definitions
│   ├── app_design_tokens.dart        # Design system tokens
│   ├── app_sizes.dart                # Spacing and sizing constants
│   ├── app_strings_ar.dart           # Arabic string resources
│   └── planner_constants.dart        # Planner-specific constants
│
├── errors/                            # Error handling (3 files)
│   ├── exceptions.dart               # Custom exception classes
│   └── failures.dart                 # Failure classes for error handling
│
├── models/                            # Core data models (1 file)
│   └── tab_order_preferences.dart    # Tab ordering preferences
│
├── network/                           # Networking layer (2 files)
│   ├── dio_client.dart               # HTTP client wrapper
│   └── network_info.dart             # Network connectivity checker
│
├── services/                          # Core services (9 files)
│   ├── app_lifecycle_observer.dart   # App lifecycle management
│   ├── connectivity_service.dart     # Network connectivity monitoring
│   ├── fcm_token_service.dart        # Firebase Cloud Messaging
│   ├── focus_mode_service.dart       # Focus mode functionality
│   ├── notification_service.dart     # Local notifications
│   ├── pdf_upload_service.dart       # PDF file upload handling
│   ├── system_dnd_manager.dart       # Do Not Disturb management
│   └── tab_order_service.dart        # Tab ordering service
│
├── storage/                           # Local storage (3 files)
│   ├── hive_service.dart             # Hive database service
│   └── secure_storage_service.dart   # Secure storage for sensitive data
│
├── theme/                             # Theming (1 file)
│   └── app_theme.dart                # Material theme configuration
│
├── usecase/                           # Base use case pattern (1 file)
│   └── usecase.dart                  # Abstract use case class
│
├── utils/                             # Utility functions (7 files)
│   ├── formatters.dart               # Data formatting utilities
│   ├── gradient_helper.dart          # Gradient generation helpers
│   ├── image_helper.dart             # Image processing utilities
│   ├── password_validator.dart       # Password validation
│   ├── pdf_font_loader.dart          # PDF font loading
│   └── validators.dart               # Form validation utilities
│
├── video_player/                      # Video player abstraction (7 files)
│   ├── domain/
│   │   ├── video_player_factory.dart      # Player factory pattern
│   │   └── video_player_interface.dart    # Player interface
│   └── infrastructure/
│       ├── chewie_player_impl.dart        # Chewie player implementation
│       ├── media_kit_player_impl.dart     # Media Kit implementation
│       ├── omni_video_player_impl.dart    # Omni player implementation
│       ├── orax_player_impl.dart          # Orax player implementation
│       └── simple_youtube_player_impl.dart # YouTube player
│
└── widgets/                           # Reusable UI components (35 files)
    ├── badges/                        # Badge components (5 files)
    │   ├── animated_status_badge.dart
    │   ├── coefficient_badge.dart
    │   ├── level_badge.dart
    │   ├── stat_badge.dart
    │   └── time_badge.dart
    │
    ├── cards/                         # Card components (9 files)
    │   ├── active_session_timer_card.dart
    │   ├── bac_archives_card.dart
    │   ├── gradient_hero_card.dart
    │   ├── info_card.dart
    │   ├── modern_section_card.dart
    │   ├── modern_stat_card.dart
    │   ├── progress_card.dart
    │   ├── session_card.dart
    │   └── stat_card_mini.dart
    │
    ├── inputs/                        # Input components (4 files)
    │   ├── app_search_bar.dart
    │   ├── code_input_field.dart
    │   ├── filter_chip_group.dart
    │   └── modern_segmented_tabs.dart
    │
    ├── layouts/                       # Layout components (4 files)
    │   ├── glass_bottom_sheet.dart
    │   ├── grid_layout.dart
    │   ├── page_scaffold.dart
    │   └── section_header.dart
    │
    └── [Common widgets]               # Other widgets (13 files)
        ├── app_card.dart
        ├── app_text_field.dart
        ├── arabic_pattern_divider.dart
        ├── empty_state_widget.dart
        ├── error_widget.dart
        ├── gradient_subject_card.dart
        ├── loading_widget.dart
        ├── main_app_bar.dart
        ├── modern_bottom_nav.dart
        ├── primary_button.dart
        ├── progress_ring_widget.dart
        ├── rtl_helper.dart
        ├── secondary_button.dart
        ├── stat_card.dart
        └── subject_card.dart
```

### Features (`lib/features`) - 660 files

#### 1. Auth Feature (`lib/features/auth`) - 25 files
```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   ├── academic_models.dart (.g.dart)
│   │   ├── login_response_model.dart (.g.dart)
│   │   └── user_model.dart (.g.dart)
│   └── repositories/
│       └── auth_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── academic_entities.dart
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/                      # 8 use cases
│       ├── get_academic_phases_usecase.dart
│       ├── get_academic_streams_usecase.dart
│       ├── get_academic_years_usecase.dart
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       ├── register_usecase.dart
│       ├── update_academic_profile_usecase.dart
│       └── validate_token_usecase.dart
│
└── presentation/
    ├── bloc/
    │   ├── academic_setup_bloc/event/state.dart (3 files)
    │   └── auth_bloc/event/state.dart (3 files)
    ├── pages/                         # 6 pages
    │   ├── academic_selection_page.dart
    │   ├── login_page.dart
    │   ├── onboarding_page.dart
    │   ├── register_page.dart
    │   ├── splash_page.dart
    │   └── update_required_page.dart
    └── widgets/
        └── selection_card.dart
```

#### 2. Courses Feature (`lib/features/courses`) - 102 files ⭐ PRIMARY FEATURE
```
features/courses/
├── data/
│   ├── datasources/
│   │   ├── courses_local_datasource.dart
│   │   └── courses_remote_datasource.dart
│   ├── models/                        # 10 models (.g.dart files)
│   │   ├── certificate_model.dart
│   │   ├── course_model.dart
│   │   ├── course_lesson_model.dart
│   │   ├── course_module_model.dart
│   │   ├── course_progress_model.dart
│   │   ├── course_review_model.dart
│   │   ├── lesson_attachment_model.dart
│   │   ├── lesson_progress_model.dart
│   │   ├── payment_receipt_model.dart
│   │   ├── subscription_package_model.dart
│   │   └── user_subscription_model.dart
│   └── repositories/
│       ├── courses_repository_impl.dart
│       └── subscription_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 11 entities
│   │   ├── certificate_entity.dart
│   │   ├── course_entity.dart
│   │   ├── course_lesson_entity.dart
│   │   ├── course_module_entity.dart
│   │   ├── course_progress_entity.dart
│   │   ├── course_review_entity.dart
│   │   ├── lesson_attachment_entity.dart
│   │   ├── lesson_progress_entity.dart
│   │   ├── payment_receipt_entity.dart
│   │   ├── subscription_package_entity.dart
│   │   └── user_subscription_entity.dart
│   ├── repositories/
│   │   ├── courses_repository.dart
│   │   └── subscription_repository.dart
│   └── usecases/                      # 17 use cases
│       ├── check_course_access_usecase.dart
│       ├── generate_certificate_usecase.dart
│       ├── get_course_details_usecase.dart
│       ├── get_course_modules_usecase.dart
│       ├── get_course_reviews_usecase.dart
│       ├── get_courses_usecase.dart
│       ├── get_featured_courses_usecase.dart
│       ├── get_lesson_progress_usecase.dart
│       ├── get_my_courses_usecase.dart
│       ├── get_my_receipts_usecase.dart
│       ├── get_my_subscriptions_usecase.dart
│       ├── get_signed_video_url_usecase.dart
│       ├── get_subscription_packages_usecase.dart
│       ├── mark_lesson_completed_usecase.dart
│       ├── redeem_subscription_code_usecase.dart
│       ├── submit_receipt_usecase.dart
│       ├── submit_review_usecase.dart
│       ├── update_lesson_progress_usecase.dart
│       └── validate_subscription_code_usecase.dart
│
├── presentation/
│   ├── bloc/
│   │   ├── courses/                   # Main courses BLoC
│   │   │   ├── courses_bloc.dart
│   │   │   ├── courses_event.dart
│   │   │   └── courses_state.dart
│   │   └── subscription/              # Subscription BLoC
│   │       ├── subscription_bloc.dart
│   │       ├── subscription_event.dart
│   │       └── subscription_state.dart
│   ├── pages/                         # 10 pages
│   │   ├── course_detail_page.dart
│   │   ├── course_learning_page.dart
│   │   ├── courses_page.dart
│   │   ├── lesson_detail_page.dart
│   │   ├── my_courses_page.dart
│   │   ├── my_receipts_page.dart
│   │   ├── payment_receipt_page.dart
│   │   ├── pdf_viewer_page.dart
│   │   ├── subscriptions_page.dart
│   │   └── video_player_page.dart
│   └── widgets/                       # 22 widgets
│       ├── modern/                    # Modern UI components (11 files)
│       │   ├── course_enrollment_badge.dart
│       │   ├── course_level_badge.dart
│       │   ├── modern_course_card.dart
│       │   ├── modern_course_header.dart
│       │   ├── modern_course_progress_card.dart
│       │   ├── modern_course_stats.dart
│       │   ├── modern_curriculum_section.dart
│       │   ├── modern_lesson_item.dart
│       │   ├── modern_rating_summary.dart
│       │   ├── modern_review_card.dart
│       │   └── modern_review_form.dart
│       └── [Other widgets]            # (11 files)
│           ├── attachment_card.dart
│           ├── course_card.dart
│           ├── course_card_shimmer.dart
│           ├── course_instructor_card.dart
│           ├── course_module_item.dart
│           ├── course_stats_row.dart
│           ├── featured_courses_carousel.dart
│           ├── featured_courses_carousel_widget.dart
│           ├── modern_code_input.dart
│           ├── modern_course_list_card.dart
│           ├── my_course_card.dart
│           ├── payment_options_bottom_sheet.dart
│           ├── receipt_status_card.dart
│           ├── subscription_code_dialog.dart
│           ├── subscription_hero_header.dart
│           └── subscription_package_card.dart
│
└── di/
    └── courses_injection.dart         # Dependency injection setup
```

#### 3. Bac (Exam Archives) Feature (`lib/features/bac`) - 47 files
```
features/bac/
├── bac_feature_setup.dart
├── data/
│   ├── datasources/
│   │   ├── bac_local_datasource.dart
│   │   └── bac_remote_datasource.dart
│   ├── models/                        # 7 models
│   │   ├── bac_chapter_info_model.dart
│   │   ├── bac_session_model.dart
│   │   ├── bac_simulation_model.dart
│   │   ├── bac_subject_model.dart
│   │   ├── bac_year_model.dart
│   │   ├── chapter_score_model.dart
│   │   └── simulation_results_model.dart
│   └── repositories/
│       └── bac_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 9 entities
│   │   ├── bac_chapter_info_entity.dart
│   │   ├── bac_enums.dart
│   │   ├── bac_session_entity.dart
│   │   ├── bac_simulation_entity.dart
│   │   ├── bac_subject_entity.dart
│   │   ├── bac_year_entity.dart
│   │   ├── chapter_score_entity.dart
│   │   └── simulation_results_entity.dart
│   ├── repositories/
│   │   └── bac_repository.dart
│   └── usecases/                      # 10 use cases
│       ├── create_simulation.dart
│       ├── download_exam_pdf.dart
│       ├── get_bac_chapters.dart
│       ├── get_bac_sessions.dart
│       ├── get_bac_subjects.dart
│       ├── get_bac_years.dart
│       ├── get_simulation_history.dart
│       ├── get_simulation_results.dart
│       ├── get_subject_performance.dart
│       ├── manage_simulation.dart
│       └── submit_simulation.dart
│
└── presentation/
    ├── bloc/
    │   ├── bac_bloc/event/state.dart (3 files)
    │   ├── bac_bookmark/              # Bookmark feature
    │   │   ├── bac_bookmark_bloc.dart
    │   │   ├── bac_bookmark_event.dart
    │   │   └── bac_bookmark_state.dart
    │   └── cubit/
    │       └── simulation_timer_cubit.dart
    ├── pages/                         # 11 pages
    │   ├── bac_active_simulation_page.dart
    │   ├── bac_archives_by_year_page.dart
    │   ├── bac_archives_page.dart
    │   ├── bac_exams_by_subject_page.dart
    │   ├── bac_performance_page.dart
    │   ├── bac_results_page.dart
    │   ├── bac_simulation_page.dart
    │   ├── bac_simulation_results_page.dart
    │   ├── bac_simulation_setup_page.dart
    │   ├── bac_subject_detail_page.dart
    │   └── bac_years_by_subject_page.dart
    └── widgets/
        ├── bac_pdf_viewer_modal.dart
        └── bac_pdf_viewer_widget.dart
```

#### 4. Bac Study Schedule Feature (`lib/features/bac_study_schedule`) - 31 files
```
features/bac_study_schedule/
├── data/
│   ├── datasources/
│   │   ├── bac_study_local_datasource.dart
│   │   └── bac_study_remote_datasource.dart
│   ├── models/                        # 5 models
│   │   ├── bac_day_subject_model.dart
│   │   ├── bac_day_topic_model.dart
│   │   ├── bac_study_day_model.dart
│   │   ├── bac_user_stats_model.dart
│   │   └── bac_weekly_reward_model.dart
│   └── repositories/
│       └── bac_study_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 5 entities
│   │   ├── bac_day_subject.dart
│   │   ├── bac_day_topic.dart
│   │   ├── bac_study_day.dart
│   │   ├── bac_user_stats.dart
│   │   └── bac_weekly_reward.dart
│   ├── repositories/
│   │   └── bac_study_repository.dart
│   └── usecases/                      # 7 use cases
│       ├── get_day_schedule.dart
│       ├── get_day_with_progress.dart
│       ├── get_full_schedule.dart
│       ├── get_user_stats.dart
│       ├── get_weekly_rewards.dart
│       ├── get_week_schedule.dart
│       └── mark_topic_complete.dart
│
└── presentation/
    ├── bloc/
    │   ├── bac_study_bloc.dart
    │   ├── bac_study_event.dart
    │   └── bac_study_state.dart
    ├── pages/                         # 3 pages
    │   ├── bac_day_detail_page.dart
    │   ├── bac_rewards_page.dart
    │   └── bac_study_main_page.dart
    └── widgets/                       # 5 widgets
        ├── bac_day_card.dart
        ├── bac_progress_header.dart
        ├── bac_reward_card.dart
        ├── bac_topic_item.dart
        └── bac_week_selector.dart
```

#### 5. Content Library Feature (`lib/features/content_library`) - 45 files
```
features/content_library/
├── data/
│   ├── datasources/
│   │   ├── content_library_local_datasource.dart
│   │   └── content_library_remote_datasource.dart
│   ├── models/                        # 4 models
│   │   ├── chapter_model.dart
│   │   ├── content_model.dart
│   │   ├── content_progress_model.dart
│   │   └── subject_model.dart
│   └── repositories/
│       └── content_library_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 4 entities
│   │   ├── chapter_entity.dart
│   │   ├── content_entity.dart
│   │   ├── content_progress_entity.dart
│   │   └── subject_entity.dart
│   ├── repositories/
│   │   └── content_library_repository.dart
│   └── usecases/                      # 8 use cases
│       ├── bookmark_content_usecase.dart
│       ├── get_bookmarked_content_usecase.dart
│       ├── get_content_progress_usecase.dart
│       ├── get_subject_contents_usecase.dart
│       ├── get_subjects_usecase.dart
│       ├── mark_content_viewed_usecase.dart
│       ├── update_content_progress_usecase.dart
│       └── view_content_usecase.dart
│
└── presentation/
    ├── bloc/
    │   ├── bookmark/
    │   │   ├── bookmark_bloc/event/state.dart (3 files)
    │   ├── content_viewer/
    │   │   ├── content_viewer_bloc/event/state.dart (3 files)
    │   ├── subjects/
    │   │   ├── subjects_bloc/event/state.dart (3 files)
    │   └── subject_detail/
    │       ├── subject_detail_bloc/event/state.dart (3 files)
    ├── pages/                         # 4 pages
    │   ├── bookmarks_page.dart
    │   ├── content_library_page.dart
    │   ├── content_viewer_page.dart
    │   └── subject_detail_page.dart
    └── widgets/                       # 3 widgets
        ├── chapter_accordion.dart
        ├── content_list_item.dart
        └── subject_card.dart
```

#### 6. Focus Mode Feature (`lib/features/focus_mode`) - 8 files
```
features/focus_mode/
├── domain/
│   └── entities/
│       ├── focus_mode_settings.dart
│       └── focus_session_entity.dart
└── presentation/
    ├── bloc/
    │   ├── focus_mode_bloc/event/state.dart (3 files)
    └── pages/
        ├── focus_mode_page.dart
        └── focus_mode_settings_page.dart
```

#### 7. Home Feature (`lib/features/home`) - 23 files
```
features/home/
├── data/
│   └── datasources/
│       └── home_remote_datasource.dart
├── presentation/
│   ├── bloc/
│   │   └── sponsors/
│   │       └── sponsors_bloc/event/state.dart (3 files)
│   ├── pages/                         # 6 pages
│   │   ├── app_shell_page.dart
│   │   ├── courses_view.dart
│   │   ├── home_page.dart
│   │   ├── leaderboard_view.dart
│   │   ├── planner_view.dart
│   │   └── profile_view.dart
│   └── widgets/                       # 11 widgets
│       ├── dashboard_stat_card.dart
│       ├── home_featured_section.dart
│       ├── home_quick_actions.dart
│       ├── home_stats_overview.dart
│       ├── home_study_streak.dart
│       ├── leaderboard_preview_widget.dart
│       ├── nav_item.dart
│       ├── sponsor_banner.dart
│       ├── sponsor_carousel.dart
│       └── user_hero_card.dart
```

#### 8. Leaderboard Feature (`lib/features/leaderboard`) - 16 files
```
features/leaderboard/
├── data/
│   ├── datasources/
│   │   └── leaderboard_remote_datasource.dart
│   ├── models/
│   │   └── leaderboard_entry_model.dart
│   └── repositories/
│       └── leaderboard_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── leaderboard_entry_entity.dart
│   ├── repositories/
│   │   └── leaderboard_repository.dart
│   └── usecases/
│       └── get_leaderboard_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── leaderboard_bloc/event/state.dart (3 files)
    ├── pages/
    │   └── leaderboard_page.dart
    └── widgets/
        ├── leaderboard_card.dart
        └── rank_badge.dart
```

#### 9. Notifications Feature (`lib/features/notifications`) - 15 files
```
features/notifications/
├── data/
│   ├── datasources/
│   │   ├── notification_local_datasource.dart
│   │   └── notification_remote_datasource.dart
│   ├── models/
│   │   └── notification_model.dart
│   └── repositories/
│       └── notification_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── notification_entity.dart
│   ├── repositories/
│   │   └── notification_repository.dart
│   └── usecases/                      # 3 use cases
│       ├── get_notifications_usecase.dart
│       ├── mark_notification_read_usecase.dart
│       └── mark_all_notifications_read_usecase.dart
└── presentation/
    ├── bloc/
    │   └── notifications_bloc/event/state.dart (3 files)
    └── pages/
        └── notifications_page.dart
```

#### 10. Planner Feature (`lib/features/planner`) - 135 files ⭐ MAJOR FEATURE
```
features/planner/
├── data/
│   ├── datasources/
│   │   ├── planner_local_datasource.dart
│   │   ├── planner_remote_datasource.dart
│   │   └── planner_sync_queue.dart
│   ├── local/
│   │   └── hive_adapters/             # 10 Hive adapters
│   │       ├── centralized_subject_adapter.dart
│   │       ├── exam_entity_adapter.dart
│   │       ├── exam_schedule_adapter.dart
│   │       ├── planner_subject_adapter.dart
│   │       ├── schedule_adapter.dart
│   │       ├── schedule_entity_adapter.dart
│   │       ├── schedule_session_adapter.dart
│   │       ├── session_activity_adapter.dart
│   │       ├── session_entity_adapter.dart
│   │       └── study_session_adapter.dart
│   ├── models/                        # 11 models
│   │   ├── achievement_model.dart
│   │   ├── analytics_model.dart
│   │   ├── exam_model.dart
│   │   ├── exam_schedule_model.dart
│   │   ├── planner_subject_model.dart
│   │   ├── schedule_model.dart
│   │   ├── schedule_session_model.dart
│   │   ├── session_activity_model.dart
│   │   ├── sync_queue_item.dart
│   │   └── user_preferences_model.dart
│   ├── repositories/
│   │   ├── planner_repository_impl.dart
│   │   └── subjects_repository_impl.dart
│   └── services/
│       └── session_lifecycle_service.dart
│
├── domain/
│   ├── entities/                      # 11 entities
│   │   ├── achievement_entity.dart
│   │   ├── exam_entity.dart
│   │   ├── exam_schedule_entity.dart
│   │   ├── planner_analytics.dart
│   │   ├── planner_preferences.dart
│   │   ├── planner_subject_entity.dart
│   │   ├── schedule_entity.dart
│   │   ├── schedule_session_entity.dart
│   │   ├── session_activity_entity.dart
│   │   ├── session_entity.dart
│   │   └── subject_priority.dart
│   ├── repositories/
│   │   ├── planner_repository.dart
│   │   └── subjects_repository.dart
│   └── usecases/                      # 25+ use cases
│       ├── complete_session.dart
│       ├── create_exam.dart
│       ├── delete_exam.dart
│       ├── generate_schedule.dart
│       ├── get_achievements_usecase.dart
│       ├── get_all_subjects.dart
│       ├── get_exam_schedules.dart
│       ├── get_exams.dart
│       ├── get_missed_sessions.dart
│       ├── get_preferences.dart
│       ├── get_schedule_usecase.dart
│       ├── get_sessions.dart
│       ├── get_statistics_usecase.dart
│       ├── get_subjects_usecase.dart
│       ├── pause_session.dart
│       ├── record_exam_result.dart
│       ├── reschedule_missed_session.dart
│       ├── resume_session.dart
│       ├── save_preferences.dart
│       ├── skip_session.dart
│       ├── start_session.dart
│       └── update_exam.dart
│
└── presentation/
    ├── bloc/
    │   ├── achievements/
    │   │   ├── achievements_bloc/event/state.dart (3 files)
    │   ├── analytics/
    │   │   ├── planner_analytics_bloc/event/state.dart (3 files)
    │   ├── exam/
    │   │   ├── exam_bloc/event/state.dart (3 files)
    │   ├── planner_bloc/event/state.dart (3 files)
    │   ├── session/
    │   │   ├── session_bloc/event/state.dart (3 files)
    │   └── subjects/
    │       ├── subjects_bloc/event/state.dart (3 files)
    ├── pages/                         # 13 pages
    │   ├── achievements_page.dart
    │   ├── active_session_page.dart
    │   ├── analytics_page.dart
    │   ├── exam_detail_page.dart
    │   ├── exam_form_page.dart
    │   ├── exams_page.dart
    │   ├── planner_home_page.dart
    │   ├── planner_settings_page.dart
    │   ├── schedule_page.dart
    │   ├── session_history_page.dart
    │   ├── session_summary_page.dart
    │   ├── subjects_management_page.dart
    │   └── weekly_view_page.dart
    └── widgets/                       # 24 widgets
        ├── achievement_card.dart
        ├── active_session_controls.dart
        ├── analytics_chart.dart
        ├── analytics_stat_card.dart
        ├── calendar_day_cell.dart
        ├── calendar_header.dart
        ├── empty_schedule_widget.dart
        ├── exam_card.dart
        ├── exam_countdown_widget.dart
        ├── missed_session_card.dart
        ├── planner_quick_stats.dart
        ├── schedule_card.dart
        ├── session_activity_list.dart
        ├── session_timer_widget.dart
        ├── subject_priority_card.dart
        ├── success_animation_widget.dart
        ├── today_schedule_widget.dart
        └── weekly_calendar_widget.dart
```

#### 11. Profile Feature (`lib/features/profile`) - 37 files
```
features/profile/
├── data/
│   ├── datasources/
│   │   ├── profile_local_datasource.dart
│   │   └── profile_remote_datasource.dart
│   ├── models/                        # 4 models
│   │   ├── device_session_model.dart
│   │   ├── profile_model.dart
│   │   ├── statistics_model.dart
│   │   └── user_settings_model.dart
│   └── repositories/
│       └── profile_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 4 entities
│   │   ├── device_session_entity.dart
│   │   ├── profile_entity.dart
│   │   ├── statistics_entity.dart
│   │   └── user_settings_entity.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/                      # 10 use cases
│       ├── change_password_usecase.dart
│       ├── delete_account_usecase.dart
│       ├── get_device_sessions_usecase.dart
│       ├── get_profile_usecase.dart
│       ├── get_settings_usecase.dart
│       ├── get_statistics_usecase.dart
│       ├── logout_all_devices_usecase.dart
│       ├── logout_device_usecase.dart
│       ├── update_profile_usecase.dart
│       └── update_settings_usecase.dart
│
└── presentation/
    ├── bloc/
    │   ├── profile_bloc/event/state.dart (3 files)
    │   └── settings_bloc/event/state.dart (3 files)
    ├── pages/                         # 7 pages
    │   ├── about_app_page.dart
    │   ├── account_security_page.dart
    │   ├── device_sessions_page.dart
    │   ├── edit_profile_page.dart
    │   ├── profile_page.dart
    │   ├── settings_page.dart
    │   └── statistics_page.dart
    └── widgets/                       # 5 widgets
        ├── device_session_card.dart
        ├── profile_header.dart
        ├── settings_section.dart
        ├── stat_card_profile.dart
        └── weekly_study_chart.dart
```

#### 12. Quiz Feature (`lib/features/quiz`) - 53 files
```
features/quiz/
├── data/
│   ├── datasources/
│   │   ├── quiz_local_datasource.dart
│   │   └── quiz_remote_datasource.dart
│   ├── models/                        # 7 models
│   │   ├── answer_model.dart
│   │   ├── multiple_choice_question_model.dart
│   │   ├── question_model.dart
│   │   ├── quiz_attempt_model.dart
│   │   ├── quiz_model.dart
│   │   ├── quiz_recommendation_model.dart
│   │   └── result_model.dart
│   └── repositories/
│       └── quiz_repository_impl.dart
│
├── domain/
│   ├── entities/                      # 7 entities
│   │   ├── answer_entity.dart
│   │   ├── multiple_choice_question.dart
│   │   ├── question_entity.dart
│   │   ├── quiz_attempt_entity.dart
│   │   ├── quiz_entity.dart
│   │   ├── quiz_recommendation_entity.dart
│   │   └── result_entity.dart
│   ├── repositories/
│   │   └── quiz_repository.dart
│   └── usecases/                      # 11 use cases
│       ├── get_quiz_by_id_usecase.dart
│       ├── get_quiz_recommendations_usecase.dart
│       ├── get_quizzes_by_chapter_usecase.dart
│       ├── get_quizzes_by_subject_usecase.dart
│       ├── get_user_quiz_history_usecase.dart
│       ├── resume_quiz_usecase.dart
│       ├── save_quiz_answer_usecase.dart
│       ├── start_quiz_usecase.dart
│       ├── submit_quiz_usecase.dart
│       └── validate_answer_usecase.dart
│
└── presentation/
    ├── bloc/
    │   ├── quiz_bloc/event/state.dart (3 files)
    │   └── quiz_history/
    │       ├── quiz_history_bloc/event/state.dart (3 files)
    ├── pages/                         # 5 pages
    │   ├── quiz_history_page.dart
    │   ├── quiz_page.dart
    │   ├── quiz_result_page.dart
    │   ├── quiz_selection_page.dart
    │   └── subject_quizzes_page.dart
    └── widgets/                       # 9 widgets
        ├── answer_option_card.dart
        ├── explanation_card.dart
        ├── quiz_card.dart
        ├── quiz_header.dart
        ├── quiz_progress_bar.dart
        ├── quiz_recommendation_card.dart
        ├── result_breakdown_chart.dart
        ├── result_summary_card.dart
        └── timer_widget.dart
```

#### 13. Video Player Feature (`lib/features/videoplayer`) - 8 files
```
features/videoplayer/
├── data/
│   ├── models/
│   │   └── video_player_state_model.dart
│   └── repositories/
│       └── video_player_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── video_player_state_entity.dart
│   └── repositories/
│       └── video_player_repository.dart
└── presentation/
    ├── bloc/
    │   └── video_player_bloc/event/state.dart (3 files)
    └── pages/
        └── fullscreen_video_player_page.dart
```

---

## 2. Laravel API Backend (`d:\ta7sil\memo_api\app`)

### Root Level (1 file)
```
app/
└── Providers/
    └── AppServiceProvider.php         # Service provider configuration
```

### Console Commands (`app/Console`) - 11 files
```
Console/
├── Kernel.php                         # Console kernel
└── Commands/                          # Artisan commands (10 files)
    ├── CheckExpiringSubscriptionsCommand.php
    ├── CleanupOrphanedQuizAttempts.php
    ├── DeactivateExpiredCodesCommand.php
    ├── ExpireSubscriptionsCommand.php
    ├── FixBacSubjectIds.php
    ├── ImportQuizFromWord.php
    ├── MergeBacSubjectsDuplicates.php
    ├── MigrateTa7silBac.php
    ├── ProcessScheduledNotifications.php
    └── UpdateCourseStatisticsCommand.php
```

### Events (`app/Events`) - 5 files
```
Events/
├── AchievementUnlocked.php
├── BacSimulationCompleted.php
├── CourseUpdated.php
├── ExamScheduleCreated.php
└── StudySessionCreated.php
```

### Exports (`app/Exports`) - 8 files
```
Exports/
├── CoursesExport.php
├── CourseStatisticsExport.php
├── RevenueReportExport.php
├── SubscriptionCodeListsExport.php
├── SubscriptionCodesByListExport.php
├── SubscriptionCodesDetailedExport.php
└── SubscriptionsExport.php
```

### Helpers (`app/Helpers`) - 1 file
```
Helpers/
└── ArabicHelper.php                   # Arabic language utilities
```

### HTTP Layer (`app/Http`) - 134 files

#### Controllers (`app/Http/Controllers`) - 112 files

##### Admin Controllers (`app/Http/Controllers/Admin`) - 27 files
```
Http/Controllers/Admin/
├── AcademicPhaseController.php
├── AcademicStreamController.php
├── AcademicYearController.php
├── AdminBacStudyScheduleController.php
├── AnalyticsController.php            # Admin analytics & reports
├── AuthController.php                 # Admin authentication
├── BacController.php                  # BAC exam management
├── ChapterController.php              # Content chapters
├── ContentController.php              # Content management
├── CourseController.php               # Course CRUD ⭐
├── CourseLessonController.php         # Lesson management ⭐
├── CourseModuleController.php         # Module management ⭐
├── CourseReviewController.php         # Review moderation ⭐
├── DashboardController.php            # Admin dashboard
├── ExportController.php               # Data exports
├── NotificationController.php         # Notification management
├── PaymentReceiptController.php       # Payment receipt handling
├── PlannerController.php              # Planner admin features
├── ProfileController.php              # User profile management
├── PromoController.php                # Promotional codes
├── QuizController.php                 # Quiz management
├── SponsorController.php              # Sponsor management
├── SubjectController.php              # Subject management
├── SubjectPlannerContentController.php
├── SubscriptionAssignmentController.php
├── SubscriptionCodeController.php     # Subscription codes ⭐
├── SubscriptionCodeListController.php # Code list management ⭐
├── SubscriptionController.php         # Subscription packages ⭐
└── UserController.php                 # User management
```

##### API Controllers (`app/Http/Controllers/Api`) - 74 files

###### V1 Controllers (`app/Http/Controllers/Api/V1`) - 7 files
```
Http/Controllers/Api/V1/
├── AcademicController.php
├── BacBookmarkController.php
├── BookmarkController.php
├── ContentController.php
├── PlannerSubjectsController.php
├── ProgressController.php
├── SubjectController.php
└── Auth/
    └── AuthController.php             # Authentication API
```

###### Main API Controllers (`app/Http/Controllers/Api`) - 67 files
```
Http/Controllers/Api/
├── AnalyticsController.php
├── AppVersionController.php
├── BacArchiveController.php
├── BacStudyScheduleController.php
├── CertificateController.php          # Certificate generation ⭐
├── CouponController.php
├── CourseApiController.php            # Course API endpoints ⭐
├── DashboardController.php
├── ExamController.php
├── LeaderboardController.php
├── NotificationApiController.php
├── NotificationController.php
├── OrderController.php
├── PdfController.php
├── PlannerController.php              # Planner API
├── PlannerSubjectController.php
├── PrayerTimesController.php
├── PriorityController.php
├── ProgressApiController.php          # Progress tracking ⭐
├── PromoController.php
├── QuizAttemptController.php
├── QuizController.php
├── ReviewApiController.php            # Course reviews ⭐
├── SponsorController.php
├── StudySessionController.php
├── SubjectController.php
├── SubscriptionApiController.php      # Subscription API ⭐
├── SyncController.php
└── UserSettingsController.php
```

#### Middleware (`app/Http/Middleware`) - 3 files
```
Http/Middleware/
├── CompressResponse.php               # Response compression
├── EnsureUserIsAdmin.php             # Admin guard
└── TrackUserActivity.php             # Activity tracking
```

#### Requests (`app/Http/Requests`) - 3 files
```
Http/Requests/
├── ChangePasswordRequest.php
├── UpdateProfileRequest.php
└── UpdateSettingsRequest.php
```

#### Resources (`app/Http/Resources`) - 8 files
```
Http/Resources/
├── AcademicProfileResource.php
├── CourseResource.php                 # Course API resource ⭐
├── DeviceSessionResource.php
├── PlannerStudySessionResource.php
├── ProfileResource.php
├── SubjectResource.php
├── UserSettingsResource.php
└── UserStatsResource.php
```

### Imports (`app/Imports`) - 1 file
```
Imports/
└── QuestionsImport.php                # Quiz question import
```

### Jobs (Background Tasks) (`app/Jobs`) - 21 files
```
Jobs/
├── AdaptSchedulesJob.php
├── CalculateUserStatisticsJob.php
├── CheckMissedSessionsJob.php
├── CheckUpcomingSessionsJob.php
├── GenerateMonthlyReportsJob.php
├── GenerateScheduleJob.php
├── GenerateWeeklyReportsJob.php
├── ProcessDueNotificationsJob.php
├── ProcessVideoUploadJob.php
├── RecalculatePrioritiesJob.php
├── SendDailySummariesJob.php
├── SendDailySummaryJob.php
├── SendExamAlertsJob.php
├── SendWeeklySummariesJob.php
├── SendWeeklySummaryJob.php
└── Planner/                           # Planner-specific jobs (4 files)
    ├── AdaptSchedulesJob.php
    ├── CheckMissedSessionsJob.php
    ├── RecalculatePrioritiesJob.php
    └── SendSessionRemindersJob.php
```

### Listeners (Event Listeners) (`app/Listeners`) - 5 files
```
Listeners/
├── ScheduleExamAlerts.php
├── ScheduleStudySessionReminder.php
├── SendAchievementNotification.php
├── SendCourseUpdateNotification.php   # Course update listener ⭐
└── UpdatePlannerAfterSimulation.php
```

### Models (Eloquent Models) (`app/Models`) - 85 files ⭐

#### Core Models
```
Models/
├── User.php                           # Main user model
├── UserProfile.php
├── UserPreferences.php
├── UserActivityLog.php
├── UserStats.php
├── DeviceSession.php
├── DeviceTransferRequest.php
└── AppSetting.php
```

#### Academic System Models
```
Models/Academic/
├── AcademicPhase.php                  # Primary/Middle/Secondary
├── AcademicStream.php                 # Science/Literature streams
├── AcademicYear.php                   # Year levels
└── UserAcademicProfile.php
```

#### Course System Models ⭐
```
Models/Courses/
├── Course.php                         # Main course model
├── CourseModule.php                   # Course modules
├── CourseLesson.php                   # Individual lessons
├── CourseLessonAttachment.php         # Lesson attachments (PDFs, etc.)
├── CourseQuiz.php                     # Quizzes within courses
├── CourseReview.php                   # Course reviews & ratings
├── UserCourseProgress.php             # User progress per course
├── UserLessonProgress.php             # User progress per lesson
├── Certificate.php                    # Course certificates
├── SubscriptionPackage.php            # Subscription packages
├── UserSubscription.php               # User subscriptions
├── SubscriptionCode.php               # Redemption codes
├── SubscriptionCodeList.php           # Code batch management
├── PaymentReceipt.php                 # Payment receipt uploads
└── Order.php                          # Course orders
```

#### Content Library Models
```
Models/Content/
├── Subject.php                        # Academic subjects
├── Chapter.php                        # Subject chapters
├── Content.php                        # Learning content
├── ContentType.php                    # Content type taxonomy
├── SubjectContentType.php             # Subject-content relationship
├── UserContentProgress.php            # Content progress tracking
├── Bookmark.php                       # Bookmarked content
└── SubjectPlannerContent.php
```

#### BAC Exam Models
```
Models/Bac/
├── BacYear.php                        # BAC exam years
├── BacSession.php                     # Normal/Resit sessions
├── BacSubject.php                     # BAC subjects
├── BacSubjectChapter.php              # Subject chapters
├── BacSimulation.php                  # Practice simulations
├── BacStudyDay.php                    # Study schedule days
├── BacDaySubject.php                  # Subjects per day
├── BacDayTopic.php                    # Topics per subject
├── BacBookmark.php                    # Bookmarked questions
├── UserBacPerformance.php             # User performance tracking
└── SimulationResult.php
```

#### Quiz System Models
```
Models/Quiz/
├── Quiz.php                           # Quiz definition
├── Question.php                       # Quiz questions
├── Answer.php                         # Question answers
├── QuizAttempt.php                    # User quiz attempts
├── UserQuizPerformance.php            # Quiz performance tracking
└── QuizRecommendation.php
```

#### Planner System Models
```
Models/Planner/
├── StudySchedule.php                  # Generated schedules
├── StudySession.php                   # Study sessions
├── SessionActivity.php                # Session activity logs
├── ExamSchedule.php                   # Exam schedules
├── UserSubject.php                    # User-subject assignments
├── UserSubjectProgress.php            # Subject progress
├── SubjectPriority.php                # Dynamic priority
├── PrayerTime.php                     # Prayer time integration
└── Achievement.php                    # Achievements
```

#### Notification & Engagement Models
```
Models/
├── Notification.php                   # Push notifications
├── UserNotificationSetting.php        # Notification preferences
├── Sponsor.php                        # Sponsor content
├── Promo.php                          # Promotional content
└── Coupon.php                         # Discount coupons
```

### Notifications (`app/Notifications`) - 6 files
```
Notifications/
├── CourseProgressMilestoneNotification.php    # Progress notifications ⭐
├── NewCourseAnnouncementNotification.php      # New course alerts ⭐
├── PaymentReceiptStatusNotification.php        # Payment status ⭐
├── SubscriptionActivatedNotification.php       # Subscription activated ⭐
└── SubscriptionExpiringNotification.php        # Expiry warnings ⭐
```

### Observers (Model Observers) (`app/Observers`) - 4 files
```
Observers/
├── ContentObserver.php                # Content lifecycle events
├── CourseObserver.php                 # Course lifecycle events ⭐
├── SubjectObserver.php                # Subject lifecycle events
└── UserObserver.php                   # User lifecycle events
```

### Policies (Authorization) (`app/Policies`) - 0 files
```
Policies/
└── [Empty - policies may be defined inline]
```

### Services (Business Logic) (`app/Services`) - 14 files
```
Services/
├── AdaptationService.php              # Schedule adaptation
├── CacheService.php                   # Caching layer
├── CodeGenerationService.php          # Code generation ⭐
├── CourseProgressService.php          # Progress tracking ⭐
├── CourseService.php                  # Course CRUD operations ⭐
├── QuizRecommendationService.php      # Quiz recommendations
├── QuizService.php                    # Quiz logic
├── ReportGenerationService.php        # Report generation
├── SubscriptionService.php            # Subscription management ⭐
└── Exports/
    ├── CodeExportService.php          # Code export ⭐
    ├── CourseExportService.php        # Course export ⭐
    └── PaymentReceiptExportService.php # Receipt export ⭐
```

---

## Feature File Counts Summary

| Feature | Flutter Files | Laravel Files | Total |
|---------|---------------|---------------|-------|
| **Courses** ⭐ | 102 | 35 | 137 |
| **Planner** | 135 | 20 | 155 |
| **Quiz** | 53 | 12 | 65 |
| **BAC** | 47 | 18 | 65 |
| **BAC Study** | 31 | 8 | 39 |
| **Content Library** | 45 | 10 | 55 |
| **Profile** | 37 | 8 | 45 |
| **Auth** | 25 | 6 | 31 |
| **Home** | 23 | 5 | 28 |
| **Leaderboard** | 16 | 3 | 19 |
| **Notifications** | 15 | 8 | 23 |
| **Focus Mode** | 8 | 2 | 10 |
| **Video Player** | 8 | 0 | 8 |
| **Core/Shared** | 68 | 50 | 118 |
| **TOTAL** | **728** | **275** | **1003** |

---

## Architecture Patterns

### Flutter App Architecture
- **Clean Architecture** with 3 layers:
  - **Presentation Layer**: BLoC pattern for state management
  - **Domain Layer**: Use cases and entities
  - **Data Layer**: Repositories, data sources, and models

### Laravel API Architecture
- **MVC Pattern** with:
  - **Models**: Eloquent ORM
  - **Controllers**: RESTful API controllers
  - **Services**: Business logic layer
  - **Jobs**: Background processing
  - **Events/Listeners**: Event-driven architecture

---

## Key Technologies

### Flutter App
- **State Management**: flutter_bloc
- **Local Storage**: Hive + secure_storage
- **Networking**: Dio HTTP client
- **Video Players**: Multiple implementations (Chewie, Media Kit, Orax, YouTube)
- **Navigation**: go_router

### Laravel API
- **Framework**: Laravel 10.x
- **Database**: MySQL
- **Queue**: Laravel Queue (Redis/Database)
- **Storage**: Laravel Storage (S3/Local)
- **Cache**: Redis

---

**Note**: This tree represents the production codebase as of December 18, 2025. File counts may vary slightly as development continues.
