# Variables File - MEMO App

**Dernière mise à jour:** 17/12/2025 (Course Subscription Feature Completion)

---

## VideoPlayer Feature Variables (NEW)

### VideoConfig (features/videoplayer/domain/entities/video_config.dart)

```dart
// Configuration properties
final String videoUrl                       // URL of video to play
final String preferredPlayer               // Player type ('chewie', 'media_kit', 'simple_youtube', 'omni', 'orax')
final bool showControls                    // Whether to show player controls
final bool autoPlay                        // Whether to auto-play
final Duration? startPosition              // Start position for resume
final int? accentColorValue                // Accent color as int
final bool showPlayerBadge                 // Show player type badge
final int autoSaveIntervalSeconds          // Auto-save interval (0 to disable)

// Static constants
static List<String> youtubeCompatiblePlayers = ['simple_youtube', 'omni', 'orax', 'orax_video_player']
```

### VideoPlayerReady State (features/videoplayer/presentation/bloc/video_player_state.dart)

```dart
final IVideoPlayer player                   // Underlying video player instance
final VideoConfig config                    // Configuration used
final Duration position                     // Current playback position
final Duration duration                     // Total duration
final bool isPlaying                        // Is currently playing
final bool isBuffering                      // Is currently buffering
final bool isFullscreen                     // Is in fullscreen mode
final double playbackSpeed                  // Current playback speed
final String? currentQuality               // Current quality setting
final List<String> availableQualities      // Available quality options
final bool didFallback                      // Whether fallback player was used
final String effectivePlayerType           // Actual player type being used
```

### VideoPlayerBloc Internal State (features/videoplayer/presentation/bloc/video_player_bloc.dart)

```dart
IVideoPlayer? _player                       // Current player instance
StreamSubscription<PlayerPlaybackState>? _stateSubscription
StreamSubscription<Duration>? _positionSubscription
StreamSubscription<Duration>? _durationSubscription
StreamSubscription<bool>? _bufferingSubscription
StreamSubscription<String>? _errorSubscription
VideoConfig? _currentConfig                 // Current video configuration
```

---

## Main App Variables (NEW - Dark Mode)

### MemoApp Widget (main.dart)

```dart
// BlocBuilder wrapping MaterialApp for dynamic theme
BlocBuilder<SettingsCubit, SettingsState>  // Listens to SettingsCubit state changes

// Theme variables (inside BlocBuilder)
final ThemeMode themeMode                  // Dynamic theme mode from settings state
```

**Purpose:** Enables dynamic theme switching across the entire app by listening to SettingsCubit state changes

**Flow:**
1. SettingsCubit emits SettingsLoaded state with themeMode
2. BlocBuilder rebuilds when state changes
3. _convertThemeMode() converts string to enum
4. MaterialApp receives new ThemeMode and applies it instantly

---

## Design System Variables (NEW)

### AppColors (core/constants/app_colors.dart) - Enhanced

```dart
// Enhanced Text Colors (NEW)
static const Color textDark = Color(0xFF0F172A)            // Slate 900
static const Color textMedium = Color(0xFF475569)          // Slate 600

// Enhanced Border Colors (NEW)
static const Color borderLight = Color(0xFFE2E8F0)         // Slate 200
static const Color borderMedium = Color(0xFFCBD5E1)        // Slate 300
static const Color borderDark = Color(0xFF94A3B8)          // Slate 400

// Shadow Colors (NEW)
static const Color shadowPrimary = Color(0x662196F3)       // Primary @ 40%
static const Color shadowPrimaryLight = Color(0x4D2196F3)  // Primary @ 30%
static const Color shadowPrimarySubtle = Color(0x332196F3) // Primary @ 20%
static const Color shadowDark = Color(0x1A000000)          // Black @ 10%
static const Color shadowMedium = Color(0x0D000000)        // Black @ 5%

// Overlay Colors (NEW)
static const Color overlayLight = Color(0x0DFFFFFF)        // White @ 5%
static const Color overlayMedium = Color(0x1AFFFFFF)       // White @ 10%
static const Color overlayDark = Color(0x66000000)         // Black @ 40%

// Accent Colors (NEW)
static const Color fireRed = Color(0xFFEF4444)             // Red 500
static const Color successGreen = Color(0xFF10B981)        // Emerald 500
static const Color warningYellow = Color(0xFFF59E0B)       // Amber 500

// Blue Gradients (NEW)
static const List<Color> primaryGradient = [
  Color(0xFF2196F3),  // Primary Blue
  Color(0xFF1976D2),  // Dark Blue
]

static const List<Color> primaryGradientHero = [
  Color(0xFF64B5F6),  // Light Blue
  Color(0xFF2196F3),  // Primary Blue
  Color(0xFF1976D2),  // Dark Blue
]
```

### AppDesignTokens (core/constants/app_design_tokens.dart) - NEW

```dart
// Container Sizes
static const double heroCardHeight = 200.0
static const double iconContainerXL = 56.0
static const double iconContainerLG = 50.0
static const double iconContainerMD = 44.0
static const double iconContainerSM = 36.0
static const double iconContainerXS = 28.0

// Icon Sizes
static const double iconSizeXL = 32.0
static const double iconSizeLG = 28.0
static const double iconSizeMD = 24.0
static const double iconSizeSM = 20.0
static const double iconSizeXS = 16.0

// Border Radius
static const double borderRadiusHero = 28.0
static const double borderRadiusCard = 20.0
static const double borderRadiusMedium = 18.0
static const double borderRadiusIcon = 14.0
static const double borderRadiusSmall = 12.0
static const double borderRadiusTiny = 10.0
static const double borderRadiusButton = 16.0

// Border Width
static const double borderWidthThin = 1.0
static const double borderWidthMedium = 1.5
static const double borderWidthThick = 2.0

// Progress Bar
static const double progressBarThin = 6.0
static const double progressBarMedium = 8.0
static const double progressBarThick = 10.0

// Spacing
static const double spacingXS = 4.0
static const double spacingSM = 8.0
static const double spacingMD = 12.0
static const double spacingLG = 16.0
static const double spacingXL = 20.0
static const double spacingXXL = 24.0
static const double spacing3XL = 32.0

// Section Spacing
static const double sectionSpacing = 24.0
static const double itemSpacing = 14.0

// Typography
static const double fontSizeDisplay = 48.0
static const double fontSizeHeadline = 28.0
static const double fontSizeHeadlineSmall = 24.0
static const double fontSizeTitle = 20.0
static const double fontSizeTitleSmall = 18.0
static const double fontSizeBody = 16.0
static const double fontSizeBodySmall = 14.0
static const double fontSizeLabel = 12.0
static const double fontSizeLabelSmall = 11.0

// Animation Durations
static const Duration animationFast = Duration(milliseconds: 200)
static const Duration animationNormal = Duration(milliseconds: 300)
static const Duration animationSlow = Duration(milliseconds: 800)

// Animation Curves
static const Curve curveStandard = Curves.easeInOut
static const Curve curveEmphasized = Curves.easeInOutCubic
static const Curve curveDecelerate = Curves.easeOut
```

### Widget Component Props

#### GradientHeroCard (core/widgets/cards/gradient_hero_card.dart)

```dart
final Widget child
final LinearGradient? gradient
final double? height
final EdgeInsetsGeometry? padding
final bool showDecorativeCircles
final BorderRadius? borderRadius
```

#### StatCardMini (core/widgets/cards/stat_card_mini.dart)

```dart
final IconData icon
final Color iconColor
final String value
final String label
final VoidCallback? onTap
final EdgeInsetsGeometry? padding
```

#### ProgressCard (core/widgets/cards/progress_card.dart)

```dart
final IconData icon
final Color iconColor
final String title
final String? subtitle
final double progress              // 0.0 to 1.0
final String? progressLabel
final VoidCallback? onTap
final bool showProgressBar
```

#### SessionCard (core/widgets/cards/session_card.dart)

```dart
final IconData subjectIcon
final LinearGradient subjectGradient
final String subjectName
final String sessionTitle
final String time
final String? duration
final VoidCallback? onTap
final bool isCompleted
```

#### InfoCard (core/widgets/cards/info_card.dart)

```dart
final IconData icon
final Color iconColor
final String title
final String? subtitle
final Widget? trailing
final VoidCallback? onTap
```

#### BacArchivesCard (core/widgets/cards/bac_archives_card.dart)

```dart
final String year
final String title
final String? subtitle
final String? stats
final LinearGradient gradient
final IconData? icon
final VoidCallback? onTap
```

#### StatBadge (core/widgets/badges/stat_badge.dart)

```dart
final IconData icon
final String value
final Color color
final BadgeSize size               // small, medium, large
final String? label
final bool showBackground
```

#### TimeBadge (core/widgets/badges/time_badge.dart)

```dart
final String time
final Color? color
final bool showIcon
final TimeBadgeStyle style         // filled, outlined, text
```

#### SectionHeader (core/widgets/layouts/section_header.dart)

```dart
final String title
final String? subtitle
final IconData? icon
final VoidCallback? onViewAll
final String? viewAllText
```

#### PageScaffold (core/widgets/layouts/page_scaffold.dart)

```dart
final String? title
final Widget body
final bool showAppBar
final bool applyHorizontalPadding
final List<Widget>? actions
final Widget? floatingActionButton
```

#### GridLayout (core/widgets/layouts/grid_layout.dart)

```dart
final int itemCount
final IndexedWidgetBuilder itemBuilder
final int columnCount
final double spacing
final double runSpacing
final EdgeInsetsGeometry? padding
```

#### AppSearchBar (core/widgets/inputs/app_search_bar.dart)

```dart
final String hintText
final ValueChanged<String>? onChanged
final ValueChanged<String>? onSubmitted
final TextEditingController? controller
final bool autofocus
final bool showClearButton
final Widget? suffixIcon
final Widget? prefixIcon
final Color? backgroundColor
final Color? borderColor
```

#### FilterChipGroup (core/widgets/inputs/filter_chip_group.dart)

```dart
final List<String> items
final int selectedIndex
final ValueChanged<int> onSelected
final Color? chipColor
final Color? selectedChipColor
final Axis scrollDirection
final EdgeInsetsGeometry? padding
```

---

## Courses Feature Widget Variables (NEW - 02/12/2025)

### ModernCourseListCard (features/courses/presentation/widgets/modern_course_list_card.dart)

```dart
// Properties
final CourseEntity course              // Course data to display
final VoidCallback onTap               // Tap callback
final bool showProgress                // Show progress bar (default: false)
final double? progress                 // Progress value 0.0-1.0

// Subject Colors Mapping
static const Map<String, Color> _subjectColors = {
  'رياضيات': Color(0xFF8B5CF6),       // Purple
  'فيزياء': Color(0xFFEC4899),        // Pink
  'كيمياء': Color(0xFF06B6D4),        // Cyan
  'علوم': Color(0xFF10B981),          // Emerald
  'عربية': Color(0xFFEF4444),         // Red
  'فرنسية': Color(0xFF6366F1),        // Indigo
  'إنجليزية': Color(0xFF14B8A6),      // Teal
  'تاريخ': Color(0xFFA855F7),         // Purple
  'جغرافيا': Color(0xFF0EA5E9),       // Sky
  'فلسفة': Color(0xFFEAB308),         // Yellow
  'إسلامية': Color(0xFF22C55E),       // Green
}

// Subject Gradient Colors Mapping
static const Map<String, List<Color>> _subjectGradients = {
  'رياضيات': [Color(0xFF667EEA), Color(0xFF764BA2)],
  'فيزياء': [Color(0xFFF093FB), Color(0xFFF5576C)],
  'كيمياء': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  'علوم': [Color(0xFF43E97B), Color(0xFF38F9D7)],
  'عربية': [Color(0xFFFA709A), Color(0xFFFEE140)],
  // ... more mappings
}

// Subject Icons Mapping
static const Map<String, IconData> _subjectIcons = {
  'رياضيات': Icons.calculate_rounded,
  'فيزياء': Icons.science_rounded,
  'كيمياء': Icons.biotech_rounded,
  'علوم': Icons.eco_rounded,
  'عربية': Icons.menu_book_rounded,
  'فرنسية': Icons.language_rounded,
  'إنجليزية': Icons.translate_rounded,
  'تاريخ': Icons.history_edu_rounded,
  'جغرافيا': Icons.public_rounded,
  'فلسفة': Icons.psychology_rounded,
  'إسلامية': Icons.mosque_rounded,
}
```

### PaymentOptionsBottomSheet (features/courses/presentation/widgets/payment_options_bottom_sheet.dart) - NEW (2025-12-17)

```dart
// Constructor Properties
final int courseId                      // ID of the course to subscribe to
final VoidCallback? onCodeRedeemed      // Callback when subscription code is successfully redeemed

// Static constants
// Payment method types: 'code', 'baridimob', 'ccp'
```

### SubscriptionCodeDialog (features/courses/presentation/widgets/subscription_code_dialog.dart) - UPDATED (2025-12-17)

```dart
// Constructor Properties (UPDATED)
final SubscriptionBloc subscriptionBloc  // BLoC for subscription operations
final int? courseId                      // NEW: Optional course ID for context-specific subscription
final VoidCallback? onSuccess            // NEW: Callback executed after successful code redemption

// State Variables
TextEditingController _codeController             // Code input controller
GlobalKey<ModernCodeInputState> _codeInputKey    // Key for code input widget
bool _isValidating                                // True during code validation
bool _isRedeeming                                 // True during code redemption
SubscriptionCodeValidationResult? _validatedCodeData  // Validated code information

// Animation Controllers
AnimationController _backgroundController         // Animated gradient background
AnimationController _successController            // Success animation controller
AnimationController _slideController              // Slide-in animation controller
Animation<double> _successScale                   // Scale animation for success state
Animation<double> _successOpacity                 // Opacity animation for success state
Animation<Offset> _slideAnimation                 // Slide animation for dialog entry
```

### CourseDetailPage State Variables (UPDATED - 2025-12-17)

```dart
// Existing state variables (no changes to data structure)
late TabController _tabController
CourseEntity? _course
List<CourseModuleEntity>? _modules
List<CourseReviewEntity>? _reviews
bool _hasAccess                         // Used to determine button state (Access vs Subscribe)
String? _errorMessage
bool _isLoading
int _expandedModuleIndex

// Note: CourseDetailPage now uses _hasAccess to show either:
// - "الوصول إلى المحتوى" (Access Content) button for subscribed users
// - "اشترك الآن" (Subscribe Now) button for non-subscribed users
```

---

## Home Feature Variables (Updated)

### Navigation State (NEW)

#### MainScreen (features/home/presentation/pages/main_screen.dart)

```dart
int _selectedNavIndex = 0            // Bottom nav: 0=الرئيسية, 1=دوراتي, 2=بلانر, 3=حسابي
int _selectedCategoryIndex = 0      // Category chips: 0=الرئيسية, 1=بلانر, 2=ملخصات, 3=بكالوريات, 4=كويز, 5=دوراتنا
PageController _pageController      // For category swipe navigation
```

#### Feature Flags (core/constants/app_design_tokens.dart)

```dart
static const bool enableCourseFAB = false  // Enable/disable FAB for courses (default: false)
```

#### BottomNavItem (core/widgets/modern_bottom_nav.dart)

```dart
// Navigation item data model with individual colors
final IconData icon                  // Inactive icon
final IconData activeIcon            // Active icon when selected
final String label                   // Navigation label (Arabic)
final List<Color> gradientColors     // Individual gradient colors for item
```

#### ModernBottomNavigationBar State

```dart
AnimationController _animationController  // For icon animations

// Static navigation items with colors
static const List<BottomNavItem> _navItems = [
  {label: 'الرئيسية', colors: [#3B82F6, #1D4ED8]},   // Blue
  {label: 'دوراتي', colors: [#10B981, #059669]},     // Green
  {label: 'اشتراكاتي', colors: [#8B5CF6, #6D28D9]},  // Purple
  {label: 'بلانر', colors: [#F59E0B, #D97706]},      // Orange
  {label: 'حسابي', colors: [#EF4444, #DC2626]},      // Red
]
```

#### CategoryItem (core/widgets/category_chips.dart)

```dart
// Category model with individual colors
String name                          // Category display name (Arabic)
IconData? icon                       // Optional icon
Color? activeColor                   // Optional active color
List<Color>? gradientColors          // Optional gradient colors for chip
```

#### AppCategories (core/widgets/category_chips.dart)

```dart
// Default categories with individual gradient colors
static const List<CategoryItem> categories = [
  {name: 'الرئيسية', colors: [#3B82F6, #1D4ED8]},     // Blue
  {name: 'بلانر', colors: [#8B5CF6, #6D28D9]},        // Purple
  {name: 'ملخصات و دروس', colors: [#10B981, #059669]}, // Green
  {name: 'بكالوريات', colors: [#F59E0B, #D97706]},    // Orange
  {name: 'كويز', colors: [#EF4444, #DC2626]},         // Red
  {name: 'دوراتنا', colors: [#06B6D4, #0891B2]},      // Cyan
]
```

#### CategoryChips State

```dart
// Widget state
ScrollController _scrollController   // For horizontal scroll
AnimationController _animationController // For chip animations
List<GlobalKey> _chipKeys            // For chip position calculation

// Configuration options
bool showIcons                       // Toggle icon visibility (default: true)
bool useGlassmorphism                // Toggle glassmorphism effect (default: true)
```

### BLoC States (NEW)

#### HomeState (features/home/presentation/bloc/home_state.dart)

**HomeInitial** - No variables

**HomeLoading** - No variables

**HomeLoaded**
```dart
final DashboardData data
```

**HomeError**
```dart
final String message
```

### BLoC Events (NEW)

#### LoadDashboard - No variables

#### RefreshDashboard - No variables

#### MarkSessionCompleted
```dart
final int sessionId
```

### Enums (NEW)

#### BadgeSize (core/widgets/badges/stat_badge.dart)

```dart
enum BadgeSize {
  small,    // 36px
  medium,   // 48px
  large,    // 56px
}
```

#### TimeBadgeStyle (core/widgets/badges/time_badge.dart)

```dart
enum TimeBadgeStyle {
  filled,    // Solid background
  outlined,  // Border only
  text,      // Text only
}
```

#### CoefficientBadgeStyle (core/widgets/badges/coefficient_badge.dart)

```dart
enum CoefficientBadgeStyle {
  filled,    // Solid background
  outlined,  // Border only
}
```

#### LevelBadgeStyle (core/widgets/badges/level_badge.dart)

```dart
enum LevelBadgeStyle {
  gradient,  // With gradient
  solid,     // Solid color
}
```

### Home Redesign Widgets (NEW - 07/12/2025)

#### UserHeroCard (features/home/presentation/widgets/user_hero_card.dart)

```dart
final String firstName              // User's first name
final String? avatarUrl             // User's avatar URL (optional)
final String? streamName            // Academic stream name (e.g., "علوم تجريبية")
final String? yearName              // Academic year name (e.g., "السنة الثالثة ثانوي")
final int level                     // Current user level
final int totalPoints               // Total XP points
final int pointsToNextLevel         // Points needed to reach next level
final int streak                    // Consecutive days streak
final String studyTimeFormatted     // Study time today formatted (e.g., "2س 30د")
final int? rank                     // User's rank in leaderboard (optional)
final VoidCallback? onTap           // Callback when card is tapped
final VoidCallback? onAvatarTap     // Callback when profile avatar is tapped
```

#### QuickActionsGrid (features/home/presentation/widgets/quick_actions_grid.dart)

```dart
final VoidCallback? onContinueStudy    // Navigate to content library
final VoidCallback? onQuickQuiz        // Navigate to quiz
final VoidCallback? onTodaySchedule    // Navigate to planner
final VoidCallback? onBacSimulation    // Navigate to BAC simulation
final String? lastSubject              // Last studied subject for "continue" button
final int? pendingQuizCount            // Number of pending quizzes
final int? todaySessionsCount          // Number of today's sessions
```

#### WeeklyProgressWidget (features/home/presentation/widgets/weekly_progress_widget.dart)

```dart
final List<DayProgress> weeklyData     // 7 days of progress data
final VoidCallback? onViewDetails      // View full analytics
```

#### DayProgress (Entity for WeeklyProgressWidget)

```dart
final String dayName                   // Day name (e.g., "السبت")
final DateTime date                    // Full date
final int studyMinutes                 // Minutes studied
final bool isToday                     // Whether this is today
```

#### LeaderboardPreviewWidget (features/home/presentation/widgets/leaderboard_preview_widget.dart)

```dart
final List<LeaderboardEntry> topThree  // Top 3 entries from the leaderboard
final CurrentUserRank? currentUserRank // Current user's rank info
final String? streamName               // Stream name to display (e.g., "علوم تجريبية")
final VoidCallback? onViewAll          // Callback when "View All" is tapped
```

#### PromoSliderWidget (features/home/presentation/widgets/promo_slider_widget.dart)

```dart
final List<PromoItem> items            // List of promotional items to display
final double height                    // Slider height (default: 160)
final Duration autoPlayDuration        // Auto-play interval (default: 5 seconds)
final VoidCallback? onItemTap          // Callback when any item is tapped
// State
int _currentPage                       // Current page index
PageController _pageController         // Page controller for sliding
Timer? _autoPlayTimer                  // Timer for auto-advance
```

#### PromoItem (Model - Updated)

```dart
final int? id                          // Promo ID from API (for analytics)
final String title                     // Main title text
final String? subtitle                 // Subtitle/description text
final String? badge                    // Badge text (e.g., "جديد", "تحدي")
final String? actionText               // Action button text
final IconData? icon                   // Icon to display
final String? imageUrl                 // Image URL (optional)
final List<Color>? gradientColors      // Gradient colors for background
final LinearGradient? gradient         // Custom gradient (overrides gradientColors)
final String? actionType               // 'route', 'url', or 'none'
final String? actionValue              // Route path or URL to navigate
final VoidCallback? onTap              // Tap callback for this item
```

### Promo Feature - Domain (NEW)

#### PromoEntity (features/home/domain/entities/promo_entity.dart)

```dart
final int id                           // Unique promo ID
final String title                     // Title text (Arabic)
final String? subtitle                 // Subtitle/description
final String? badge                    // Badge text (e.g., "جديد")
final String? actionText               // CTA button text
final String? iconName                 // Icon name string for mapping
final String? imageUrl                 // Image URL
final List<String>? gradientColors     // Hex color strings from API
final String? actionType               // Navigation type
final String? actionValue              // Navigation destination
final int order                        // Display order
final bool isActive                    // Whether promo is active
```

#### PromosResponse (features/home/domain/entities/promo_entity.dart)

```dart
final List<PromoEntity> promos         // List of promo entities
final bool sectionEnabled              // Whether to show slider section
```

### Promo Feature - BLoC States (NEW)

#### PromoState (features/home/presentation/bloc/promo/promo_state.dart)

```dart
// PromoLoaded
final List<PromoEntity> promos         // Loaded promos from API
final bool sectionEnabled              // Section visibility flag

// PromoError
final String message                   // Error message (Arabic)
final List<PromoEntity>? cachedPromos  // Cached promos for fallback
bool get hasCachedData                 // Whether cached data is available
```

---

## Auth Feature Variables

```dart
final int id
final String email
final String firstName
final String lastName
final String? phone
final String? avatar
final AcademicProfileEntity? academicProfile
final DateTime createdAt
```

#### AcademicProfileEntity

```dart
final int? phaseId
final int? yearId
final int? streamId
final String? phaseName
final String? yearName
final String? streamName
```

### BLoC States

#### AuthState (features/auth/presentation/bloc/auth_state.dart)

**AuthInitial** - Aucune variable

**AuthLoading** - Aucune variable

**Authenticated**
```dart
final UserEntity user
```

**Unauthenticated** - Aucune variable

**AuthError**
```dart
final String message
final String? errorType
```

### BLoC Events

#### AuthCheckRequested - Aucune variable

#### LoginRequested
```dart
final String email
final String password
final bool rememberMe
```

#### RegisterRequested
```dart
final String email
final String password
final String firstName
final String lastName
final String? phone
```

#### LogoutRequested
```dart
final bool logoutFromAllDevices
```

#### AcademicProfileUpdateRequested
```dart
final int phaseId
final int yearId
final int? streamId
```

### Models

#### UserModel (features/auth/data/models/user_model.dart)

```dart
final int id
final String email
final String firstName
final String lastName
final String? phone
final String? avatar
final AcademicProfileModel? academicProfile
final String createdAt
```

#### LoginResponseModel

```dart
final String token
final String tokenType
final UserModel user
```

### Pages State Variables

#### LoginPage
```dart
final TextEditingController _emailController
final TextEditingController _passwordController
final GlobalKey<FormState> _formKey
bool _rememberMe
bool _obscurePassword
```

#### RegisterPage
```dart
final TextEditingController _firstNameController
final TextEditingController _lastNameController
final TextEditingController _emailController
final TextEditingController _phoneController
final TextEditingController _passwordController
final TextEditingController _confirmPasswordController
final GlobalKey<FormState> _formKey
bool _obscurePassword
bool _obscureConfirmPassword
```

#### SplashPage
```dart
late AnimationController _animationController
late Animation<double> _scaleAnimation
late Animation<double> _opacityAnimation
```

#### OnboardingPage
```dart
final PageController _pageController
int _currentPage
```

#### AcademicSelectionPage
```dart
final PageController _pageController
int _currentStep
int? _selectedPhaseId
int? _selectedYearId
int? _selectedStreamId
```

---

## Home Feature Variables

### Entities (Updated)

#### StatsEntity (features/home/domain/entities/stats_entity.dart)

```dart
final int streak
final int totalPoints
final int level
final int pointsToNextLevel
final int studyTimeToday
final int dailyGoal

// Computed properties (NEW)
double get levelProgress               // Progress to next level (0.0-1.0)
double get dailyGoalProgress          // Daily goal completion (0.0-1.0)
String get formattedStudyTime         // "2h 30m" format
```

#### StudySessionEntity (features/home/domain/entities/study_session_entity.dart)

```dart
final int id
final int subjectId
final String subjectName
final String subjectColor
final SessionType type
final SessionStatus status
final DateTime startTime
final DateTime endTime
final String? topic
final String? notes
```

#### SubjectProgressEntity (features/home/domain/entities/subject_progress_entity.dart)

```dart
final int id
final String name
final String nameAr
final String color
final double coefficient
final int totalLessons
final int completedLessons
final int totalQuizzes
final int completedQuizzes
final double averageScore
final DateTime? nextExamDate
final String? iconEmoji
```

### Models

#### StatsModel (features/home/data/models/stats_model.dart)

```dart
final int streak
@JsonKey(name: 'total_points') final int totalPoints
final int level
@JsonKey(name: 'points_to_next_level') final int pointsToNextLevel
@JsonKey(name: 'study_time_today') final int studyTimeToday
@JsonKey(name: 'daily_goal') final int dailyGoal
```

#### StudySessionModel

```dart
final int id
@JsonKey(name: 'subject_id') final int subjectId
@JsonKey(name: 'subject_name') final String subjectName
@JsonKey(name: 'subject_color') final String subjectColor
final String type
final String status
@JsonKey(name: 'start_time') final String startTime
@JsonKey(name: 'end_time') final String endTime
final String? topic
final String? notes
```

#### SubjectProgressModel

```dart
final int id
final String name
@JsonKey(name: 'name_ar') final String nameAr
final String color
final double coefficient
@JsonKey(name: 'total_lessons') final int totalLessons
@JsonKey(name: 'completed_lessons') final int completedLessons
@JsonKey(name: 'total_quizzes') final int totalQuizzes
@JsonKey(name: 'completed_quizzes') final int completedQuizzes
@JsonKey(name: 'average_score') final double averageScore
@JsonKey(name: 'next_exam_date') final String? nextExamDate
@JsonKey(name: 'icon_emoji') final String? iconEmoji
```

### Use Cases

#### DashboardData (features/home/domain/usecases/get_dashboard_data_usecase.dart)

```dart
final StatsEntity stats
final List<StudySessionEntity> todaySessions
final List<SubjectProgressEntity> subjectsProgress
```

---

## Core Constants

### AppColors (core/constants/app_colors.dart)

```dart
// Theme Colors
static const Color primary
static const Color primaryDark
static const Color primaryLight
static const Color secondary
static const Color accent

// Semantic Colors
static const Color success
static const Color warning
static const Color error
static const Color info

// Background Colors
static const Color background
static const Color surface
static const Color textOnPrimary

// Text Colors
static const Color textPrimary
static const Color textSecondary
static const Color textTertiary

// Subject Colors
static const Color mathematics
static const Color physics
static const Color chemistry
static const Color arabic
static const Color french
static const Color english
static const Color history
static const Color geography
static const Color philosophy
static const Color islamic

// UI Colors
static const Color divider
static const Color shadow
static const Color overlay
static const Color border
```

### AppSizes (core/constants/app_sizes.dart)

```dart
// Padding
static const double paddingXS
static const double paddingSM
static const double paddingMD
static const double paddingLG
static const double paddingXL

// Border Radius
static const double radiusSM
static const double radiusMD
static const double radiusLG
static const double radiusXL

// Icon Sizes
static const double iconSM
static const double iconMD
static const double iconLG
static const double iconXL

// Elevation
static const double elevationSM
static const double elevationMD
static const double elevationLG
```

### ApiConstants (core/constants/api_constants.dart)

```dart
static const String baseUrl
static const String login
static const String register
static const String logout
static const String validateToken
static const String updateAcademicProfile
static const String dashboardStats
static const String todaySessions
static const String subjectsProgress
static const String sessions
static const String updateStudyTime
// ... (40+ endpoints)
```

---

## Enums

### SessionType (features/home/domain/entities/study_session_entity.dart)

```dart
enum SessionType {
  lesson,    // درس
  review,    // مراجعة
  quiz,      // اختبار
  homework,  // واجب
}
```

### SessionStatus

```dart
enum SessionStatus {
  pending,     // قادم
  inProgress,  // جاري
  completed,   // مكتمل
  missed,      // فائت
}
```

---

## Dependency Injection

### GetIt Instance (injection_container.dart)

```dart
final sl = GetIt.instance
```

**Services Enregistrés:**
- AuthBloc
- LoginUseCase
- RegisterUseCase
- ValidateTokenUseCase
- LogoutUseCase
- AuthRepository
- AuthRemoteDataSource
- AuthLocalDataSource
- DioClient
- SecureStorageService
- HiveService
- Connectivity

---

## Navigation

### AppRouter (app_router.dart)

```dart
final AuthBloc authBloc
late final GoRouter router
```

**Routes:**
- /splash
- /onboarding
- /auth/login
- /auth/register
- /auth/academic-selection
- /home

---

## Planner Feature Variables

### Entities

#### SelectableSubject (features/planner/domain/entities/selectable_subject.dart)

```dart
final Subject subject
bool isSelected
int difficultyLevel          // 1-5 stars
Priority priority            // low, medium, high, critical
int progressPercentage       // 0-100
```

#### Priority Enum

```dart
enum Priority {
  low,       // منخفضة
  medium,    // متوسطة
  high,      // عالية
  critical   // حرجة
}
```

#### PlannerSubject (features/planner/domain/entities/planner_subject.dart)

```dart
final int id
final int userId
final int subjectId
final Subject subject
final int difficultyLevel
final Priority priority
final int progressPercentage
final DateTime createdAt
final DateTime updatedAt
```

#### PlannerSubjectCreate (features/planner/domain/entities/planner_subject_create.dart)

```dart
final int subjectId
final int difficultyLevel
final String priority        // 'low', 'medium', 'high', 'critical'
final int progressPercentage
```

#### PlannerSession (features/planner/domain/entities/planner_session.dart)

```dart
final int id
final int userId
final int subjectId
final Subject subject
final DateTime scheduledStart
final DateTime scheduledEnd
final int durationMinutes
final SessionType type       // study, revision, practice
final SessionStatus status   // scheduled, in_progress, completed, missed, skipped
final String? notes
final int? completionPercentage
final int? concentrationScore
final int? difficultyRating
final String? mood
final DateTime? actualStart
final DateTime? actualEnd
final int? pointsEarned
```

#### SessionType Enum

```dart
enum SessionType {
  study,      // دراسة
  revision,   // مراجعة
  practice    // تطبيق
}
```

#### SessionStatus Enum

```dart
enum SessionStatus {
  scheduled,    // مجدول
  in_progress,  // جاري
  completed,    // مكتمل
  missed,       // فائت
  skipped       // متخطى
}
```

#### Exam (features/planner/domain/entities/exam.dart)

```dart
final int id
final int userId
final int subjectId
final Subject subject
final String title
final ExamType type          // quiz, test, exam, final
final DateTime examDate
final int? chapterId
final String? notes
final int? score
final DateTime createdAt
```

#### ExamType Enum

```dart
enum ExamType {
  quiz,      // اختبار قصير
  test,      // فرض
  exam,      // امتحان
  final_bac  // باكالوريا
}
```

#### ScheduleGenerationParams (features/planner/domain/entities/schedule_generation_params.dart)

```dart
final DateTime startDate
final DateTime endDate
final int hoursPerDay
final List<String> preferredTimes    // ['morning', 'afternoon', 'evening', 'night']
final List<String> energyLevels      // 'high' for morning, 'low' for night
final String sleepStart              // '23:00'
final String sleepEnd                // '06:00'
final List<String> exerciseTimes     // ['16:00-17:00']
final bool includePrayerTimes
final String? city                   // For prayer times
final int pomodoroWorkMinutes        // Default 25
final int pomodoroShortBreak         // Default 5
final int pomodoroLongBreak          // Default 15
```

### BLoC States

#### SubjectSelectionState (features/planner/presentation/bloc/subject_selection/subject_selection_state.dart)

**SubjectSelectionInitial** - No variables

**SubjectSelectionLoading** - No variables

**SubjectSelectionLoaded**
```dart
final List<SelectableSubject> streamSubjects    // User's branch subjects
final List<SelectableSubject> commonSubjects     // Common subjects
final int selectedCount
```

**SubjectSelectionSaving** - No variables

**SubjectSelectionSaved**
```dart
final List<PlannerSubject> savedSubjects
```

**SubjectSelectionError**
```dart
final String message
```

#### PlannerState (features/planner/presentation/bloc/planner/planner_state.dart)

**PlannerInitial** - No variables

**PlannerSubjectsEmpty** - No variables

**PlannerSubjectsLoaded**
```dart
final List<PlannerSubject> subjects
```

**PlannerLoading** - No variables

**PlannerTodayLoaded**
```dart
final List<PlannerSession> sessions
final DateTime date
```

**PlannerScheduleGenerated**
```dart
final ScheduleResponse schedule
final int totalSessions
final Map<String, int> sessionsBySubject
```

**PlannerError**
```dart
final String message
```

#### SessionTimerState (features/planner/presentation/bloc/session_timer/session_timer_state.dart)

**SessionTimerInitial** - No variables

**SessionTimerRunning**
```dart
final Duration remainingTime
final Duration totalTime
final bool isWorkSession      // true for work, false for break
final bool isPaused
final int pomodoroCount       // Number of completed pomodoros
```

**SessionTimerPaused**
```dart
final Duration remainingTime
final Duration totalTime
final bool isWorkSession
final int pomodoroCount
```

**SessionTimerCompleted**
```dart
final int totalPomodoros
final Duration totalWorkTime
final int pointsEarned
```

#### ExamState (features/planner/presentation/bloc/exam/exam_state.dart)

**ExamInitial** - No variables

**ExamLoading** - No variables

**ExamLoaded**
```dart
final List<Exam> exams
final List<Exam> upcomingExams       // Filtered by date
final Map<int, int> daysUntilExam    // exam.id -> days
```

**ExamCreated**
```dart
final Exam exam
```

**ExamError**
```dart
final String message
```

### Widget State Variables

#### SelectableSubjectCard (features/planner/presentation/widgets/selectable_subject_card.dart)

```dart
final SelectableSubject selectableSubject
final VoidCallback onToggle
final ValueChanged<Priority> onPriorityChanged
final ValueChanged<int> onDifficultyChanged
```

#### PomodoroTimer (features/planner/presentation/widgets/pomodoro_timer.dart)

```dart
final Duration duration
final bool isRunning
final VoidCallback onComplete
final VoidCallback? onPause
final VoidCallback? onResume
```

#### SessionTimelineItem (features/planner/presentation/widgets/session_timeline_item.dart)

```dart
final PlannerSession session
final VoidCallback onStart
final VoidCallback onComplete
final VoidCallback onReschedule
final VoidCallback onSkip
```

#### WeekCalendar (features/planner/presentation/widgets/week_calendar.dart)

```dart
final DateTime selectedDate
final List<PlannerSession> sessions
final ValueChanged<DateTime> onDateSelected
```

### Cache Keys

```dart
// Subjects cache
static const String ACADEMIC_SUBJECTS_CACHE_KEY = 'subjects_year_{yearId}_stream_{streamId}';
static const int SUBJECTS_CACHE_TTL = 24; // hours

// Planner subjects cache
static const String USER_PLANNER_SUBJECTS_CACHE_KEY = 'planner_subjects_user_{userId}';

// Sessions cache
static const String TODAY_SESSIONS_CACHE_KEY = 'today_sessions_{date}';
static const int SESSIONS_CACHE_TTL = 6; // hours

// Prayer times cache
static const String PRAYER_TIMES_CACHE_KEY = 'prayer_times_{city}_{date}';
static const int PRAYER_TIMES_CACHE_TTL = 24; // hours
```

### API Response Models

#### BatchCreateResponse

```dart
final bool success
final String message
final int createdCount
final List<PlannerSubject> subjects
```

#### ScheduleResponse

```dart
final bool success
final String message
final int totalSessions
final List<PlannerSession> sessions
final Map<String, dynamic> algorithm_stats
final DateTime generatedAt
```

### Constants

```dart
// Priority weights for algorithm
const Map<Priority, double> PRIORITY_WEIGHTS = {
  Priority.low: 1.0,
  Priority.medium: 1.5,
  Priority.high: 2.0,
  Priority.critical: 2.5,
};

// Difficulty multipliers
const Map<int, double> DIFFICULTY_MULTIPLIERS = {
  1: 0.8,  // Easy
  2: 1.0,  // Medium-easy
  3: 1.2,  // Medium
  4: 1.5,  // Hard
  5: 2.0,  // Very hard
};

// Points calculation
const int BASE_POINTS_PER_SESSION = 10;
const int BONUS_FULL_COMPLETION = 5;
const int BONUS_NO_PAUSE = 5;
const int BONUS_ON_TIME = 3;
const int BONUS_POSITIVE_MOOD = 2;
const int MAX_POINTS_PER_SESSION = 25;

// Session duration limits
const int MIN_SESSION_DURATION = 15;  // minutes
const int MAX_SESSION_DURATION = 120; // minutes

// Pomodoro defaults
const int DEFAULT_POMODORO_WORK = 25;      // minutes
const int DEFAULT_POMODORO_SHORT_BREAK = 5;
const int DEFAULT_POMODORO_LONG_BREAK = 15;
const int POMODOROS_UNTIL_LONG_BREAK = 4;

// Schedule generation limits
const int MIN_SUBJECTS_FOR_SCHEDULE = 1;
const int MAX_SCHEDULE_DAYS = 30;
const int MAX_SESSIONS_PER_DAY = 8;

// Grace period for starting session
const int SESSION_START_GRACE_MINUTES = 15;

// Maximum reschedules per session
const int MAX_RESCHEDULES_PER_SESSION = 3;

// Pause timeout
const int PAUSE_TIMEOUT_MINUTES = 30;
```

### PlannerDesignConstants (NEW - 30/11/2025)

```dart
// Background colors (features/planner/presentation/widgets/shared/planner_design_constants.dart)
static const Color slateBackground = Color(0xFFF8FAFC)
static const Color cardBackground = Color(0xFFFFFFFF)

// Card styling
static const double cardRadius = 20.0

// Subject colors (matching session_detail_screen.dart design)
static const Map<String, Color> subjectColors = {
  'رياضيات': Color(0xFF3B82F6),      // Blue
  'فيزياء': Color(0xFF8B5CF6),       // Purple
  'علوم': Color(0xFF10B981),         // Green
  'كيمياء': Color(0xFFF59E0B),       // Amber
  'أحياء': Color(0xFF22C55E),        // Green
  'عربية': Color(0xFFEC4899),        // Pink
  'فرنسية': Color(0xFF6366F1),       // Indigo
  'إنجليزية': Color(0xFF14B8A6),     // Teal
  'تاريخ': Color(0xFFA855F7),        // Purple
  'جغرافيا': Color(0xFF0EA5E9),      // Sky
  'فلسفة': Color(0xFFEF4444),        // Red
  'إسلامية': Color(0xFF10B981),      // Emerald
  'default': Color(0xFF6366F1),      // Default indigo
}

// Status colors
static const Map<SessionStatus, Color> statusColors = {
  SessionStatus.scheduled: Color(0xFF3B82F6),   // Blue
  SessionStatus.inProgress: Color(0xFF10B981),  // Green
  SessionStatus.paused: Color(0xFFF59E0B),      // Amber
  SessionStatus.completed: Color(0xFF22C55E),   // Green
  SessionStatus.skipped: Color(0xFF6B7280),     // Gray
}

// Priority colors
static const Map<int, Color> priorityColors = {
  1: Color(0xFF6B7280),   // Low - Gray
  2: Color(0xFF3B82F6),   // Medium - Blue
  3: Color(0xFFF59E0B),   // High - Amber
  4: Color(0xFFEF4444),   // Critical - Red
}
```

### Routes

```dart
// Planner routes
- /planner                      // Main planner page (today view)
- /planner/subject-selection    // Subject selection (first-time)
- /planner/schedule-generation  // Schedule generation wizard
- /planner/subjects             // Subjects management
- /planner/session/:id          // Session detail
- /planner/session/:id/execute  // Session execution (Pomodoro)
- /planner/settings             // Planner settings
- /planner/exams                // Exam calendar
```

### New Variables (24/11/2025)

#### _SubjectFormDialogState (features/planner/presentation/pages/subjects_page.dart)

```dart
// Form controllers
late TextEditingController _nameArController
late TextEditingController _nameEnController
late TextEditingController _coefficientController
late TextEditingController _difficultyController

// Form state
String _selectedIcon = 'book'
Color _selectedColor = const Color(0xFF2196F3)

// Available options
final List<Map<String, dynamic>> _availableIcons = [
  {'name': 'book', 'icon': Icons.menu_book_rounded, 'label': 'كتاب'},
  {'name': 'calculate', 'icon': Icons.calculate_rounded, 'label': 'حاسبة'},
  {'name': 'science', 'icon': Icons.science_rounded, 'label': 'علوم'},
  {'name': 'mosque', 'icon': Icons.mosque_rounded, 'label': 'مسجد'},
  {'name': 'language', 'icon': Icons.language_rounded, 'label': 'لغة'},
  {'name': 'public', 'icon': Icons.public_rounded, 'label': 'عالم'},
  {'name': 'psychology', 'icon': Icons.psychology_rounded, 'label': 'فلسفة'},
]

final List<Color> _availableColors = [
  const Color(0xFF2196F3), // Blue
  const Color(0xFF4CAF50), // Green
  const Color(0xFFF44336), // Red
  const Color(0xFFFF9800), // Orange
  const Color(0xFF9C27B0), // Purple
  const Color(0xFFE91E63), // Pink
  const Color(0xFF00BCD4), // Cyan
  const Color(0xFFFF5722), // Deep Orange
  const Color(0xFF795548), // Brown
  const Color(0xFF607D8B), // Blue Grey
]
```

#### PlannerBloc New Fields (features/planner/presentation/bloc/planner_bloc.dart)

```dart
final PauseSession pauseSessionUseCase
final ResumeSession resumeSessionUseCase
final GetWeekSessions getWeekSessionsUseCase
```

#### New PlannerState - WeekScheduleLoaded

```dart
final List<StudySession> sessions
final DateTime weekStart
final String? message
```

---

## PDF Font Loader (core/utils/pdf_font_loader.dart) ✅ NEW (2025-12-15)

### PdfFontLoader Static Variables
```dart
// Font instances (nullable)
static pw.Font? _regularFont                    // Cairo Regular font instance
static pw.Font? _boldFont                       // Cairo Bold font instance
static pw.Font? _semiBoldFont                   // Cairo SemiBold font instance

// Initialization state
static bool _isInitialized                      // Whether fonts have been loaded

// Public getters
pw.Font? regularFont                            // Get regular font (null if not loaded)
pw.Font? boldFont                               // Get bold font (null if not loaded)
pw.Font? semiBoldFont                           // Get semi-bold font (null if not loaded)
bool isReady                                    // Whether fonts are ready (regularFont != null)
```

**Font Loading Behavior:**
- Fonts load asynchronously from `assets/fonts/*.ttf`
- If files missing: `loadFonts()` returns `false`, fonts remain `null`
- Console warning printed if fonts not found
- `getArabicTheme()` returns default theme if fonts missing (Arabic → boxes ████)

**Font File Paths:**
```dart
'assets/fonts/Cairo-Regular.ttf'
'assets/fonts/Cairo-Bold.ttf'
'assets/fonts/Cairo-SemiBold.ttf'  // Optional, falls back to Bold
```

---

## Notes

- Toutes les entities utilisent `final` (immutabilité)
- Models utilisent `@JsonKey` pour mapping API
- Controllers Flutter sont `late` et nécessitent dispose()
- States BLoC sont immutables (Equatable)
- Enums pour type safety (SessionType, SessionStatus, Priority, ExamType)
- SelectableSubject utilise `bool` mutable pour isSelected (state UI temporaire)
- Form dialogs preservent contexte BLoC via parameter blocContext
