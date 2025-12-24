# Project Tree - MEMO App

**Dernière mise à jour:** 17/12/2025 (Course Subscription Feature Completion)
**Total fichiers:** 283 (+1 payment_options_bottom_sheet.dart)

---

## Structure Complète

```
memo_app/
├── lib/
│   ├── main.dart
│   ├── app_router.dart
│   ├── injection_container.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_design_tokens.dart       # NEW: Design system tokens
│   │   │   ├── app_sizes.dart
│   │   │   ├── app_strings_ar.dart
│   │   │   └── api_constants.dart
│   │   │
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   │
│   │   ├── network/
│   │   │   └── dio_client.dart
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   └── hive_service.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── gradient_helper.dart         # NEW: Gradient utilities
│   │   │   └── pdf_font_loader.dart         # ✅ NEW (2025-12-15): Arabic font loader for PDF exports
│   │   │
│   │   ├── services/                          # NEW: Core Services
│   │   │   ├── notification_service.dart      # FCM push notifications handling
│   │   │   ├── fcm_token_service.dart         # FCM token registration & refresh
│   │   │   └── connectivity_service.dart      # Network connectivity monitoring
│   │   │
│   │   ├── video_player/                      # Video Player Abstraction Layer
│   │   │   ├── domain/
│   │   │   │   ├── video_player_interface.dart     # IVideoPlayer abstract interface
│   │   │   │   └── video_player_factory.dart       # Factory for player instances
│   │   │   │
│   │   │   └── infrastructure/
│   │   │       ├── chewie_player_impl.dart         # Chewie implementation
│   │   │       ├── media_kit_player_impl.dart      # Media Kit implementation
│   │   │       ├── simple_youtube_player_impl.dart # Simple YouTube implementation
│   │   │       ├── omni_video_player_impl.dart     # Omni Video Player implementation
│   │   │       └── orax_player_impl.dart           # Orax Video Player (YouTube + quality)
│   │   │
│   │   └── widgets/
│   │       ├── gradient_subject_card.dart          # NEW: Reusable gradient subject card (used by Content Library & BAC Archives)
│   │       │
│   │       ├── cards/                        # NEW: Card components
│   │       │   ├── gradient_hero_card.dart
│   │       │   ├── stat_card_mini.dart
│   │       │   ├── progress_card.dart
│   │       │   ├── session_card.dart
│   │       │   ├── info_card.dart
│   │       │   ├── bac_archives_card.dart
│   │       │   ├── active_session_timer_card.dart  # NEW: Active session timer with pulse animation
│   │       │   ├── modern_stat_card.dart           # NEW: Modern stat card (3-column layout)
│   │       │   └── modern_section_card.dart        # NEW: Section card with header
│   │       │
│   │       ├── badges/                       # NEW: Badge components
│   │       │   ├── stat_badge.dart
│   │       │   ├── time_badge.dart
│   │       │   ├── coefficient_badge.dart
│   │       │   └── level_badge.dart
│   │       │
│   │       ├── layouts/                      # NEW: Layout components
│   │       │   ├── section_header.dart
│   │       │   ├── page_scaffold.dart
│   │       │   └── grid_layout.dart
│   │       │
│   │       ├── inputs/                       # NEW: Input components
│   │       │   ├── app_search_bar.dart
│   │       │   └── filter_chip_group.dart
│   │       │
│   │       ├── modern_bottom_nav.dart        # Updated: 4 items (الرئيسية, دوراتي, بلانر, حسابي)
│   │       ├── category_chips.dart           # NEW: Horizontal category chips with swipe support
│   │       ├── main_app_bar.dart             # NEW: Custom app bar with categories
│   │       ├── primary_button.dart
│   │       ├── secondary_button.dart
│   │       ├── app_text_field.dart
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       ├── empty_state_widget.dart
│   │       ├── stat_card.dart
│   │       ├── subject_card.dart
│   │       └── rtl_helper.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── user_entity.dart
│       │   │   │   └── academic_profile_entity.dart
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── login_usecase.dart
│       │   │       ├── register_usecase.dart
│       │   │       ├── validate_token_usecase.dart
│       │   │       └── logout_usecase.dart
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── user_model.dart
│       │   │   │   ├── user_model.g.dart (generated)
│       │   │   │   ├── login_response_model.dart
│       │   │   │   └── login_response_model.g.dart (generated)
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── auth_remote_datasource.dart
│       │   │   │   └── auth_local_datasource.dart
│       │   │   │
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── auth_event.dart
│       │       │   ├── auth_state.dart
│       │       │   └── auth_bloc.dart
│       │       │
│       │       ├── pages/
│       │       │   ├── splash_page.dart
│       │       │   ├── onboarding_page.dart
│       │       │   ├── login_page.dart
│       │       │   ├── register_page.dart
│       │       │   └── academic_selection_page.dart
│       │       │
│       │       └── widgets/
│       │           └── selection_card.dart
│       │
│       ├── home/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── stats_entity.dart
│       │   │   │   ├── study_session_entity.dart
│       │   │   │   ├── subject_progress_entity.dart
│       │   │   │   └── promo_entity.dart             # NEW: Promo entity + PromosResponse
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   ├── home_repository.dart
│       │   │   │   └── promo_repository.dart         # NEW: Promo repository interface
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── get_dashboard_data_usecase.dart
│       │   │       ├── mark_session_completed_usecase.dart
│       │   │       ├── get_promos_usecase.dart       # NEW: Fetch promos
│       │   │       └── record_promo_click_usecase.dart  # NEW: Record promo click
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── stats_model.dart
│       │   │   │   ├── study_session_model.dart
│       │   │   │   ├── subject_progress_model.dart
│       │   │   │   └── promo_model.dart              # NEW: Promo model + PromoApiResponse
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── home_remote_datasource.dart
│       │   │   │   ├── home_local_datasource.dart
│       │   │   │   └── promo_remote_datasource.dart  # NEW: Promo API calls
│       │   │   │
│       │   │   └── repositories/
│       │   │       ├── home_repository_impl.dart
│       │   │       └── promo_repository_impl.dart    # NEW: Promo repository impl
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── home_bloc.dart
│       │       │   ├── home_event.dart
│       │       │   ├── home_state.dart
│       │       │   └── promo/                        # NEW: Promo BLoC
│       │       │       ├── promo_bloc.dart
│       │       │       ├── promo_event.dart
│       │       │       └── promo_state.dart
│       │       ├── pages/
│       │       │   ├── main_screen.dart          # NEW: Main entry with PageView navigation
│       │       │   ├── home_content_view.dart    # UPDATED: Redesigned with 7 modern sections
│       │       │   ├── planner_preview_view.dart # NEW: بلانر preview (swipe category)
│       │       │   ├── content_library_view.dart # NEW: ملخصات و دروس category
│       │       │   ├── bac_archives_view.dart    # NEW: بكالوريات category
│       │       │   ├── quiz_list_view.dart       # NEW: كويز category
│       │       │   ├── courses_view.dart         # NEW: دوراتنا category
│       │       │   └── home_page.dart            # Legacy (replaced by MainScreen)
│       │       └── widgets/
│       │           ├── user_hero_card.dart              # NEW: Glassmorphism hero with level, XP, avatar
│       │           ├── quick_actions_grid.dart          # NEW: 2x2 grid for quick actions
│       │           ├── weekly_progress_widget.dart      # NEW: 7-day bar chart with animations
│       │           ├── leaderboard_preview_widget.dart  # NEW: Top 3 + user position preview
│       │           ├── promo_slider_widget.dart         # UPDATED: Dynamic promo slider with API integration
│       │           └── sponsors_carousel_widget.dart    # Sponsors carousel
│       │
│       ├── bac/                    # BAC Archives & Simulation Feature (NEW)
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── bac_year_entity.dart
│       │   │   │   ├── bac_session_entity.dart
│       │   │   │   ├── bac_subject_entity.dart
│       │   │   │   ├── bac_chapter_info_entity.dart
│       │   │   │   ├── bac_simulation_entity.dart
│       │   │   │   ├── chapter_score_entity.dart
│       │   │   │   └── simulation_results_entity.dart
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   └── bac_repository.dart
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── get_bac_years_usecase.dart
│       │   │       ├── get_bac_sessions_usecase.dart
│       │   │       ├── get_bac_subjects_usecase.dart
│       │   │       ├── get_bac_subject_detail_usecase.dart
│       │   │       ├── start_simulation_usecase.dart
│       │   │       ├── get_simulation_status_usecase.dart
│       │   │       ├── submit_simulation_usecase.dart
│       │   │       ├── download_bac_subject_usecase.dart
│       │   │       ├── delete_download_usecase.dart
│       │   │       ├── get_user_performance_usecase.dart
│       │   │       └── get_my_simulations_usecase.dart
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── bac_year_model.dart
│       │   │   │   ├── bac_session_model.dart
│       │   │   │   ├── bac_subject_model.dart
│       │   │   │   ├── bac_chapter_info_model.dart
│       │   │   │   ├── bac_simulation_model.dart
│       │   │   │   ├── chapter_score_model.dart
│       │   │   │   └── simulation_results_model.dart
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── bac_remote_datasource.dart
│       │   │   │   ├── bac_local_datasource.dart
│       │   │   │   └── bac_download_manager.dart
│       │   │   │
│       │   │   └── repositories/
│       │   │       └── bac_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── bac_bloc.dart
│       │       │   ├── bac_event.dart
│       │       │   ├── bac_state.dart
│       │       │   ├── simulation_timer_cubit.dart
│       │       │   └── simulation_timer_state.dart
│       │       │
│       │       ├── pages/
│       │       │   ├── bac_archives_page.dart
│       │       │   ├── bac_subject_detail_page.dart
│       │       │   ├── bac_simulation_page.dart
│       │       │   ├── bac_self_evaluation_page.dart
│       │       │   ├── bac_results_page.dart
│       │       │   └── bac_performance_page.dart
│       │       │
│       │       └── widgets/
│       │           ├── year_card.dart
│       │           ├── session_chip.dart
│       │           ├── bac_subject_card.dart
│       │           ├── info_row.dart
│       │           ├── chapter_info_card.dart
│       │           ├── user_history_chart.dart
│       │           ├── simulation_mode_dialog.dart
│       │           ├── simulation_header.dart
│       │           ├── simulation_footer.dart
│       │           ├── timer_alert_dialog.dart
│       │           ├── chapter_evaluation_section.dart
│       │           ├── total_score_card.dart
│       │           ├── difficulty_selector.dart
│       │           ├── chapter_breakdown_item.dart
│       │           ├── weak_chapter_card.dart
│       │           ├── recommendations_list.dart
│       │           ├── progress_chart.dart
│       │           └── download_progress_dialog.dart
│       │
│       ├── planner/                # Intelligent Planner Feature (UPDATED)
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── selectable_subject.dart
│       │   │   │   ├── planner_subject.dart
│       │   │   │   ├── planner_subject_create.dart
│       │   │   │   ├── planner_session.dart
│       │   │   │   ├── exam.dart
│       │   │   │   ├── schedule_generation_params.dart
│       │   │   │   ├── achievement.dart            # NEW: Achievements entity
│       │   │   │   └── points_history.dart         # NEW: Points history entity
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   └── planner_repository.dart
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── get_academic_subjects.dart
│       │   │       ├── batch_create_planner_subjects.dart
│       │   │       ├── get_user_planner_subjects.dart
│       │   │       ├── update_planner_subject.dart
│       │   │       ├── delete_planner_subject.dart
│       │   │       ├── generate_schedule.dart
│       │   │       ├── get_today_sessions.dart
│       │   │       ├── get_week_sessions.dart
│       │   │       ├── start_session.dart
│       │   │       ├── pause_session.dart
│       │   │       ├── resume_session.dart
│       │   │       ├── complete_session.dart
│       │   │       ├── create_exam.dart
│       │   │       ├── get_user_exams.dart
│       │   │       ├── get_achievements.dart          # NEW: Fetch achievements
│       │   │       ├── get_points_history.dart        # NEW: Fetch points history
│       │   │       ├── record_exam_result.dart        # NEW: Record exam results
│       │   │       └── trigger_adaptation.dart        # NEW: Trigger schedule adaptation
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── selectable_subject_model.dart
│       │   │   │   ├── planner_subject_model.dart
│       │   │   │   ├── planner_session_model.dart
│       │   │   │   ├── exam_model.dart
│       │   │   │   ├── schedule_response_model.dart
│       │   │   │   ├── achievement_model.dart         # NEW: Achievement model
│       │   │   │   └── points_history_model.dart      # NEW: Points history model
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── planner_remote_datasource.dart
│       │   │   │   └── planner_local_datasource.dart
│       │   │   │
│       │   │   └── repositories/
│       │   │       └── planner_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── subject_selection/
│       │       │   │   ├── subject_selection_bloc.dart
│       │       │   │   ├── subject_selection_event.dart
│       │       │   │   └── subject_selection_state.dart
│       │       │   │
│       │       │   ├── planner/
│       │       │   │   ├── planner_bloc.dart
│       │       │   │   ├── planner_event.dart
│       │       │   │   └── planner_state.dart
│       │       │   │
│       │       │   ├── session_timer/
│       │       │   │   ├── session_timer_cubit.dart
│       │       │   │   └── session_timer_state.dart
│       │       │   │
│       │       │   ├── exam/
│       │       │   │   ├── exam_bloc.dart
│       │       │   │   ├── exam_event.dart
│       │       │   │   └── exam_state.dart
│       │       │   │
│       │       │   ├── achievements/                  # NEW: Achievements BLoC
│       │       │   │   ├── achievements_bloc.dart
│       │       │   │   ├── achievements_event.dart
│       │       │   │   └── achievements_state.dart
│       │       │   │
│       │       │   └── points_history/                # NEW: Points History BLoC
│       │       │       ├── points_history_bloc.dart
│       │       │       ├── points_history_event.dart
│       │       │       └── points_history_state.dart
│       │       │
│       │       ├── screens/                            # Renamed from pages
│       │       │   ├── subject_selection_page.dart
│       │       │   ├── planner_main_page.dart
│       │       │   ├── schedule_generation_page.dart
│       │       │   ├── session_detail_page.dart        # Reference design for modern UI
│       │       │   ├── session_execution_page.dart
│       │       │   ├── planner_settings_page.dart      # Updated: Modern design
│       │       │   ├── today_view_screen.dart          # Updated: Modern design
│       │       │   ├── full_schedule_screen.dart       # Updated: Modern design
│       │       │   ├── analytics_dashboard_screen.dart # Updated: Modern design
│       │       │   ├── session_history_screen.dart     # Updated: Modern design
│       │       │   ├── exam_calendar_page.dart
│       │       │   ├── subjects_management_page.dart
│       │       │   ├── achievements_screen.dart        # NEW: Achievements display screen
│       │       │   ├── points_history_screen.dart      # NEW: Points history screen
│       │       │   └── exam_result_screen.dart         # NEW: Exam result recording screen
│       │       │
│       │       └── widgets/
│       │           ├── shared/                     # NEW: Shared design components
│       │           │   └── planner_design_constants.dart  # Design system (colors, decorations)
│       │           ├── selectable_subject_card.dart
│       │           ├── subject_group_header.dart
│       │           ├── priority_selector.dart
│       │           ├── difficulty_star_rating.dart
│       │           ├── session_timeline_item.dart
│       │           ├── week_calendar.dart
│       │           ├── pomodoro_timer.dart
│       │           ├── energy_level_selector.dart
│       │           ├── prayer_times_card.dart
│       │           ├── session_card.dart              # Updated: Modern design
│       │           ├── timeline_widget.dart           # Updated: Modern timeline
│       │           ├── empty_schedule_widget.dart     # Updated: Modern empty state
│       │           ├── achievement_card.dart          # NEW: Achievement card widget
│       │           └── adaptation_button.dart         # NEW: Adaptation trigger button
│       │
│       ├── courses/                # Courses Feature (COMPLETE)
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── course_entity.dart
│       │   │   │   ├── course_module_entity.dart
│       │   │   │   ├── course_lesson_entity.dart
│       │   │   │   ├── lesson_attachment_entity.dart
│       │   │   │   ├── course_progress_entity.dart
│       │   │   │   ├── lesson_progress_entity.dart
│       │   │   │   ├── course_review_entity.dart
│       │   │   │   ├── certificate_entity.dart
│       │   │   │   ├── subscription_package_entity.dart
│       │   │   │   ├── user_subscription_entity.dart
│       │   │   │   └── payment_receipt_entity.dart
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   ├── courses_repository.dart
│       │   │   │   └── subscription_repository.dart
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── get_courses_usecase.dart
│       │   │       ├── get_featured_courses_usecase.dart
│       │   │       ├── get_course_details_usecase.dart
│       │   │       ├── get_course_modules_usecase.dart
│       │   │       ├── check_course_access_usecase.dart
│       │   │       ├── get_signed_video_url_usecase.dart
│       │   │       ├── mark_lesson_completed_usecase.dart
│       │   │       ├── update_lesson_progress_usecase.dart
│       │   │       ├── get_lesson_progress_usecase.dart
│       │   │       ├── get_course_reviews_usecase.dart
│       │   │       ├── submit_review_usecase.dart
│       │   │       ├── get_subscription_packages_usecase.dart
│       │   │       ├── get_my_subscriptions_usecase.dart
│       │   │       ├── redeem_subscription_code_usecase.dart
│       │   │       ├── validate_subscription_code_usecase.dart
│       │   │       ├── submit_receipt_usecase.dart
│       │   │       ├── get_my_receipts_usecase.dart
│       │   │       ├── generate_certificate_usecase.dart
│       │   │       └── get_my_courses_usecase.dart
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── course_model.dart
│       │   │   │   ├── course_module_model.dart
│       │   │   │   ├── course_lesson_model.dart
│       │   │   │   ├── lesson_attachment_model.dart
│       │   │   │   ├── course_progress_model.dart
│       │   │   │   ├── lesson_progress_model.dart
│       │   │   │   ├── course_review_model.dart
│       │   │   │   ├── certificate_model.dart
│       │   │   │   ├── subscription_package_model.dart
│       │   │   │   ├── user_subscription_model.dart
│       │   │   │   └── payment_receipt_model.dart
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── courses_remote_datasource.dart
│       │   │   │   └── courses_local_datasource.dart
│       │   │   │
│       │   │   └── repositories/
│       │   │       ├── courses_repository_impl.dart
│       │   │       └── subscription_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── courses/
│       │       │   │   ├── courses_bloc.dart
│       │       │   │   ├── courses_event.dart
│       │       │   │   └── courses_state.dart
│       │       │   │
│       │       │   ├── video_player/
│       │       │   │   ├── video_player_bloc.dart
│       │       │   │   ├── video_player_event.dart
│       │       │   │   └── video_player_state.dart
│       │       │   │
│       │       │   └── subscription/
│       │       │       ├── subscription_bloc.dart
│       │       │       ├── subscription_event.dart
│       │       │       └── subscription_state.dart
│       │       │
│       │       ├── pages/
│       │       │   ├── courses_page.dart
│       │       │   ├── course_detail_page.dart
│       │       │   ├── course_learning_page.dart
│       │       │   ├── video_player_page.dart
│       │       │   ├── lesson_detail_page.dart         # NEW: Lesson detail with video, attachments, quiz
│       │       │   ├── pdf_viewer_page.dart            # NEW: PDF attachment viewer
│       │       │   ├── subscriptions_page.dart
│       │       │   ├── payment_receipt_page.dart
│       │       │   └── my_receipts_page.dart
│       │       │
│       │       └── widgets/
│       │           ├── course_card.dart
│       │           ├── modern_course_list_card.dart   # NEW: Modern card with image cover
│       │           ├── course_card_shimmer.dart
│       │           ├── featured_courses_carousel.dart
│       │           ├── course_instructor_card.dart
│       │           ├── course_module_item.dart
│       │           ├── course_stats_row.dart
│       │           ├── subscription_code_dialog.dart   # Updated: Added courseId & onSuccess callback
│       │           ├── payment_options_bottom_sheet.dart  # NEW: Payment options (Code, Baridi Mob, CCP)
│       │           ├── modern_code_input.dart          # Code input widget for subscription
│       │           ├── subscription_hero_header.dart
│       │           ├── subscription_package_card.dart
│       │           ├── receipt_status_card.dart
│       │           ├── my_course_card.dart
│       │           ├── attachment_card.dart            # NEW: Attachment card widget
│       │           └── modern/
│       │               ├── modern_course_card.dart
│       │               ├── modern_course_header.dart
│       │               ├── modern_course_progress_card.dart
│       │               ├── modern_course_stats.dart
│       │               ├── modern_curriculum_section.dart
│       │               ├── modern_lesson_item.dart
│       │               ├── course_level_badge.dart
│       │               ├── course_enrollment_badge.dart
│       │               ├── modern_rating_summary.dart
│       │               ├── modern_review_card.dart
│       │               └── modern_review_form.dart
│       │
│       ├── video_player/          # Unified Video Player Feature (NEW)
│       │   ├── domain/
│       │   │   └── entities/
│       │   │       └── video_config.dart           # Video configuration entity
│       │   │
│       │   ├── di/
│       │   │   └── video_player_injection.dart     # Dependency injection
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── unified_video_player_bloc.dart
│       │       │   ├── unified_video_player_event.dart
│       │       │   └── unified_video_player_state.dart
│       │       │
│       │       ├── pages/
│       │       │   └── unified_video_player_page.dart  # Main player page + widget
│       │       │
│       │       └── widgets/
│       │           ├── video_loading_state.dart      # Loading indicator
│       │           ├── video_error_state.dart        # Error display
│       │           ├── video_player_widget.dart      # Core video widget
│       │           ├── video_info_card.dart          # Info card with progress
│       │           ├── video_quick_actions.dart      # Quick action buttons
│       │           └── video_bottom_bar.dart         # Bottom action bar
│       │
│       ├── quiz/                  # Quiz Feature (COMPLETE)
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── quiz_entity.dart
│       │   │   │   ├── quiz_attempt_entity.dart
│       │   │   │   ├── quiz_result_entity.dart
│       │   │   │   ├── quiz_performance_entity.dart
│       │   │   │   ├── single_choice_question.dart
│       │   │   │   ├── multiple_choice_question.dart
│       │   │   │   ├── true_false_question.dart
│       │   │   │   ├── fill_blank_question.dart
│       │   │   │   ├── short_answer_question.dart
│       │   │   │   ├── numeric_question.dart
│       │   │   │   ├── matching_question.dart
│       │   │   │   └── ordering_question.dart
│       │   │   │
│       │   │   ├── repositories/
│       │   │   │   └── quiz_repository.dart
│       │   │   │
│       │   │   └── usecases/
│       │   │       ├── get_quizzes_usecase.dart
│       │   │       ├── get_quiz_details_usecase.dart
│       │   │       ├── start_quiz_usecase.dart
│       │   │       ├── submit_quiz_usecase.dart
│       │   │       ├── abandon_quiz_usecase.dart
│       │   │       ├── get_quiz_results_usecase.dart
│       │   │       └── get_quiz_review_usecase.dart
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── quiz_model.dart
│       │   │   │
│       │   │   ├── datasources/
│       │   │   │   ├── quiz_remote_datasource.dart
│       │   │   │   └── quiz_local_datasource.dart
│       │   │   │
│       │   │   └── repositories/
│       │   │       └── quiz_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── quiz_list/
│       │       │   │   ├── quiz_list_bloc.dart
│       │       │   │   ├── quiz_list_event.dart
│       │       │   │   └── quiz_list_state.dart
│       │       │   │
│       │       │   ├── quiz_detail/
│       │       │   │   ├── quiz_detail_bloc.dart
│       │       │   │   ├── quiz_detail_event.dart
│       │       │   │   └── quiz_detail_state.dart
│       │       │   │
│       │       │   ├── quiz_attempt/
│       │       │   │   ├── quiz_attempt_bloc.dart
│       │       │   │   ├── quiz_attempt_event.dart
│       │       │   │   └── quiz_attempt_state.dart
│       │       │   │
│       │       │   ├── quiz_results/
│       │       │   │   ├── quiz_results_bloc.dart
│       │       │   │   ├── quiz_results_event.dart
│       │       │   │   └── quiz_results_state.dart
│       │       │   │
│       │       │   └── quiz_timer/
│       │       │       ├── quiz_timer_cubit.dart
│       │       │       └── quiz_timer_state.dart
│       │       │
│       │       ├── pages/
│       │       │   ├── quiz_list_page.dart
│       │       │   ├── subject_quizzes_page.dart
│       │       │   ├── quiz_detail_page.dart
│       │       │   ├── quiz_taking_page.dart
│       │       │   ├── quiz_results_page.dart
│       │       │   └── quiz_review_page.dart
│       │       │
│       │       └── widgets/
│       │           ├── quiz_card.dart
│       │           ├── subject_quiz_card.dart
│       │           ├── quiz_filter_sheet.dart
│       │           ├── quiz_progress_bar.dart
│       │           ├── quiz_stats_card.dart
│       │           ├── quiz_timer_widget.dart
│       │           ├── question_header.dart
│       │           ├── question_navigation.dart
│       │           └── questions/
│       │               ├── single_choice_widget.dart
│       │               ├── multiple_choice_widget.dart
│       │               ├── true_false_widget.dart
│       │               ├── fill_blank_widget.dart
│       │               ├── short_answer_widget.dart
│       │               ├── numeric_widget.dart
│       │               ├── matching_widget.dart
│       │               └── ordering_widget.dart
│       │
│       └── profile/                # Profile Management Feature ✅ PHASE 1 & 2 COMPLETE
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── profile_entity.dart
│           │   │   ├── statistics_entity.dart
│           │   │   ├── settings_entity.dart
│           │   │   └── device_session_entity.dart
│           │   │
│           │   ├── repositories/
│           │   │   ├── profile_repository.dart
│           │   │   ├── statistics_repository.dart
│           │   │   └── settings_repository.dart
│           │   │
│           │   └── usecases/
│           │       └── delete_account_usecase.dart  ✅ NEW (Phase 1.2 - GDPR)
│           │
│           ├── data/
│           │   ├── models/
│           │   │   ├── profile_model.dart
│           │   │   ├── profile_model.g.dart (generated)
│           │   │   ├── statistics_model.dart
│           │   │   ├── statistics_model.g.dart (generated)
│           │   │   ├── settings_model.dart
│           │   │   ├── settings_model.g.dart (generated)
│           │   │   ├── device_session_model.dart
│           │   │   └── device_session_model.g.dart (generated)
│           │   │
│           │   └── datasources/
│           │       ├── profile_remote_datasource.dart
│           │       ├── profile_local_datasource.dart
│           │       ├── statistics_remote_datasource.dart
│           │       ├── statistics_local_datasource.dart
│           │       └── settings_local_datasource.dart
│           │
│           └── presentation/
│               ├── pages/
│               │   ├── profile_page.dart
│               │   ├── edit_profile_page.dart          ✅ UPDATED (Phase 1.3 - Photo Upload)
│               │   ├── change_password_page.dart       ✅ UPDATED (Phase 1.1 - Password Strength)
│               │   ├── delete_account_page.dart        ✅ NEW (Phase 1.2 - GDPR Deletion)
│               │   ├── statistics_page.dart            ✅ UPDATED (Phase 2 - Charts Integration)
│               │   └── settings_page.dart
│               │
│               └── widgets/
│                   ├── password_strength_indicator.dart   ✅ NEW (Phase 1.1)
│                   ├── password_requirements_checklist.dart ✅ NEW (Phase 1.1)
│                   ├── delete_account_warning.dart      ✅ NEW (Phase 1.2)
│                   ├── weekly_study_chart.dart          ✅ NEW (Phase 2.1 - Bar Chart)
│                   ├── achievement_badge.dart           ✅ NEW (Phase 2.2 - Single Badge)
│                   ├── achievements_grid.dart           ✅ NEW (Phase 2.2 - Grid Layout)
│                   └── streak_calendar.dart             ✅ NEW (Phase 2.3 - Calendar)
│
│       └── notifications/               # Notifications Feature (NEW)
│           ├── domain/
│           │   ├── entities/
│           │   │   └── notification_entity.dart      # NotificationEntity, NotificationsListEntity
│           │   │
│           │   └── repositories/
│           │       └── notification_repository.dart  # Abstract repository interface
│           │
│           ├── data/
│           │   ├── models/
│           │   │   └── notification_model.dart       # NotificationModel with Hive adapter
│           │   │
│           │   ├── datasources/
│           │   │   ├── notification_remote_datasource.dart  # API calls for notifications
│           │   │   └── notification_local_datasource.dart   # Hive cache for offline
│           │   │
│           │   └── repositories/
│           │       └── notification_repository_impl.dart    # Repository implementation
│           │
│           └── presentation/
│               ├── bloc/
│               │   ├── notifications_bloc.dart       # Main notifications BLoC
│               │   ├── notifications_event.dart      # BLoC events
│               │   └── notifications_state.dart      # BLoC states
│               │
│               ├── pages/
│               │   └── notifications_page.dart       # Notifications list page
│               │
│               └── widgets/
│                   ├── notification_item.dart        # Single notification item
│                   ├── notification_empty_widget.dart # Empty state widget
│                   └── notification_filter_chips.dart # Filter chips for types
│
│       ├── videoplayer/               # Video Player Feature (NEW - Extracted)
│       │   ├── videoplayer.dart                    # Barrel export file
│       │   │
│       │   ├── domain/
│       │   │   └── entities/
│       │   │       └── video_config.dart           # Video player configuration entity
│       │   │
│       │   ├── presentation/
│       │   │   ├── bloc/
│       │   │   │   ├── video_player_bloc.dart      # BLoC for video player state
│       │   │   │   ├── video_player_event.dart     # Events (Initialize, Play, Pause, Seek, etc.)
│       │   │   │   └── video_player_state.dart     # States (Initial, Loading, Ready, Error, Completed)
│       │   │   │
│       │   │   ├── widgets/
│       │   │   │   ├── video_player_widget.dart    # Main reusable video player widget
│       │   │   │   ├── video_player_controls.dart  # Quick action controls (fullscreen, seek)
│       │   │   │   ├── player_type_badge.dart      # Player type indicator badge
│       │   │   │   ├── video_loading_state.dart    # Loading state widget
│       │   │   │   └── video_error_state.dart      # Error state widget
│       │   │   │
│       │   │   └── pages/
│       │   │       └── fullscreen_video_page.dart  # Fullscreen video viewer
│       │   │
│       │   └── di/
│       │       └── videoplayer_injection.dart      # Dependency injection setup
│       │
│       └── content_library/           # Content Library Feature (Uses videoplayer)
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── content_entity.dart
│           │   │   ├── chapter_entity.dart
│           │   │   ├── subject_entity.dart
│           │   │   └── content_progress_entity.dart
│           │   │
│           │   └── repositories/
│           │       └── content_library_repository.dart
│           │
│           ├── data/
│           │   ├── models/
│           │   │   ├── content_model.dart
│           │   │   ├── chapter_model.dart
│           │   │   ├── subject_model.dart
│           │   │   └── content_progress_model.dart
│           │   │
│           │   ├── datasources/
│           │   │   ├── content_library_remote_datasource.dart
│           │   │   └── content_library_local_datasource.dart
│           │   │
│           │   └── repositories/
│           │       └── content_library_repository_impl.dart
│           │
│           └── presentation/
│               ├── bloc/
│               │   ├── subjects/
│               │   │   ├── subjects_bloc.dart
│               │   │   ├── subjects_event.dart
│               │   │   └── subjects_state.dart
│               │   │
│               │   ├── subject_detail/
│               │   │   ├── subject_detail_bloc.dart
│               │   │   ├── subject_detail_event.dart
│               │   │   └── subject_detail_state.dart
│               │   │
│               │   ├── content_viewer/
│               │   │   ├── content_viewer_bloc.dart
│               │   │   ├── content_viewer_event.dart
│               │   │   └── content_viewer_state.dart
│               │   │
│               │   └── bookmark/
│               │       ├── bookmark_bloc.dart
│               │       ├── bookmark_event.dart
│               │       └── bookmark_state.dart
│               │
│               ├── pages/
│               │   ├── subjects_list_page.dart
│               │   ├── subject_detail_page.dart
│               │   ├── content_viewer_page.dart     # Uses VideoPlayerWidget for video content
│               │   └── bookmarks_page.dart
│               │
│               └── widgets/
│                   ├── subject_list_card.dart
│                   ├── chapter_accordion.dart
│                   └── content_list_item.dart
│
├── test/
│   └── widget_test.dart
│
├── assets/
│   ├── images/
│   │   └── .gitkeep
│   ├── lottie/
│   ├── icons/
│   └── fonts/                                  # ✅ NEW (2025-12-15): Fonts for PDF export
│       ├── Cairo-Regular.ttf                  # User must download from Google Fonts
│       ├── Cairo-Bold.ttf                     # User must download from Google Fonts
│       ├── Cairo-SemiBold.ttf                 # Optional
│       └── README.md                          # Installation guide
│
├── docs/
│   ├── project_tree.md (ce fichier)
│   ├── functions.md
│   ├── variables_file.md
│   ├── DESIGN_SYSTEM.md            # NEW: Design system documentation
│   └── MIGRATION_GUIDE.md          # NEW: Migration guide for all pages
│
├── pubspec.yaml
├── analysis_options.yaml
│
├── BUILD_AND_RUN.md
├── DEVELOPMENT_STATUS.md
├── FINAL_SUMMARY.md
├── NEXT_STEPS.md
├── SESSION_2_SUMMARY.md
└── PHASE_2_PROGRESS.md
```

---

## Statistiques

| Catégorie | Nombre de fichiers |
|-----------|-------------------|
| **Core** | 43 (+3 services) |
| **Auth Feature** | 24 |
| **Home Feature** | 29 (+8 promo API files: entity, repo, usecases, model, datasource, bloc) |
| **BAC Feature** | 62 |
| **Planner Feature** | 48 |
| **Profile Feature** | 21 |
| **Notifications Feature** | 15 |
| **VideoPlayer Feature** | 12 (NEW - Extracted from content_library) |
| **Content Library Feature** | 25 (Uses VideoPlayer) |
| **Documentation** | 11 (+2 design docs) |
| **Tests** | 1 |
| **Configuration** | 2 |
| **TOTAL** | 282 |

---

## Fichiers Générés Automatiquement

- `*.g.dart` - Générés par build_runner (json_serializable)
- `*.freezed.dart` - Générés par build_runner (freezed) si utilisé

---

## Notes

- Structure suit Clean Architecture (Domain/Data/Presentation)
- **Design System:** Unified Blue theme (#2196F3) avec 15+ composants réutilisables
- Feature Auth: COMPLET (100%)
- Feature Home: COMPLET (100%) - Refactorisé avec design system
- Feature BAC: Spécification COMPLÈTE dans new_plan/new_bac.md (0% implémenté)
- Feature Planner: COMPLET (100%)
- Feature Profile: Domain + Data COMPLETS, UI Pages créées (70%)
- Feature Notifications: COMPLET (100%) - Firebase FCM, Push notifications, BLoC, UI
- **Feature VideoPlayer: COMPLET (100%) - Extracted as standalone reusable module**
- **Feature Content Library: COMPLET (100%) - Uses VideoPlayerWidget for video content**
- Tous les fichiers compilent sans erreurs
- APK généré avec succès

## Design System Components (NEW)

**Core/Constants:**
- app_colors.dart - Enhanced with Blue gradients and shadows
- app_design_tokens.dart - Complete design tokens (spacing, sizing, animations)

**Core/Utils:**
- gradient_helper.dart - 30+ gradient presets

**Core/Widgets:**
- 9 Card components (gradient_hero_card, stat_card_mini, progress_card, session_card, info_card, bac_archives_card, active_session_timer_card, modern_stat_card, modern_section_card)
- 4 Badge components (stat_badge, time_badge, coefficient_badge, level_badge)
- 3 Layout components (section_header, page_scaffold, grid_layout)
- 2 Input components (app_search_bar, filter_chip_group)
- modern_bottom_nav.dart (updated to Blue theme)

**Documentation:**
- DESIGN_SYSTEM.md - Complete design system guide (400+ lines)
- MIGRATION_GUIDE.md - Migration guide for all 43 pages (500+ lines)
