# Functions - MEMO App

**Dernière mise à jour:** 17/12/2025 (Course Subscription Feature Completion)

---

## Main App Functions (NEW - Dark Mode)

### _convertThemeMode (main.dart)

```dart
ThemeMode _convertThemeMode(String themeModeString)  // Convert theme string to ThemeMode enum
```

**Purpose:** Converts theme mode string from settings ('light', 'dark', 'system') to Flutter's ThemeMode enum

**Parameters:**
- `themeModeString` - Theme mode as string ('light', 'dark', 'system')

**Returns:** ThemeMode enum value (ThemeMode.light, ThemeMode.dark, ThemeMode.system)

**Usage:** Called by BlocBuilder when SettingsCubit state changes to apply new theme to MaterialApp

---

## Design System Functions (NEW)

### GradientHelper (core/utils/gradient_helper.dart)

```dart
// Primary gradients
static LinearGradient get primary                    // 2-color Blue gradient
static LinearGradient get primaryHero                // 3-color hero gradient
static LinearGradient get primaryVertical            // Vertical variant
static LinearGradient get primaryHorizontal          // Horizontal variant
static LinearGradient get primaryDiagonal            // Diagonal variant
static LinearGradient get primaryReverse             // Reversed colors

// Subject gradients
static LinearGradient get math                       // Mathematics gradient
static LinearGradient get physics                    // Physics gradient
static LinearGradient get chemistry                  // Chemistry gradient
static LinearGradient get arabic                     // Arabic gradient
static LinearGradient get french                     // French gradient
static LinearGradient get english                    // English gradient
static LinearGradient get history                    // History gradient
static LinearGradient get geography                  // Geography gradient
static LinearGradient get philosophy                 // Philosophy gradient
static LinearGradient get islamic                    // Islamic studies gradient

// Semantic gradients
static LinearGradient get success                    // Success/green gradient
static LinearGradient get error                      // Error/red gradient
static LinearGradient get warning                    // Warning/orange gradient
static LinearGradient get info                       // Info/blue gradient

// Special effects
static LinearGradient get shimmer                    // Loading shimmer effect
static LinearGradient get glass                      // Glassmorphism effect
static LinearGradient get overlay                    // Dark overlay

// Helper methods
static LinearGradient createCustomGradient(List<Color> colors, {AlignmentGeometry? begin, AlignmentGeometry? end})
static LinearGradient getSubjectGradient(String subjectName)  // Auto-detect from name
static LinearGradient withOpacity(LinearGradient gradient, double opacity)
```

### AppDesignTokens (core/constants/app_design_tokens.dart)

```dart
// Getters for shadows
static BoxShadow get shadowPrimary                   // Primary shadow
static BoxShadow get shadowPrimaryLight              // Light shadow
static BoxShadow get shadowPrimarySubtle             // Subtle shadow
static BoxShadow get shadowCard                      // Card shadow
static BoxShadow get shadowCardHover                 // Card hover shadow
static BoxShadow get shadowButton                    // Button shadow

// Getters for padding
static EdgeInsets get paddingScreen                  // Screen padding
static EdgeInsets get paddingSection                 // Section padding
static EdgeInsets get paddingCard                    // Card padding
static EdgeInsets get paddingButton                  // Button padding
```

---

## PDF Font Loader (core/utils/pdf_font_loader.dart) ✅ NEW (2025-12-15)

### PdfFontLoader Static Methods

```dart
// Font loading
static Future<bool> loadFonts()                // Load Cairo font files from assets
static pw.Font? get regularFont                 // Get regular Cairo font (null if not loaded)
static pw.Font? get boldFont                    // Get bold Cairo font (null if not loaded)
static pw.Font? get semiBoldFont                // Get semi-bold Cairo font (null if not loaded)

// Theme generation
static pw.ThemeData getArabicTheme()           // Get PDF theme with Cairo fonts configured

// Status check
static bool get isReady                         // Check if fonts are loaded and ready

// Testing
static void reset()                             // Reset fonts (useful for testing)
```

**Purpose:** Loads Arabic (Cairo) font TTF files from `assets/fonts/` for proper Arabic text rendering in PDF exports.

**Key Features:**
- Lazy loading: Fonts loaded once on first use
- Graceful degradation: If fonts missing, returns default theme (Arabic shows as boxes ████)
- Console warnings: Prints helpful error if fonts not found
- Singleton pattern: Fonts cached after first load

**Usage Example:**
```dart
// 1. Load fonts (async)
final fontsLoaded = await PdfFontLoader.loadFonts();

// 2. Get theme with Arabic support
final theme = PdfFontLoader.getArabicTheme();

// 3. Use in PDF generation
pdf.addPage(
  pw.MultiPage(
    theme: theme,  // ← Enables Arabic text
    textDirection: pw.TextDirection.rtl,
    build: (context) => [
      pw.Text('الجدول الدراسي'),  // Renders correctly
    ],
  ),
);
```

**Font Files Required** (user must download):
- `assets/fonts/Cairo-Regular.ttf` (required)
- `assets/fonts/Cairo-Bold.ttf` (required)
- `assets/fonts/Cairo-SemiBold.ttf` (optional, falls back to Bold)

**Download from:** https://fonts.google.com/specimen/Cairo

**Used by:**
- Planner Schedule PDF Export (`planner_main_screen.dart:_exportScheduleToPdf()`)
- Session History PDF Export (`session_history_screen.dart:_exportHistory()`)

---

## Video Player Abstraction (core/video_player/)

### IVideoPlayer Interface (domain/video_player_interface.dart)

```dart
// Lifecycle
Future<void> initialize(String videoUrl, {Duration? startPosition})
Future<void> dispose()

// Playback Control
Future<void> play()
Future<void> pause()
Future<void> seekTo(Duration position)
Future<void> setPlaybackSpeed(double speed)
Future<void> setQuality(String quality)
Future<void> setFullscreen(bool fullscreen)

// Getters
Duration get currentPosition
Duration get duration
bool get isPlaying
bool get isBuffering
bool get isFullscreen
double get playbackSpeed
String? get currentQuality
List<String> get availableQualities
bool get isInitialized
String get playerType

// Streams
Stream<PlayerPlaybackState> get stateStream
Stream<Duration> get positionStream
Stream<Duration> get durationStream
Stream<bool> get bufferingStream
Stream<String> get errorStream

// UI
Widget buildPlayer(BuildContext context, {bool showControls = true})
```

### VideoPlayerFactory (domain/video_player_factory.dart)

```dart
static IVideoPlayer create(String playerType)        // Create player instance
static IVideoPlayer createWithFallback(String preferredPlayerType, {Function? onFallback})
static List<String> get availablePlayers            // ['chewie', 'media_kit', 'simple_youtube', 'omni', 'orax_video_player']
static String getPlayerDisplayName(String playerType)  // Arabic display name
static String getPlayerDescription(String playerType)  // Arabic description
static bool isValidPlayerType(String playerType)
static String get defaultPlayer                      // 'chewie'
```

### OraxPlayerImpl (infrastructure/orax_player_impl.dart) - NEW

```dart
// Implements IVideoPlayer interface
// Features: YouTube support, quality selection, subtitles, zoom
String get playerType => 'orax_video_player'
```

---

## VideoPlayer Feature (features/videoplayer/) - NEW

### VideoConfig (domain/entities/video_config.dart)

```dart
// Configuration for video player
const VideoConfig({
  required String videoUrl,
  String preferredPlayer = 'simple_youtube',
  bool showControls = true,
  bool autoPlay = false,
  Duration? startPosition,
  int? accentColorValue,
  bool showPlayerBadge = true,
  int autoSaveIntervalSeconds = 30,
})

// Factory constructors
factory VideoConfig.contentLibrary({required String videoUrl, ...})
factory VideoConfig.course({required String videoUrl, ...})
factory VideoConfig.minimal({required String videoUrl, ...})

// Computed properties
bool get isYouTubeUrl
bool get isVimeoUrl
bool get isPreferredPlayerYoutubeCompatible
String get effectivePlayerType              // With fallback logic
bool get didFallbackToYoutubePlayer
VideoConfig copyWith({...})
```

### VideoPlayerBloc (presentation/bloc/video_player_bloc.dart)

```dart
// State management for video player
class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState>

// Events
InitializeVideo(VideoConfig config)
PlayVideo()
PauseVideo()
TogglePlayPause()
SeekTo(Duration position)
SeekForward({Duration duration = const Duration(seconds: 10)})
SeekBackward({Duration duration = const Duration(seconds: 10)})
SetPlaybackSpeed(double speed)
SetVideoQuality(String quality)
ToggleFullscreen()
UpdatePosition({required Duration position, required Duration duration})
UpdateBuffering(bool isBuffering)
ReportError(String message)
RetryLoad()
VideoCompleted()
DisposePlayer()
ChangeVideoSource(VideoConfig newConfig)

// States
VideoPlayerInitial
VideoPlayerLoading(VideoConfig config)
VideoPlayerReady({
  required IVideoPlayer player,
  required VideoConfig config,
  Duration position,
  Duration duration,
  bool isPlaying,
  bool isBuffering,
  bool isFullscreen,
  double playbackSpeed,
  String? currentQuality,
  List<String> availableQualities,
  bool didFallback,
  required String effectivePlayerType,
})
VideoPlayerCompleted(VideoConfig config)
VideoPlayerError({required String message, VideoConfig? config, bool canRetry = true})

// Ready state computed properties
double get progress                         // 0.0 to 1.0
int get progressPercent                     // 0 to 100
bool get isCompleted                        // progress >= 0.99
```

### VideoPlayerWidget (presentation/widgets/video_player_widget.dart)

```dart
// Main reusable video player widget
const VideoPlayerWidget({
  required VideoConfig config,
  ValueChanged<double>? onProgress,
  VoidCallback? onCompleted,
  ValueChanged<String>? onError,
  bool showQuickControls = true,
  bool showProgressBar = true,
  Color? accentColor,
  bool showFallbackNotification = true,
})
```

### VideoPlayerControls (presentation/widgets/video_player_controls.dart)

```dart
// Quick action controls
const VideoPlayerControls({
  required Color accentColor,
  VoidCallback? onFullscreen,
  VoidCallback? onSeekForward,
  VoidCallback? onSeekBackward,
  bool enabled = true,
})

// Floating controls overlay
const VideoPlayerControlsOverlay({...})

// Progress bar with time display
const VideoProgressBar({
  required Duration position,
  required Duration duration,
  required Color accentColor,
  ValueChanged<Duration>? onSeek,
})
```

### PlayerTypeBadge (presentation/widgets/player_type_badge.dart)

```dart
const PlayerTypeBadge({
  required String playerType,
  required Color accentColor,
  double fontSize = 12,
})

const PlayerTypeBadgeCompact({
  required String playerType,
  required Color accentColor,
})
```

### VideoLoadingState (presentation/widgets/video_loading_state.dart)

```dart
const VideoLoadingState({Color accentColor, String? message, String? submessage})
const VideoLoadingIndicator({Color accentColor, double size = 40})
const VideoBufferingOverlay({Color accentColor, bool isVisible = true})
```

### VideoErrorState (presentation/widgets/video_error_state.dart)

```dart
const VideoErrorState({
  required String message,
  Color accentColor,
  VoidCallback? onRetry,
  bool canRetry = true,
})

const VideoErrorIndicator({String? message, VoidCallback? onRetry, Color accentColor})
const NoVideoState({Color accentColor})
```

### FullscreenVideoPage (presentation/pages/fullscreen_video_page.dart)

```dart
const FullscreenVideoPage({
  required VideoPlayerBloc bloc,
  required String title,
  String? subtitle,
  required Color accentColor,
  VoidCallback? onCompleted,
})

static Future<void> show(BuildContext context, {...})  // Navigate to fullscreen
```

---

## Core Widget Functions (NEW)

### Cards

#### GradientHeroCard (core/widgets/cards/gradient_hero_card.dart)

```dart
Widget build(BuildContext context)
Widget _buildDecorativeCircles()                     // Background decoration
```

#### StatCardMini (core/widgets/cards/stat_card_mini.dart)

```dart
Widget build(BuildContext context)
Widget _buildIconContainer()                         // Icon container with gradient
```

#### StatCardMiniHorizontal

```dart
Widget build(BuildContext context)
```

#### ProgressCard (core/widgets/cards/progress_card.dart)

```dart
Widget build(BuildContext context)
Widget _buildProgressBar()                           // Animated progress bar
Color _getProgressColor(double progress)             // Dynamic color based on progress
```

#### SessionCard (core/widgets/cards/session_card.dart)

```dart
Widget build(BuildContext context)
Widget _buildGradientIcon()                          // Icon with gradient background
Widget _buildTimeInfo()                              // Time and duration display
```

#### InfoCard (core/widgets/cards/info_card.dart)

```dart
Widget build(BuildContext context)
```

#### BacArchivesCard (core/widgets/cards/bac_archives_card.dart)

```dart
Widget build(BuildContext context)
Widget _buildYearBadge()                             // Year display badge
Widget _buildGradientOverlay()                       // Gradient overlay effect
```

#### BacArchivesCardHorizontal

```dart
Widget build(BuildContext context)
```

#### ActiveSessionTimerCard (core/widgets/cards/active_session_timer_card.dart) - NEW

```dart
// Active session timer with circular progress and pulse animation
Widget build(BuildContext context)
String get _formattedTime                          // Format remaining time
double get _progress                               // Calculate progress percentage

// Properties
final String subjectName
final String? topicName
final Color subjectColor
final Duration remainingDuration
final Duration totalDuration
final VoidCallback? onTap
final VoidCallback? onContinue
```

#### ModernStatCard (core/widgets/cards/modern_stat_card.dart) - NEW

```dart
// Stat card with icon, value, and label in vertical layout
Widget build(BuildContext context)

// Properties
final IconData icon
final Color iconColor
final String value
final String label
final VoidCallback? onTap

// ModernStatsRow - Row of 3 stat cards
Widget build(BuildContext context)

// ModernStatData - Data class for stats
class ModernStatData {
  final IconData icon
  final Color iconColor
  final String value
  final String label
  final VoidCallback? onTap
}
```

#### ModernSectionCard (core/widgets/cards/modern_section_card.dart) - NEW

```dart
// White card with section header (icon + title + view all)
Widget build(BuildContext context)
Widget _buildHeader()

// Properties
final IconData icon
final Color iconColor
final String title
final VoidCallback? onViewAll
final String viewAllText
final Widget child
final bool showBackground
final EdgeInsets padding

// ModernSectionHeader - Header without card wrapper
Widget build(BuildContext context)
```

### Badges

#### StatBadge (core/widgets/badges/stat_badge.dart)

```dart
Widget build(BuildContext context)
double _getBadgeSize(BadgeSize size)                 // Size calculation
```

#### TimeBadge (core/widgets/badges/time_badge.dart)

```dart
Widget build(BuildContext context)
```

#### LiveTimerBadge

```dart
void initState()
void dispose()
void _startPulseAnimation()                          // Pulse animation for live timer
Widget build(BuildContext context)
```

#### CoefficientBadge (core/widgets/badges/coefficient_badge.dart)

```dart
Widget build(BuildContext context)
Color _getCoefficientColor(int coefficient)          // Color based on coefficient value
```

#### LevelBadge (core/widgets/badges/level_badge.dart)

```dart
Widget build(BuildContext context)
```

#### LevelBadgeCircular

```dart
Widget build(BuildContext context)
```

### Layouts

#### SectionHeader (core/widgets/layouts/section_header.dart)

```dart
Widget build(BuildContext context)
Widget _buildViewAllButton()                         // "View All" button
```

#### PageScaffold (core/widgets/layouts/page_scaffold.dart)

```dart
Widget build(BuildContext context)
PreferredSizeWidget? _buildAppBar()                  // Custom app bar
```

#### PageScaffoldWithRefresh

```dart
Future<void> _handleRefresh()                        // Pull to refresh handler
Widget build(BuildContext context)
```

#### GridLayout (core/widgets/layouts/grid_layout.dart)

```dart
Widget build(BuildContext context)
```

#### ResponsiveGrid

```dart
int _getColumnCount(double width)                    // Auto column count based on width
Widget build(BuildContext context)
```

### Inputs

#### AppSearchBar (core/widgets/inputs/app_search_bar.dart)

```dart
Widget build(BuildContext context)
void _handleClear()                                  // Clear button handler
```

#### AppSearchBarCompact

```dart
Widget build(BuildContext context)
```

#### FilterChipGroup (core/widgets/inputs/filter_chip_group.dart)

```dart
Widget build(BuildContext context)
Widget _buildChip(int index)                         // Individual chip builder
```

#### IconFilterChip

```dart
Widget build(BuildContext context)
```

#### MultiSelectFilterChipGroup

```dart
Widget build(BuildContext context)
Widget _buildChip(int index)
void _handleSelection(int index)                     // Multi-select handler
```

### Navigation

#### BottomNavItem (core/widgets/modern_bottom_nav.dart)

```dart
// Navigation item data model
class BottomNavItem {
  final IconData icon;              // Inactive icon
  final IconData activeIcon;        // Active icon
  final String label;               // Navigation label
  final List<Color> gradientColors; // Individual gradient colors
}
```

#### ModernBottomNavigationBar (core/widgets/modern_bottom_nav.dart)

```dart
// Constructor - requires selectedIndex and onItemTapped
const ModernBottomNavigationBar({
  required int selectedIndex,
  required Function(int) onItemTapped,
})

Widget build(BuildContext context)
Widget _buildBottomNavItem(BuildContext context, {
  required BottomNavItem item,
  required int index,
  required bool isSelected,
})
```

**Features:**
- Glassmorphism with backdrop blur (15px)
- Individual gradient colors per item
- Multi-layer shadows with glow effect
- Active indicator line with animation
- Icon size animations with ScaleTransition
- Haptic feedback on tap (HapticFeedback.lightImpact)

**Navigation Items (5 items) with individual colors:**
- 0: الرئيسية (home) - Blue gradient [#3B82F6, #1D4ED8]
- 1: دوراتي (school) - Green gradient [#10B981, #059669]
- 2: اشتراكاتي (subscriptions) - Purple gradient [#8B5CF6, #6D28D9]
- 3: بلانر (calendar) - Orange gradient [#F59E0B, #D97706]
- 4: حسابي (person) - Red gradient [#EF4444, #DC2626]

#### CategoryItem (core/widgets/category_chips.dart)

```dart
// Category model with individual colors
class CategoryItem {
  final String name;
  final IconData? icon;
  final Color? activeColor;
  final List<Color>? gradientColors;
}
```

#### AppCategories (core/widgets/category_chips.dart)

```dart
// Default categories with individual gradient colors
static const List<CategoryItem> categories = [
  CategoryItem(name: 'الرئيسية', icon: Icons.home_rounded,
    gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),     // Blue
  CategoryItem(name: 'بلانر', icon: Icons.calendar_month_rounded,
    gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),     // Purple
  CategoryItem(name: 'ملخصات و دروس', icon: Icons.menu_book_rounded,
    gradientColors: [Color(0xFF10B981), Color(0xFF059669)]),     // Green
  CategoryItem(name: 'بكالوريات', icon: Icons.school_rounded,
    gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)]),     // Orange
  CategoryItem(name: 'كويز', icon: Icons.quiz_rounded,
    gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)]),     // Red
  CategoryItem(name: 'دوراتنا', icon: Icons.play_circle_rounded,
    gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),     // Cyan
];

// Get categories in custom order
static List<CategoryItem> getOrderedCategories(List<int> order)
static CategoryItem getCategoryAt(int index)
static int get count
```

#### CategoryChips (core/widgets/category_chips.dart)

```dart
// Widget with modern glassmorphism design
const CategoryChips({
  required List<CategoryItem> categories,
  required int selectedIndex,
  required Function(int) onSelected,
  bool showIcons = true,           // Toggle icon visibility
  bool useGlassmorphism = true,    // Toggle glassmorphism effect
})

void _scrollToSelectedChip()       // Auto-scroll to selected chip with centering
Widget _buildChip(CategoryItem, bool isSelected, VoidCallback onTap, int index)
```

**Features:**
- Glassmorphism with backdrop blur (5px)
- Individual gradient colors per category
- Animated container with easeOutCubic curve
- Category-specific shadows with glow effect
- Animated icon container with background
- Smooth text animations

#### MainAppBar (core/widgets/main_app_bar.dart)

```dart
const MainAppBar({
  required List<CategoryItem> categories,
  required int selectedCategoryIndex,
  required Function(int) onCategorySelected,
  VoidCallback? onProfileTap,
  VoidCallback? onNotificationTap,
  int streakCount = 0,
  String? userName,
  String? userAvatar,
})

Size get preferredSize => Size.fromHeight(120)
Widget _buildDefaultAvatar()
```

#### MainScreen (features/home/presentation/pages/main_screen.dart)

```dart
// State management
int _selectedNavIndex = 0;             // Bottom nav index (0-3)
int _selectedCategoryIndex = 0;        // Category chip index (0-4)
PageController _pageController;

// Handlers
void _onCategorySelected(int index)    // Category chip tap
void _onPageChanged(int index)         // PageView swipe
void _onNavItemTapped(int index)       // Bottom nav tap

// Builders
String? _getUserName(BuildContext context)
Widget _buildHomeContent()             // PageView with 5 category views
Widget _buildBody()                    // Switch based on nav index
```

---

## Core Functions

### DioClient (core/network/dio_client.dart)

```dart
Future<Response> get(String path, {Map<String, dynamic>? queryParameters})
Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters})
Future<Response> put(String path, {dynamic data})
Future<Response> delete(String path)
```

### SecureStorageService (core/storage/secure_storage_service.dart)

```dart
Future<void> saveToken(String token)
Future<String?> getToken()
Future<void> deleteToken()
Future<void> saveDeviceId(String deviceId)
Future<String?> getDeviceId()
Future<void> deleteDeviceId()
```

### HiveService (core/storage/hive_service.dart)

```dart
Future<void> init()
Future<void> clear()
```

### Validators (core/utils/validators.dart)

```dart
static String? validateEmail(String? value)
static String? validatePassword(String? value)
static String? validateName(String? value)
static String? validatePhone(String? value)
static String? validateRequired(String? value, String fieldName)
static String? validateMinLength(String? value, int minLength, String fieldName)
static String? validateMaxLength(String? value, int maxLength, String fieldName)
static String? validateConfirmPassword(String? value, String password)
```

### Formatters (core/utils/formatters.dart)

```dart
static String formatArabicNumber(int number)
static String formatArabicDecimal(double number, {int decimals = 2})
static String formatDate(DateTime date, {bool includeTime = false})
static String formatTime(DateTime time)
static String formatDuration(Duration duration)
static String formatFileSize(int bytes)
```

### NotificationService (core/services/notification_service.dart)

```dart
// Singleton access
factory NotificationService()                           // Factory constructor
static NotificationService get instance                 // Singleton instance

// Initialization
Future<void> init()                                     // Initialize Firebase & local notifications
Future<bool> requestPermission()                        // Request notification permissions

// Token management
String? get fcmToken                                    // Current FCM token
Stream<String> get onTokenRefresh                       // Token refresh stream
Future<void> deleteToken()                              // Delete FCM token

// Message streams
Stream<Map<String, dynamic>> get onNotification         // Notification event stream

// Internal handlers
Future<void> _setupHandlers()                           // Setup message handlers
Future<void> _showLocalNotification({title, body, data, id})  // Show local notification
```

### FcmTokenService (core/services/fcm_token_service.dart)

```dart
Future<void> init()                                     // Initialize & get device info
Future<bool> registerToken()                            // Register FCM token with API
Future<bool> unregisterDevice()                         // Unregister device (logout)
Future<List<Map<String, dynamic>>> getDevices()         // Get user's registered devices
```

---

## Notifications Feature Functions (NEW)

### NotificationRepository (features/notifications/domain/repositories/notification_repository.dart)

```dart
Future<Either<Failure, NotificationsListEntity>> getNotifications({page, perPage, isRead, type})
Future<Either<Failure, int>> getUnreadCount()
Future<Either<Failure, bool>> markAsRead(String notificationId)
Future<Either<Failure, int>> markAllAsRead()
Future<Either<Failure, bool>> deleteNotification(String notificationId)
Future<Either<Failure, bool>> registerFcmToken({token, deviceUuid, platform})
Future<Either<Failure, bool>> unregisterDevice(String deviceUuid)
Future<List<NotificationEntity>> getCachedNotifications()
Future<void> clearCache()
```

### NotificationsBloc (features/notifications/presentation/bloc/notifications_bloc.dart)

```dart
// Events
LoadNotifications({refresh, isRead, type})              // Load notifications list
LoadMoreNotifications()                                 // Load next page
RefreshUnreadCount()                                    // Refresh unread count
MarkNotificationAsRead(notificationId)                  // Mark single as read
MarkAllNotificationsAsRead()                            // Mark all as read
DeleteNotification(notificationId)                      // Delete notification
NotificationReceived({title, body, data})               // FCM notification received
NotificationTapped(data)                                // Notification tapped

// States
NotificationsInitial                                    // Initial state
NotificationsLoading                                    // Loading state
NotificationsLoaded(notifications, unreadCount, total, hasMore)  // Loaded state
NotificationsLoadingMore(currentNotifications)          // Loading more state
NotificationsError(message, cachedNotifications)        // Error state
NewNotificationReceived(title, body, data)              // New notification received
NavigateToDestination(route, arguments)                 // Deep link navigation
```

---

## Auth Feature Functions

### Domain - Entities

#### UserEntity (features/auth/domain/entities/user_entity.dart)

```dart
bool get hasAcademicProfile
String get fullName
```

#### AcademicProfileEntity

```dart
bool get isComplete
```

### Domain - Use Cases

#### LoginUseCase (features/auth/domain/usecases/login_usecase.dart)

```dart
Future<Either<Failure, UserEntity>> call({
  required String email,
  required String password,
  required String deviceId,
})
```

#### RegisterUseCase (features/auth/domain/usecases/register_usecase.dart)

```dart
Future<Either<Failure, UserEntity>> call({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  String? phone,
  required String deviceId,
})
```

#### ValidateTokenUseCase (features/auth/domain/usecases/validate_token_usecase.dart)

```dart
Future<Either<Failure, UserEntity>> call()
```

#### LogoutUseCase (features/auth/domain/usecases/logout_usecase.dart)

```dart
Future<Either<Failure, void>> call({required bool logoutFromAllDevices})
```

### Data - Remote DataSource

#### AuthRemoteDataSource (features/auth/data/datasources/auth_remote_datasource.dart)

```dart
Future<LoginResponseModel> login(String email, String password, String deviceId)
Future<LoginResponseModel> register({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  String? phone,
  required String deviceId,
})
Future<UserModel> validateToken()
Future<void> logout(bool logoutFromAllDevices)
Future<UserModel> updateAcademicProfile(int phaseId, int yearId, int? streamId)
```

### Data - Local DataSource

#### AuthLocalDataSource (features/auth/data/datasources/auth_local_datasource.dart)

```dart
Future<UserModel?> getCachedUser()
Future<void> cacheUser(UserModel user)
Future<void> clearCache()
```

### Data - Repository Implementation

#### AuthRepositoryImpl (features/auth/data/repositories/auth_repository_impl.dart)

```dart
Future<Either<Failure, UserEntity>> login({...})
Future<Either<Failure, UserEntity>> register({...})
Future<Either<Failure, UserEntity>> validateToken()
Future<Either<Failure, void>> logout({...})
Future<Either<Failure, UserEntity>> updateAcademicProfile({...})
Future<bool> isAuthenticated()
```

### Data - Models

#### UserModel (features/auth/data/models/user_model.dart)

```dart
factory UserModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
UserEntity toEntity()
```

#### LoginResponseModel (features/auth/data/models/login_response_model.dart)

```dart
factory LoginResponseModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
```

### Presentation - BLoC

#### AuthBloc (features/auth/presentation/bloc/auth_bloc.dart)

```dart
Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit)
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit)
Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit)
Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit)
Future<void> _onAcademicProfileUpdateRequested(AcademicProfileUpdateRequested event, Emitter<AuthState> emit)
Future<String> _getOrGenerateDeviceId()
```

### Presentation - Pages

#### SplashPage (features/auth/presentation/pages/splash_page.dart)

```dart
void initState()
void dispose()
Widget build(BuildContext context)
```

#### LoginPage (features/auth/presentation/pages/login_page.dart)

```dart
void _handleLogin()
void _showDeviceMismatchDialog(BuildContext context)
String? _validateEmail(String? value)
String? _validatePassword(String? value)
Widget build(BuildContext context)
```

#### RegisterPage (features/auth/presentation/pages/register_page.dart)

```dart
void _handleRegister()
String? validateConfirmPassword(String? value)
Widget build(BuildContext context)
```

#### OnboardingPage (features/auth/presentation/pages/onboarding_page.dart)

```dart
Future<void> _completeOnboarding()
void _nextPage()
Widget _buildPage1Welcome()
Widget _buildPage2Features()
Widget _buildPage3Motivation()
Widget _buildFeatureItem(String icon, String title, String description)
Widget _buildStatItem(String value, String label)
```

#### AcademicSelectionPage (features/auth/presentation/pages/academic_selection_page.dart)

```dart
void _goToNextStep()
void _goToPreviousStep()
void _submitAcademicProfile()
bool _canContinue()
Widget _buildProgressIndicator()
Widget _buildPhaseSelection()
Widget _buildYearSelection()
Widget _buildStreamSelection()
```

### Presentation - Widgets

#### SelectionCard (features/auth/presentation/widgets/selection_card.dart)

```dart
Widget build(BuildContext context)
```

---

## Home Feature Functions

### Domain - Entities

#### StatsEntity (features/home/domain/entities/stats_entity.dart)

```dart
double get levelProgress
double get dailyGoalProgress
String get formattedStudyTime
```

#### StudySessionEntity (features/home/domain/entities/study_session_entity.dart)

```dart
int get durationMinutes
String get formattedDuration
Duration get timeUntilStart
bool get isToday
bool get isNow
bool get hasPassed
String get typeLabel
```

#### SubjectProgressEntity (features/home/domain/entities/subject_progress_entity.dart)

```dart
double get completionPercentage
bool get hasExamSoon
int? get daysUntilExam
String get coefficientLabel
String get completionLabel
```

### Domain - Use Cases

#### GetDashboardDataUseCase (features/home/domain/usecases/get_dashboard_data_usecase.dart)

```dart
Future<Either<Failure, DashboardData>> call()
```

#### MarkSessionCompletedUseCase (features/home/domain/usecases/mark_session_completed_usecase.dart)

```dart
Future<Either<Failure, void>> call(int sessionId)
```

### Data - Remote DataSource

#### HomeRemoteDataSource (features/home/data/datasources/home_remote_datasource.dart)

```dart
Future<StatsModel> getStats()
Future<List<StudySessionModel>> getTodaySessions()
Future<List<SubjectProgressModel>> getSubjectsProgress()
Future<void> markSessionCompleted(int sessionId)
Future<void> markSessionMissed(int sessionId)
Future<void> updateStudyTime(int minutes)
```

### Data - Local DataSource

#### HomeLocalDataSource (features/home/data/datasources/home_local_datasource.dart)

```dart
Future<StatsModel?> getCachedStats()
Future<void> cacheStats(StatsModel stats)
Future<List<StudySessionModel>?> getCachedTodaySessions()
Future<void> cacheTodaySessions(List<StudySessionModel> sessions)
Future<List<SubjectProgressModel>?> getCachedSubjectsProgress()
Future<void> cacheSubjectsProgress(List<SubjectProgressModel> subjects)
```

### Data - Repository Implementation

#### HomeRepositoryImpl (features/home/data/repositories/home_repository_impl.dart)

```dart
Future<Either<Failure, StatsEntity>> getStats()
Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions()
Future<Either<Failure, List<SubjectProgressEntity>>> getSubjectsProgress()
Future<Either<Failure, void>> markSessionCompleted(int sessionId)
Future<Either<Failure, void>> markSessionMissed(int sessionId)
Future<Either<Failure, void>> updateStudyTime(int minutes)
```

### Data - Models

#### StatsModel (features/home/data/models/stats_model.dart)

```dart
factory StatsModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
StatsEntity toEntity()
```

### Presentation - BLoC

#### HomeBloc (features/home/presentation/bloc/home_bloc.dart)

```dart
Future<void> _onLoadDashboard(LoadDashboard event, Emitter<HomeState> emit)
Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<HomeState> emit)
Future<void> _onMarkSessionCompleted(MarkSessionCompleted event, Emitter<HomeState> emit)
```

### Presentation - Pages

#### HomePage (features/home/presentation/pages/home_page.dart)

```dart
Widget build(BuildContext context)
Widget _buildLoadedState(DashboardData data)
Widget _buildHeroSection(StatsEntity stats)           // Hero card with stats
Widget _buildQuickStats(StatsEntity stats)            // Mini stat cards
Widget _buildTodaySessions(List<StudySessionEntity> sessions)  // Session list
Widget _buildSubjectsGrid(List<SubjectProgressEntity> subjects)  // Subject grid
void _handleRefresh()                                 // Pull to refresh
```

#### StudySessionModel (features/home/data/models/study_session_model.dart)

```dart
factory StudySessionModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
StudySessionEntity toEntity()
SessionType _parseSessionType(String type)
SessionStatus _parseSessionStatus(String status)
```

#### SubjectProgressModel (features/home/data/models/subject_progress_model.dart)

```dart
factory SubjectProgressModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
SubjectProgressEntity toEntity()
```

### Presentation - Widgets (NEW - Home Redesign)

#### UserHeroCard (features/home/presentation/widgets/user_hero_card.dart)

Modern glassmorphism hero card with level, XP, avatar and mini stats.

```dart
Widget build(BuildContext context)
List<Widget> _buildDecorativeCircles()        // Background decoration circles
Widget _buildTopRow()                          // Avatar + greeting section
Widget _buildAvatarPlaceholder()               // Fallback avatar with initial
Widget _buildLevelSection(double progress, int progressPercent, int currentLevelPoints)
Widget _buildMiniStatsRow()                    // Streak, study time, rank
Widget _buildMiniStat({IconData icon, String value, String label, Color iconColor})
```

#### QuickActionsGrid (features/home/presentation/widgets/quick_actions_grid.dart)

2x2 grid for quick navigation actions.

```dart
Widget build(BuildContext context)
Widget _buildActionButton({String title, String subtitle, IconData icon, List<Color> gradientColors, VoidCallback? onTap})
```

#### WeeklyProgressWidget (features/home/presentation/widgets/weekly_progress_widget.dart)

7-day bar chart with animations showing weekly study progress.

```dart
Widget build(BuildContext context)
Widget _buildDayBar(DayProgress day, double maxMinutes, bool isToday)
Widget _buildEmptyState()
String _formatMinutes(int minutes)
```

#### LeaderboardPreviewWidget (features/home/presentation/widgets/leaderboard_preview_widget.dart)

Compact leaderboard preview showing top 3 and current user's position.

```dart
Widget build(BuildContext context)
bool _shouldShowCurrentUser()                  // Check if user should be shown (not in top 3)
Widget _buildEmptyState()
Widget _buildCompactPodiumItem(LeaderboardEntry entry, int rank)
Widget _buildAvatarPlaceholder(LeaderboardEntry entry)
Widget _buildCurrentUserRank()
String _getRankEmoji(int rank)                 // Returns 🥇, 🥈, 🥉
List<Color> _getRankColors(int rank)           // Gold, silver, bronze gradients
```

#### PromoSliderWidget (features/home/presentation/widgets/promo_slider_widget.dart)

Auto-advancing promotional slider with API integration and dots indicator.

```dart
Widget build(BuildContext context)
void _startAutoPlay()                          // Start auto-play timer
void _onPageChanged(int page)                  // Handle page change
Widget _buildPromoCard(PromoItem item, int index)  // Build single promo card
List<Widget> _buildDecorativeElements(PromoItem item)  // Background decorations
Widget _buildPromoImage(PromoItem item)        // Image or icon display
Widget _buildIconFallback(PromoItem item)      // Fallback icon
Widget _buildDotsIndicator()                   // Page indicator dots
```

#### PromoItem (Model for promo slider)

```dart
const PromoItem({
  int? id,                                     // Promo ID from API
  required String title,
  String? subtitle,
  String? badge,
  String? actionText,
  IconData? icon,
  String? imageUrl,
  List<Color>? gradientColors,
  LinearGradient? gradient,
  String? actionType,                          // 'route', 'url', 'none'
  String? actionValue,                         // Route path or URL
  VoidCallback? onTap,
})
factory PromoItem.fromEntity(PromoEntity entity, {VoidCallback? onTap})  // Create from API entity
static List<PromoItem> fromEntities(List<PromoEntity> entities, {void Function(PromoEntity)?})
static IconData? _iconFromName(String? iconName)  // Map icon name to IconData
static List<Color>? _parseGradientColors(List<String>? hexColors)  // Parse hex to Color
static List<PromoItem> get defaultItems        // Default promotional items (fallback)
```

### Promo Feature - Domain Layer (NEW)

#### PromoEntity (features/home/domain/entities/promo_entity.dart)

```dart
class PromoEntity extends Equatable {
  final int id;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? actionText;
  final String? iconName;
  final String? imageUrl;
  final List<String>? gradientColors;
  final String? actionType;
  final String? actionValue;
  final int order;
  final bool isActive;
}

class PromosResponse extends Equatable {
  final List<PromoEntity> promos;
  final bool sectionEnabled;
}
```

#### PromoRepository (features/home/domain/repositories/promo_repository.dart)

```dart
abstract class PromoRepository {
  Future<Either<Failure, PromosResponse>> getPromos();
  Future<Either<Failure, void>> recordPromoClick(int promoId);
}
```

#### GetPromosUseCase (features/home/domain/usecases/get_promos_usecase.dart)

```dart
Future<Either<Failure, PromosResponse>> call()
```

#### RecordPromoClickUseCase (features/home/domain/usecases/record_promo_click_usecase.dart)

```dart
Future<Either<Failure, void>> call(int promoId)
```

### Promo Feature - Data Layer (NEW)

#### PromoModel (features/home/data/models/promo_model.dart)

```dart
factory PromoModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
PromoEntity toEntity()

class PromoApiResponse {
  factory PromoApiResponse.fromJson(Map<String, dynamic> json)
}
```

#### PromoRemoteDataSource (features/home/data/datasources/promo_remote_datasource.dart)

```dart
Future<PromoApiResponse> getPromos()           // GET /v1/promos
Future<void> recordPromoClick(int promoId)     // POST /v1/promos/{id}/click
```

### Promo Feature - BLoC (NEW)

#### PromoBloc (features/home/presentation/bloc/promo/promo_bloc.dart)

```dart
Future<void> _onLoadPromos(LoadPromos event, Emitter<PromoState> emit)
Future<void> _onRefreshPromos(RefreshPromos event, Emitter<PromoState> emit)
Future<void> _onRecordPromoClick(RecordPromoClick event, Emitter<PromoState> emit)
```

#### PromoEvent (features/home/presentation/bloc/promo/promo_event.dart)

```dart
class LoadPromos extends PromoEvent {}
class RefreshPromos extends PromoEvent {}
class RecordPromoClick extends PromoEvent { final int promoId; }
```

#### PromoState (features/home/presentation/bloc/promo/promo_state.dart)

```dart
class PromoInitial extends PromoState {}
class PromoLoading extends PromoState {}
class PromoLoaded extends PromoState { final List<PromoEntity> promos; final bool sectionEnabled; }
class PromoError extends PromoState { final String message; final List<PromoEntity>? cachedPromos; }
```

---

## Core Widgets

### GradientSubjectCard (core/widgets/gradient_subject_card.dart) **NEW**

Reusable gradient subject card widget used by Content Library and BAC Archives pages.

```dart
// Constructor
const GradientSubjectCard({
  Key? key,
  required String nameAr,        // Arabic subject name
  required int coefficient,       // Subject coefficient (معامل)
  required VoidCallback onTap,    // Tap handler
  Color? color,                   // Optional custom color (auto-detected from name if null)
  IconData? icon,                 // Optional custom icon (auto-mapped from name if null)
})

// Auto-mapping methods
Color _getSubjectColor(String subjectName)    // Maps Arabic name to color
IconData _getSubjectIcon(String subjectName)  // Maps Arabic name to icon

// Design features:
// - 2-column grid compatible
// - Gradient background with shadow
// - Decorative background circles
// - Icon container with transparency
// - Coefficient badge
// - Arrow indicator (top-left)
```

### PrimaryButton (core/widgets/primary_button.dart)

```dart
Widget build(BuildContext context)
```

### AppTextField (core/widgets/app_text_field.dart)

```dart
Widget build(BuildContext context)
```

### LoadingWidget (core/widgets/loading_widget.dart)

```dart
Widget build(BuildContext context)
```

### ErrorWidget (core/widgets/error_widget.dart)

```dart
Widget build(BuildContext context)
```

---

## Planner Feature Functions

### SelectableSubject Entity (features/planner/domain/entities/selectable_subject.dart)

```dart
factory SelectableSubject.fromSubject(Subject subject)
SelectableSubject copyWith({Subject? subject, bool? isSelected, int? difficultyLevel, Priority? priority, int? progressPercentage})
String get difficultyStars
Color get priorityColor
```

### PlannerRepository (features/planner/domain/repositories/planner_repository.dart)

```dart
Future<Either<Failure, List<Subject>>> getAcademicSubjects()
Future<Either<Failure, List<PlannerSubject>>> batchCreatePlannerSubjects(List<PlannerSubjectCreate> subjects)
Future<Either<Failure, List<PlannerSubject>>> getUserPlannerSubjects()
Future<Either<Failure, PlannerSubject>> updatePlannerSubject(int id, PlannerSubjectUpdate data)
Future<Either<Failure, void>> deletePlannerSubject(int id)
Future<Either<Failure, ScheduleResponse>> generateSchedule(ScheduleGenerationParams params)
Future<Either<Failure, List<PlannerSession>>> getTodaySessions()
Future<Either<Failure, PlannerSession>> startSession(int sessionId)
Future<Either<Failure, PlannerSession>> completeSession(int sessionId, SessionCompletionData data)
Future<Either<Failure, Exam>> createExam(ExamCreate data)
Future<Either<Failure, List<Exam>>> getUserExams()
```

### Use Cases (features/planner/domain/usecases/)

```dart
// get_academic_subjects.dart
Future<Either<Failure, List<Subject>>> call(NoParams params)

// batch_create_planner_subjects.dart
Future<Either<Failure, List<PlannerSubject>>> call(BatchCreateParams params)

// get_user_planner_subjects.dart
Future<Either<Failure, List<PlannerSubject>>> call(NoParams params)

// update_planner_subject.dart
Future<Either<Failure, PlannerSubject>>> call(UpdateSubjectParams params)

// delete_planner_subject.dart
Future<Either<Failure, void>> call(DeleteSubjectParams params)

// generate_schedule.dart
Future<Either<Failure, ScheduleResponse>> call(ScheduleGenerationParams params)

// get_today_sessions.dart
Future<Either<Failure, List<PlannerSession>>> call(NoParams params)

// start_session.dart
Future<Either<Failure, PlannerSession>> call(SessionIdParams params)

// complete_session.dart
Future<Either<Failure, PlannerSession>> call(CompleteSessionParams params)

// create_exam.dart
Future<Either<Failure, Exam>> call(CreateExamParams params)

// get_user_exams.dart
Future<Either<Failure, List<Exam>>> call(NoParams params)
```

### PlannerRemoteDataSource (features/planner/data/datasources/planner_remote_datasource.dart)

```dart
Future<List<SubjectModel>> getAcademicSubjects()
Future<List<PlannerSubjectModel>> batchCreatePlannerSubjects(List<PlannerSubjectCreate> subjects)
Future<List<PlannerSubjectModel>> getUserPlannerSubjects()
Future<PlannerSubjectModel> updatePlannerSubject(int id, Map<String, dynamic> data)
Future<void> deletePlannerSubject(int id)
Future<ScheduleResponseModel> generateSchedule(Map<String, dynamic> params)
Future<List<PlannerSessionModel>> getTodaySessions()
Future<PlannerSessionModel> startSession(int sessionId)
Future<PlannerSessionModel> completeSession(int sessionId, Map<String, dynamic> data)
Future<ExamModel> createExam(Map<String, dynamic> data)
Future<List<ExamModel>> getUserExams()
```

### PlannerLocalDataSource (features/planner/data/datasources/planner_local_datasource.dart)

```dart
Future<void> cacheAcademicSubjects(List<SubjectModel> subjects)
Future<List<SubjectModel>?> getCachedAcademicSubjects()
Future<void> cacheUserPlannerSubjects(List<PlannerSubjectModel> subjects)
Future<List<PlannerSubjectModel>?> getCachedUserPlannerSubjects()
Future<void> cacheTodaySessions(List<PlannerSessionModel> sessions)
Future<List<PlannerSessionModel>?> getCachedTodaySessions()
Future<void> clearPlannerCache()
```

### SubjectSelectionBloc (features/planner/presentation/bloc/subject_selection/)

#### Events:
```dart
class LoadAcademicSubjects extends SubjectSelectionEvent
class ToggleSubjectSelection extends SubjectSelectionEvent { final int subjectId; }
class UpdateSubjectPriority extends SubjectSelectionEvent { final int subjectId; final Priority priority; }
class UpdateSubjectDifficulty extends SubjectSelectionEvent { final int subjectId; final int difficulty; }
class SelectAllSubjects extends SubjectSelectionEvent
class DeselectAllSubjects extends SubjectSelectionEvent
class ConfirmSubjectSelection extends SubjectSelectionEvent
```

#### States:
```dart
class SubjectSelectionInitial extends SubjectSelectionState
class SubjectSelectionLoading extends SubjectSelectionState
class SubjectSelectionLoaded extends SubjectSelectionState { final List<SelectableSubject> streamSubjects; final List<SelectableSubject> commonSubjects; final int selectedCount; }
class SubjectSelectionSaving extends SubjectSelectionState
class SubjectSelectionSaved extends SubjectSelectionState { final List<PlannerSubject> savedSubjects; }
class SubjectSelectionError extends SubjectSelectionState { final String message; }
```

#### Methods:
```dart
Future<void> _onLoadAcademicSubjects(LoadAcademicSubjects event, Emitter<SubjectSelectionState> emit)
void _onToggleSelection(ToggleSubjectSelection event, Emitter<SubjectSelectionState> emit)
void _onUpdatePriority(UpdateSubjectPriority event, Emitter<SubjectSelectionState> emit)
void _onUpdateDifficulty(UpdateSubjectDifficulty event, Emitter<SubjectSelectionState> emit)
void _onSelectAll(SelectAllSubjects event, Emitter<SubjectSelectionState> emit)
void _onDeselectAll(DeselectAllSubjects event, Emitter<SubjectSelectionState> emit)
Future<void> _onConfirmSelection(ConfirmSubjectSelection event, Emitter<SubjectSelectionState> emit)
```

### PlannerBloc (features/planner/presentation/bloc/planner/)

#### Events:
```dart
class CheckUserSubjects extends PlannerEvent
class LoadTodaySchedule extends PlannerEvent
class GenerateSchedule extends PlannerEvent { final ScheduleGenerationParams params; }
class RefreshSchedule extends PlannerEvent
```

#### States:
```dart
class PlannerInitial extends PlannerState
class PlannerSubjectsEmpty extends PlannerState
class PlannerSubjectsLoaded extends PlannerState { final List<PlannerSubject> subjects; }
class PlannerLoading extends PlannerState
class PlannerTodayLoaded extends PlannerState { final List<PlannerSession> sessions; }
class PlannerScheduleGenerated extends PlannerState { final ScheduleResponse schedule; }
class PlannerError extends PlannerState { final String message; }
```

#### Methods:
```dart
Future<void> _onCheckUserSubjects(CheckUserSubjects event, Emitter<PlannerState> emit)
Future<void> _onLoadTodaySchedule(LoadTodaySchedule event, Emitter<PlannerState> emit)
Future<void> _onGenerateSchedule(GenerateSchedule event, Emitter<PlannerState> emit)
Future<void> _onRefreshSchedule(RefreshSchedule event, Emitter<PlannerState> emit)
```

### SessionTimerCubit (features/planner/presentation/bloc/session_timer/)

```dart
void startTimer(int durationMinutes)
void pauseTimer()
void resumeTimer()
void skipBreak()
void completeSession()
void _tick()
```

### ExamBloc (features/planner/presentation/bloc/exam/)

#### Events:
```dart
class LoadUserExams extends ExamEvent
class CreateExam extends ExamEvent { final ExamCreate exam; }
class UpdateExam extends ExamEvent { final int id; final ExamUpdate data; }
class DeleteExam extends ExamEvent { final int id; }
```

#### States:
```dart
class ExamInitial extends ExamState
class ExamLoading extends ExamState
class ExamLoaded extends ExamState { final List<Exam> exams; }
class ExamCreated extends ExamState { final Exam exam; }
class ExamError extends ExamState { final String message; }
```

### Planner Widgets (features/planner/presentation/widgets/)

```dart
// selectable_subject_card.dart
Widget build(BuildContext context)
Color _getCoefficientColor(int coefficient)

// subject_group_header.dart
Widget build(BuildContext context)

// priority_selector.dart
Widget build(BuildContext context)
void _onPriorityChanged(Priority? priority)

// difficulty_star_rating.dart
Widget build(BuildContext context)
void _onStarTapped(int level)

// session_timeline_item.dart
Widget build(BuildContext context)
void _onActionTapped(SessionAction action)

// week_calendar.dart
Widget build(BuildContext context)
Widget _buildDayCell(DateTime date)
List<PlannerSession> _getSessionsForDate(DateTime date)

// pomodoro_timer.dart
Widget build(BuildContext context)
Widget _buildCircularProgress()
String _formatTime(Duration duration)

// prayer_times_card.dart
Widget build(BuildContext context)
Widget _buildPrayerTimeRow(String prayer, String time)

// session_card.dart
Widget build(BuildContext context)
Color _getStatusColor(SessionStatus status)
IconData _getStatusIcon(SessionStatus status)
```

### New Planner Use Cases (24/11/2025)

```dart
// pause_session.dart
class PauseSession implements UseCase<Unit, String>
Future<Either<Failure, Unit>> call(String sessionId)

// resume_session.dart
class ResumeSession implements UseCase<Unit, String>
Future<Either<Failure, Unit>> call(String sessionId)

// get_week_sessions.dart
class GetWeekSessions implements UseCase<List<StudySession>, GetWeekSessionsParams>
Future<Either<Failure, List<StudySession>>> call(GetWeekSessionsParams params)

class GetWeekSessionsParams {
  final DateTime startDate;
}
```

### SubjectsPage - Modern Design (features/planner/presentation/pages/subjects_page.dart)

```dart
// SubjectsPage (StatelessWidget)
Widget build(BuildContext context)

// _SubjectsPageContent (StatelessWidget) - Main content with modern UI
Widget build(BuildContext context)
void _showSnackBar(BuildContext context, String message, {required bool isError})

// Modern App Bar
Widget _buildModernAppBar(BuildContext context)           // Floating buttons with shadows
Widget _buildAppBarButton({IconData icon, VoidCallback onPressed})

// Page Header with Stats
Widget _buildPageHeader(BuildContext context)             // Blue gradient header card
Widget _buildHeaderStat({IconData icon, String label, String value})

// Empty State
Widget _buildModernEmptyState(BuildContext context)       // Modern empty state with gradient button

// Subjects Grid
Widget _buildSubjectsGrid(BuildContext context, List<Subject> subjects)
Widget _buildModernSubjectCard(BuildContext context, Subject subject)  // Gradient cards with shadows

// Bottom Sheets & Dialogs
void _showSubjectOptions(BuildContext context, Subject subject)  // Options bottom sheet
Widget _buildOptionTile({IconData icon, String label, Color color, VoidCallback onTap})
void _showAddSubjectDialog(BuildContext context)
void _showEditSubjectDialog(BuildContext context, Subject subject)
void _showSubjectDetails(BuildContext context, Subject subject)  // Details bottom sheet
Widget _buildDetailStatCard({IconData icon, String label, String value, Color color})
Widget _buildActionButton({IconData icon, String label, Color color, VoidCallback onPressed})
void _showDeleteConfirmation(BuildContext context, Subject subject)
```

### Modern Subject Form Dialog (_ModernSubjectFormDialog)

```dart
// _ModernSubjectFormDialog (StatefulWidget)
State<_ModernSubjectFormDialog> createState()

// _ModernSubjectFormDialogState
void initState()
void dispose()
Widget build(BuildContext context)
Widget _buildTextField({
  TextEditingController controller,
  String label,
  String hint,
  IconData icon,
  TextInputType keyboardType,
  String? Function(String?)? validator,
})
void _handleSubmit()

// Form Controllers
TextEditingController _nameArController
TextEditingController _nameEnController
TextEditingController _coefficientController
TextEditingController _difficultyController

// Form State
String _selectedIcon
Color _selectedColor
List<Map<String, dynamic>> _availableIcons   // Updated with 8 icons
List<Color> _availableColors                  // Modern color palette (10 colors)
```

### Updated PlannerBloc Methods

```dart
// planner_bloc.dart
Future<void> _onPauseSession(PauseSessionEvent event, Emitter<PlannerState> emit)
Future<void> _onResumeSession(ResumeSessionEvent event, Emitter<PlannerState> emit)
Future<void> _onLoadWeekSchedule(LoadWeekScheduleEvent event, Emitter<PlannerState> emit)
```

### New PlannerState

```dart
// planner_state.dart
class WeekScheduleLoaded extends PlannerState {
  final List<StudySession> sessions;
  final DateTime weekStart;
  final String? message;
}
```

### PlannerDesignConstants (features/planner/presentation/widgets/shared/planner_design_constants.dart) - NEW 30/11/2025

```dart
// Design System Constants - Modern UI matching session_detail_screen.dart
class PlannerDesignConstants {
  // Background colors
  static const Color slateBackground = Color(0xFFF8FAFC)
  static const Color cardBackground = Color(0xFFFFFFFF)

  // Card styling
  static const double cardRadius = 20.0
  static BoxDecoration modernCardDecoration({Color? color, double? borderRadius})
  static BoxDecoration iconContainerDecoration(Color color)

  // Subject colors
  static const Map<String, Color> subjectColors = {...}
  static Color getSubjectColor(String subjectName)

  // Status colors
  static const Map<SessionStatus, Color> statusColors = {...}
  static Color getStatusColor(SessionStatus status)

  // Priority colors
  static const Map<int, Color> priorityColors = {...}
  static Color getPriorityColor(int priority)

  // Gradient helpers
  static LinearGradient subjectGradient(Color color)
}
```

### Updated Planner Screens - Modern Design (30/11/2025)

```dart
// today_view_screen.dart - Modern stat cards, date header, timeline integration
// full_schedule_screen.dart - Modern date badges, session count badges
// analytics_dashboard_screen.dart - Modern metric cards, chart containers
// planner_settings_screen.dart - Modern section headers with icons, switch tiles
// session_history_screen.dart - Modern calendar heatmap, session cards

// Common patterns used:
- PlannerDesignConstants.slateBackground for screen background
- PlannerDesignConstants.modernCardDecoration() for cards
- PlannerDesignConstants.iconContainerDecoration(color) for icon containers
- Gradient icon containers (50x50 with LinearGradient)
- Status badges with rounded corners (20px)
- Cairo font family for Arabic text
```

---

## Courses Feature Functions (NEW - 30/11/2025)

### Modern UI Widgets

#### ModernCourseListCard (features/courses/presentation/widgets/modern_course_list_card.dart) - NEW 02/12/2025

```dart
// ModernCourseListCard (StatelessWidget) - Modern card with image cover
Widget build(BuildContext context)
Widget _buildImageSection()                           // Image with gradient overlay or default icon
Widget _buildDefaultIcon(List<Color> gradientColors)  // Fallback icon with decorations
Widget _buildCategoryBadge()                          // Subject category badge
Widget _buildFeaturedBadge()                          // Featured course badge
Widget _buildStatsRow()                               // Rating, duration, price
Widget _buildPriceBadge()                             // Price/free badge
Widget _buildProgressBar()                            // Optional progress bar
String _formatDuration(int minutes)                   // Format duration text
Color _getCategoryColor(String subject)               // Category color mapping
List<Color> _getGradientColors(String subject)        // Subject gradient colors
IconData _getSubjectIcon(String subject)              // Subject icon mapping

// Properties
final CourseEntity course
final VoidCallback onTap
final bool showProgress                               // Show progress bar (default: false)
final double? progress                                // Progress value 0.0-1.0
```

#### ModernCourseProgressCard (features/courses/presentation/widgets/modern/modern_course_progress_card.dart)

```dart
// ModernCourseProgressCard (StatelessWidget)
Widget build(BuildContext context)

// Properties
final CourseProgressEntity progress
final VoidCallback? onContinue
```

#### ModernRatingSummary (features/courses/presentation/widgets/modern/modern_rating_summary.dart)

```dart
// ModernRatingSummary (StatelessWidget)
Widget build(BuildContext context)
Widget _buildStarsRow(double rating)
Widget _buildRatingBar(int stars, int count)

// CompactRatingDisplay (StatelessWidget) - Compact variant for headers
Widget build(BuildContext context)

// Properties
final double averageRating
final int totalReviews
final Map<int, int> ratingDistribution
```

#### ModernReviewCard (features/courses/presentation/widgets/modern/modern_review_card.dart)

```dart
// ModernReviewCard (StatelessWidget)
Widget build(BuildContext context)
Widget _buildAvatarPlaceholder()
Widget _buildActionButton({IconData icon, String label, VoidCallback onTap, Color color})
Color _getRatingColor(int rating)

// EmptyReviewsState (StatelessWidget)
Widget build(BuildContext context)

// Properties
final CourseReviewEntity review
final VoidCallback? onHelpful
final VoidCallback? onReport
```

#### ModernReviewForm (features/courses/presentation/widgets/modern/modern_review_form.dart)

```dart
// ModernReviewForm (StatefulWidget)
State<ModernReviewForm> createState()

// _ModernReviewFormState
void dispose()
void _handleSubmit()
Widget build(BuildContext context)
Widget _buildStarSelector()
Color _getRatingColor(int rating)
String _getRatingText(int rating)

// Helper function
void showReviewFormBottomSheet({BuildContext context, Function(int, String) onSubmit})
```

### CourseDetailPage (features/courses/presentation/pages/course_detail_page.dart)

```dart
// CourseDetailPage (StatefulWidget) - Redesigned Modern UI with Subscription Integration
State<CourseDetailPage> createState()

// _CourseDetailPageState
void initState()
void _loadData()
void dispose()
Color get _subjectColor
IconData get _subjectIcon
Widget build(BuildContext context)
Widget _buildBody()
Widget _buildModernSliverAppBar()
Widget _buildModernTabBar()
Widget _buildOverviewTab()
Widget _buildSectionCard({IconData icon, String title, Color iconColor, Widget child})
Widget _buildCheckItem(String text)
Widget _buildFeatureItem(IconData icon, String text, Color color)
Widget _buildCurriculumTab()
Widget _buildReviewsTab()
Widget _buildBottomBar()                         // Bottom action bar
Widget _buildContinueButton()                    // "الوصول إلى المحتوى" button (for subscribed users)
Widget _buildEnrollButtons()                     // "اشترك الآن" button (for non-subscribed users)
void _showPaymentOptions()                       // NEW: Show payment options bottom sheet
void _navigateToCourseModules()                  // NEW: Navigate to course modules after subscription
Map<int, int> _calculateRatingDistribution()
Widget _buildBottomActionBar()
Widget _buildEnrolledActions()
Widget _buildEnrollActions()
Widget _buildLoadingSkeleton()
Widget _buildErrorState(String message)
void _showEnrollDialog()
void _showPaymentOptionsDialog()
Widget _buildPaymentOption({IconData icon, String title, String subtitle, Color color, VoidCallback onTap})
void _showSubscriptionCodeDialog()
void _showPaymentMethodDialog()
Widget _buildPaymentMethodOption({IconData icon, String title, String subtitle, Color color, String method})

// State Variables
late TabController _tabController
CourseEntity? _course
List<CourseModuleEntity>? _modules
CourseProgressEntity? _progress
List<CourseReviewEntity>? _reviews
bool _hasAccess
bool _canReview
String? _errorMessage
bool _isLoading
```

### LessonDetailPage (features/courses/presentation/pages/lesson_detail_page.dart) - NEW

```dart
// LessonDetailPage (StatefulWidget) - Lesson content with video, attachments, quiz
State<LessonDetailPage> createState()

// _LessonDetailPageState
void initState()
void _loadData()
void _extractAllLessons()                              // Extract all lessons for navigation
Widget build(BuildContext context)
Widget _buildBody()
Widget _buildAppBar()                                  // Purple app bar with title, bookmark
Widget _buildVideoSection()                            // Video player section with play button
Widget _buildLessonInfo()                              // Lesson title, description, stats
Widget _buildStatChip(IconData icon, String text)      // Small stat chip
Widget _buildAttachmentsSection()                      // Attachments list section
Widget _buildQuizSection()                             // Quiz section if hasQuiz
Widget _buildNavigationSection()                       // Previous/Next lesson navigation
Widget _buildNavButton({IconData icon, String label, bool enabled, VoidCallback? onTap, bool isPrimary, bool iconOnRight})
Widget _buildLoadingState()
Widget _buildErrorState(String message)

// Actions
void _openVideoPlayer()                                // Navigate to video player
void _previewAttachment(LessonAttachmentEntity attachment)   // Preview PDF or image
void _downloadAttachment(LessonAttachmentEntity attachment)  // Download file
void _showImageViewer(LessonAttachmentEntity attachment)     // Full screen image viewer
void _startQuiz()                                      // Start lesson quiz
void _goToPreviousLesson()                             // Navigate to previous lesson
void _goToNextLesson()                                 // Navigate to next lesson

// State Variables
CourseLessonEntity? _lesson
List<CourseModuleEntity>? _modules
bool _isLoading
String? _errorMessage
List<CourseLessonEntity> _allLessons                   // All lessons in course
int _currentLessonIndex                                // Current position in playlist

// Properties
final int courseId
final int lessonId
```

### PdfViewerPage (features/courses/presentation/pages/pdf_viewer_page.dart) - NEW

```dart
// PdfViewerPage (StatefulWidget) - PDF attachment viewer
State<PdfViewerPage> createState()

// _PdfViewerPageState
void initState()
Future<void> _downloadAndOpenPdf()                     // Download PDF from URL
Widget build(BuildContext context)
PreferredSizeWidget _buildAppBar()                     // App bar with share, download buttons
Widget _buildBody()                                    // PDF view using flutter_pdfview
Widget _buildBottomBar()                               // Page navigation bar
Widget _buildPageNavButton({IconData icon, VoidCallback? onTap})
Widget _buildLoadingState()                            // Loading with progress
Widget _buildErrorState()                              // Error with retry

// Actions
void _goToPreviousPage()
void _goToNextPage()
Future<void> _sharePdf()                               // Share PDF file
Future<void> _downloadPdf()                            // Save PDF to documents

// State Variables
String? _localPath                                     // Local file path
bool _isLoading
String? _errorMessage
int _currentPage
int _totalPages
PDFViewController? _pdfController

// Properties
final LessonAttachmentEntity attachment
```

### AttachmentCard (features/courses/presentation/widgets/attachment_card.dart) - NEW

```dart
// AttachmentCard (StatelessWidget) - Single attachment display
Widget build(BuildContext context)
Widget _buildFileIcon()                                // Icon based on file type
Color _getFileColor()                                  // Color based on file type
bool _canPreview()                                     // Check if file can be previewed
Widget _buildActionButton({IconData icon, VoidCallback? onTap, String tooltip, bool isPrimary})

// Properties
final LessonAttachmentEntity attachment
final VoidCallback? onPreview
final VoidCallback? onDownload

// AttachmentsList (StatelessWidget) - List of attachments
Widget build(BuildContext context)

// Properties
final List<LessonAttachmentEntity> attachments
final Function(LessonAttachmentEntity)? onPreview
final Function(LessonAttachmentEntity)? onDownload
```

### PaymentOptionsBottomSheet (features/courses/presentation/widgets/payment_options_bottom_sheet.dart) - NEW (2025-12-17)

```dart
// PaymentOptionsBottomSheet (StatelessWidget) - Payment method selection bottom sheet
static Future<void> show(BuildContext context, {int courseId, VoidCallback? onCodeRedeemed})  // Show bottom sheet
Widget build(BuildContext context)
Widget _buildPaymentOption({IconData icon, Gradient iconGradient, String title, String description, VoidCallback onTap})
void _handleCodeOption(BuildContext context)         // Open subscription code dialog
void _handleBaridiMobOption(BuildContext context)   // Navigate to payment receipt page (Baridi Mob)
void _handleCCPOption(BuildContext context)          // Navigate to payment receipt page (CCP)

// Properties
final int courseId
final VoidCallback? onCodeRedeemed
```

### SubscriptionCodeDialog (features/courses/presentation/widgets/subscription_code_dialog.dart) - UPDATED (2025-12-17)

```dart
// SubscriptionCodeDialog (StatefulWidget) - Glassmorphic subscription code validation & redemption
static Future<void> show(BuildContext context, {int? courseId, VoidCallback? onSuccess})  // UPDATED: Added optional parameters
State<SubscriptionCodeDialog> createState()

// _SubscriptionCodeDialogState
void initState()
void dispose()
void _onCodeComplete(String code)
void _validateCode(String code)
void _redeemCode()
Widget build(BuildContext context)
Widget _buildAnimatedBackground()
Widget _buildHandle()
Widget _buildPremiumHeader()
Widget _buildCodeSection()
Widget _buildValidationSuccess()
Widget _buildInfoCards(SubscriptionCodeValidationResult result)
Widget _buildInfoCard({IconData icon, String label, String value, List<Color> gradient})
Widget _buildValidateButton()
Widget _buildRedeemButton()
Widget _buildCancelButton()
void _showSuccessSnackBar(String message)
void _showErrorSnackBar(String message)
String _formatDuration(int days)

// Properties (UPDATED)
final SubscriptionBloc subscriptionBloc
final int? courseId                    // NEW: Optional course ID
final VoidCallback? onSuccess           // NEW: Success callback

// State Variables
TextEditingController _codeController
GlobalKey<ModernCodeInputState> _codeInputKey
bool _isValidating
bool _isRedeeming
SubscriptionCodeValidationResult? _validatedCodeData
AnimationController _backgroundController
AnimationController _successController
AnimationController _slideController
```

---

## Profile Feature ✅ PHASES 1 & 2 COMPLETE (2025-12-03)

### Phase 1: Security & GDPR Compliance

#### PasswordValidator (lib/core/utils/password_validator.dart) - Static utility class
```dart
static int calculateStrength(String password)                           // Returns 0-4 strength level
static Map<String, bool> getRequirements(String password)              // Returns map of requirement checks
static bool hasUppercase(String value)                                 // Check uppercase letter
static bool hasLowercase(String value)                                 // Check lowercase letter
static bool hasDigit(String value)                                     // Check digit
static bool hasSpecialChar(String value)                               // Check special character
static String getStrengthLabel(int strength)                           // Get Arabic label (ضعيف جداً → قوي جداً)
static int getStrengthColor(int strength)                              // Get color code for strength
static String? validatePassword(String? value)                         // Form validator
static String? validatePasswordConfirmation(String? password, String? confirmation)  // Confirm validator
```

#### ImageHelper (lib/core/utils/image_helper.dart) - Static utility class
```dart
static Future<File?> pickImageFromCamera()                             // Pick from camera with permissions
static Future<File?> pickImageFromGallery()                            // Pick from gallery with permissions
static Future<File?> cropImage(File source, {BuildContext? context})   // Crop to 1:1 aspect ratio
static Future<File> compressImage(File source, {int maxSizeKB = 2048}) // Compress to < 2MB
static Future<File?> pickAndCropImage(BuildContext context, {required ImageSource source, int maxSizeKB = 2048})  // Complete flow
static Future<ImageSource?> showImageSourceSelector(BuildContext context)  // Bottom sheet selector
static Future<String?> validateImage(File file, {int maxSizeKB = 2048})   // Validate file
static Future<Directory> getCacheDirectory()                           // Get temp directory
static Future<void> clearCache()                                       // Clear image cache
```

#### PasswordStrengthIndicator (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Build animated strength indicator

// Properties
final String password
final double height
final double borderRadius
final bool showLabel
```

#### PasswordRequirementsChecklist (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Build requirements checklist
Widget _buildRequirementItem({required bool isMet, required String label, bool isRecommended = false})

// Properties
final String password
final bool compact
```

#### DeleteAccountWarning (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Build warning card
Widget _buildDataItem({required IconData icon, required String label}) // Build data item

// Properties
final String? customMessage
final bool showDataList
```

#### CompactDeleteAccountWarning (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Compact version without data list

// Properties
final String? message
```

#### DeleteAccountUseCase
```dart
Future<Either<Failure, void>> call(DeleteAccountParams params)         // Execute deletion
String? _validateConfirmation(String confirmation)                     // Validate confirmation text

// Properties
final ProfileRepository repository
```

#### DeleteAccountParams
```dart
Map<String, dynamic> toJson()                                          // Convert to JSON

// Properties
final String confirmation
final String? reason
final String? additionalFeedback
static const List<String> predefinedReasons                            // 5 predefined reasons
```

#### DeleteAccountPage (StatefulWidget) - Complete GDPR-compliant deletion flow
```dart
Widget build(BuildContext context)                                     // Build page
Widget _buildAppBar()                                                  // Build app bar
Widget _buildExportDataCard()                                          // Optional export before delete
Widget _buildInstructionsCard()                                        // 30-day grace period info
Widget _buildConfirmationTextField()                                   // "حذف" or "delete" input
Widget _buildReasonDropdown()                                          // 5 reasons dropdown
Widget _buildFeedbackTextField()                                       // Optional feedback
Widget _buildDeleteButton()                                            // Red gradient delete button
Widget _buildCancelButton()                                            // Cancel button
Future<void> _handleDeleteAccount()                                    // Handle deletion
Future<bool?> _showFinalConfirmationDialog()                          // Double confirmation
```

### Phase 2: User Engagement & Statistics Dashboard

#### WeeklyStudyChart (StatefulWidget) - 7-day bar chart with fl_chart
```dart
Widget build(BuildContext context)                                     // Build chart column
Widget _buildTitle()                                                   // Build chart title
BarChartData _buildBarChartData()                                      // Build bar chart data
List<BarChartGroupData> _buildBarGroups()                             // Build bar groups
Widget _buildBottomTitles(double value, TitleMeta meta)              // Build day names (abbreviated)
Widget _buildLeftTitles(double value, TitleMeta meta)                // Build hours axis
Widget _buildSummaryStats()                                           // Build summary (total, avg, max)
Widget _buildStatItem({required String label, required String value, required String unit, required IconData icon})
Widget _buildVerticalDivider()                                        // Build divider
Widget _buildEmptyState()                                             // Build empty state

// Properties
final Map<String, double> weeklyData                                  // Day name → hours
final double maxHours
final double height
final bool showSummary

// State
int _touchedIndex                                                     // Currently touched bar
```

#### CompactWeeklyStudyChart (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Compact version without summary

// Properties
final Map<String, double> weeklyData
final double maxHours
```

#### AchievementModel (Data class)
```dart
int get progressPercentage                                             // Calculate 0-100%
bool get isPartiallyCompleted                                          // Check if in progress

// Properties
final String id
final String title
final String description
final String icon
final bool isUnlocked
final DateTime? unlockedAt
final int? progress
final int? goal
final String? category
```

#### AchievementBadge (StatelessWidget) - Single achievement badge
```dart
Widget build(BuildContext context)                                     // Build badge container
Widget _buildBadgeIcon()                                               // Build icon with lock overlay
Widget _buildProgressIndicator()                                       // Build progress bar (partial)
Widget _buildUnlockDate()                                              // Build unlock date label

// Properties
final AchievementModel achievement
final VoidCallback? onTap
final double size
final bool showProgress
```

#### CompactAchievementBadge (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // Icon only, no text

// Properties
final AchievementModel achievement
final VoidCallback? onTap
final double size
```

#### AchievementsGrid (StatelessWidget) - Responsive grid layout
```dart
Widget build(BuildContext context)                                     // Build grid or headers
List<AchievementModel> _sortAchievements(List<AchievementModel> list) // Sort by unlock status + progress
int _getResponsiveColumns(BuildContext context)                       // 2-4 columns responsive
Widget _buildGrid(List<AchievementModel> achievements, int columns)   // Build grid view
Widget _buildWithHeaders(List<AchievementModel> achievements, int columns)  // Build with section headers
Widget _buildSectionHeader({required String title, required int count, required IconData icon})
void _showAchievementDetails(BuildContext context, AchievementModel achievement)  // Show detail dialog
Widget _buildEmptyState()                                              // Empty state

// Properties
final List<AchievementModel> achievements
final int? crossAxisCount
final double spacing
final bool showHeaders
```

#### AchievementDetailsDialog (StatelessWidget) - Detail modal
```dart
Widget build(BuildContext context)                                     // Build dialog
Widget _buildUnlockInfo()                                              // Show unlock date
Widget _buildProgressInfo()                                            // Show progress bar

// Properties
final AchievementModel achievement
```

#### HorizontalAchievementsRow (StatelessWidget) - Horizontal scrollable list
```dart
Widget build(BuildContext context)                                     // Build horizontal list
void _showDetails(BuildContext context, AchievementModel achievement)  // Show details

// Properties
final List<AchievementModel> achievements
final VoidCallback? onSeeAll
```

#### StreakCalendar (StatefulWidget) - Monthly calendar with table_calendar
```dart
Widget build(BuildContext context)                                     // Build calendar + stats
Widget _buildTitle()                                                   // Build title
Widget _buildCalendar()                                                // Build table_calendar widget
Widget? _buildDayMarker(DateTime date)                                // Build ✓/✗/○ marker
Widget _buildLegend()                                                  // Build legend (studied/missed/future)
Widget _buildLegendItem({required IconData icon, required Color color, required String label})
Widget _buildStreakStats()                                             // Build current + longest streak
Widget _buildStreakItem({required IconData icon, required String label, required int value, required String unit})

// Properties
final Map<DateTime, bool> studyDays                                    // Date → studied (true/false)
final int currentStreak
final int longestStreak
final bool showStats
final DateTime? initialFocusedDay

// State
DateTime _focusedDay
DateTime? _selectedDay
```

#### CompactStreakCalendar (StatelessWidget)
```dart
Widget build(BuildContext context)                                     // No stats, smaller size

// Properties
final Map<DateTime, bool> studyDays
```

#### StreakStatsCard (StatelessWidget) - Stats without calendar
```dart
Widget build(BuildContext context)                                     // Build gradient stats card
Widget _buildStatItem({required String label, required int value, required IconData icon})
Widget _buildDivider()                                                 // Build vertical divider

// Properties
final int currentStreak
final int longestStreak
final int totalStudyDays
```

#### StatisticsPage (Updated) - Integrated all Phase 2 widgets
```dart
Widget _buildWeeklyChartSection(List weeklyData)                      // NEW: Uses WeeklyStudyChart
Widget _buildAchievementsSection(List achievements)                   // NEW: Uses AchievementsGrid
Widget _buildStreakCalendarSection(streakCalendar)                    // NEW: Uses StreakCalendar
```

---

## Unified Video Player Feature (NEW - 13/12/2025)

### VideoConfig Entity (features/video_player/domain/entities/video_config.dart)

```dart
class VideoConfig {
  final String videoUrl;          // Video URL (HLS, MP4, YouTube)
  final String title;             // Video title
  final String? subtitle;         // Subject or course name
  final Color accentColor;        // Accent color for UI
  final int? durationSeconds;     // Duration in seconds
  final VideoDifficultyLevel? difficultyLevel;  // easy, medium, hard

  // Progress tracking
  final int? contentId;           // For content_library
  final int? lessonId;            // For courses
  final double initialProgress;   // 0.0 to 1.0
  final bool isCompleted;

  // Playlist support
  final List<VideoConfig>? playlist;
  final int? currentIndex;

  // Callbacks
  final VoidCallback? onCompleted;
  final Function(double)? onProgressUpdate;
  final VoidCallback? onNextVideo;
  final VoidCallback? onPreviousVideo;
}
```

**Computed Properties:**
- `isContentLibrary` - Check if content library video
- `isCourseLesson` - Check if course lesson video
- `hasNext` / `hasPrevious` - Playlist navigation
- `formattedDuration` - Duration as MM:SS or HH:MM:SS
- `difficultyText` - Arabic difficulty label
- `difficultyColor` - Color for difficulty badge

### UnifiedVideoPlayerBloc (features/video_player/presentation/bloc/)

```dart
class UnifiedVideoPlayerBloc extends Bloc<UnifiedVideoPlayerEvent, UnifiedVideoPlayerState>
```

**Events:**
- `InitializeVideoPlayerEvent(config)` - Initialize with VideoConfig
- `PlayVideoPlayerEvent` - Start playback
- `PauseVideoPlayerEvent` - Pause playback
- `SeekVideoPlayerEvent(position)` - Seek to position
- `ChangePlaybackSpeedEvent(speed)` - Change speed
- `ToggleFullscreenEvent(isFullscreen)` - Toggle fullscreen
- `SaveProgressEvent` - Save progress to backend
- `MarkCompletedEvent` - Mark video as completed
- `NextVideoEvent` / `PreviousVideoEvent` - Playlist navigation
- `DisposeVideoPlayerEvent` - Cleanup
- `RetryVideoLoadEvent` - Retry on error

**States:**
- `VideoPlayerInitialState` - Before initialization
- `VideoPlayerLoadingState(message)` - Loading with message
- `VideoPlayerReadyState(...)` - Ready with player, config, progress
- `VideoPlayerErrorState(message, canRetry)` - Error state
- `VideoPlayerCompletedState(config)` - Video completed

**Features:**
- Auto-save progress every 30 seconds
- Auto-completion at 90% watched
- Smart player fallback (YouTube → simple_youtube, others → chewie)
- Supports both content_library and courses

### UnifiedVideoPlayerPage (features/video_player/presentation/pages/)

```dart
class UnifiedVideoPlayerPage extends StatefulWidget {
  final VideoConfig config;
  final bool embedded;           // Embedded mode (no scaffold)
  final PreferredSizeWidget? appBar;  // Custom app bar
}
```

**Design:**
- Uses content_library design (from content_viewer_page.dart)
- Video container with rounded corners and shadow
- Player type indicator badge
- Video info card with progress bar
- Quick actions (fullscreen, seek ±10s)
- Bottom bar (mark complete, next)

### Widget Classes

#### VideoPlayerWidget
```dart
Widget build() -> Container(
  decoration: BoxDecoration(borderRadius: 20, shadow),
  child: AspectRatio(16/9, player.buildPlayer())
)
```

#### VideoInfoCard
```dart
Widget build() -> Container with title, tags, progress bar, description
```

#### VideoQuickActions
```dart
Widget build() -> Row(fullscreen, seekBackward10s, seekForward10s)
```

#### VideoBottomBar
```dart
Widget build() -> Row(markCompleteButton, nextButton)
```

#### VideoLoadingStateWidget
```dart
Widget build() -> Center with spinner, message, "الرجاء الانتظار"
```

#### VideoErrorStateWidget
```dart
Widget build() -> Center with error icon, message, retry button
```

---

## Notes

- Toutes les fonctions async retournent `Future<>`
- Repository methods retournent `Either<Failure, T>` (pattern functional)
- Use cases encapsulent la logique business
- DataSources gèrent la communication API/Cache
- Toutes les entities sont immutables (Equatable)
- Les formulaires utilisent GlobalKey<FormState> pour la validation
- Les dialogs preservent le contexte BLoC via blocContext parameter
