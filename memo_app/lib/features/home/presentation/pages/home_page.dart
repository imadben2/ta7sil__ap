import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/widgets/cards/gradient_hero_card.dart';
import '../../../../core/widgets/cards/stat_card_mini.dart';
import '../../../../core/widgets/cards/session_card.dart';
import '../../../../core/widgets/cards/progress_card.dart';
import '../../../../core/widgets/cards/bac_archives_card.dart';
import '../../../../core/widgets/layouts/section_header.dart';
import '../../../../core/widgets/badges/level_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../domain/entities/subject_progress_entity.dart';
import '../../../quiz/presentation/bloc/quiz_list/quiz_list_bloc.dart';
import '../../../quiz/presentation/bloc/quiz_list/quiz_list_state.dart';
import '../../../quiz/presentation/widgets/quiz_card.dart';
import '../../../courses/presentation/bloc/courses/courses_bloc.dart';
import '../../../courses/presentation/bloc/courses/courses_event.dart';
import '../../../courses/presentation/bloc/courses/courses_state.dart';
import '../../../courses/presentation/widgets/featured_courses_carousel_widget.dart';
import '../../domain/entities/sponsor_entity.dart';
import '../widgets/sponsors_carousel_widget.dart';

/// Modern minimalist dashboard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  // Sponsors data - هاد التطبيق برعاية
  // TODO: Replace with API data when backend is ready
  final List<SponsorEntity> _sponsors = const [
    SponsorEntity(
      id: 1,
      nameAr: 'أ. محمد',
      photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      externalLink: 'https://www.youtube.com/@example1',
      title: 'أستاذ الرياضيات',
      specialty: 'الرياضيات',
      order: 1,
    ),
    SponsorEntity(
      id: 2,
      nameAr: 'أ. أحمد',
      photoUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
      externalLink: 'https://www.youtube.com/@example2',
      title: 'أستاذ الفيزياء',
      specialty: 'الفيزياء',
      order: 2,
    ),
    SponsorEntity(
      id: 3,
      nameAr: 'أ. كريم',
      photoUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
      externalLink: 'https://www.facebook.com/example3',
      title: 'أستاذ العلوم',
      specialty: 'العلوم الطبيعية',
      order: 3,
    ),
    SponsorEntity(
      id: 4,
      nameAr: 'أ. سمير',
      photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      externalLink: 'https://www.youtube.com/@example4',
      title: 'أستاذ الفرنسية',
      specialty: 'اللغة الفرنسية',
      order: 4,
    ),
    SponsorEntity(
      id: 5,
      nameAr: 'أ. يوسف',
      photoUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
      externalLink: 'https://www.youtube.com/@example5',
      title: 'أستاذ الفلسفة',
      specialty: 'الفلسفة',
      order: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    context.read<HomeBloc>().add(const DashboardLoadRequested());
    // Load courses data (featured + all in single call)
    context.read<CoursesBloc>().add(const LoadAllCoursesDataEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const DashboardLoadRequested());
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.primary,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              if (homeState is HomeLoading) {
                return _buildLoadingState();
              }

              if (homeState is HomeError && !homeState.hasCachedData) {
                return _buildErrorState(homeState.message);
              }

              return _buildContent(context, homeState);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(const DashboardLoadRequested());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    final data = state is HomeLoaded
        ? state.data
        : state is HomeRefreshing
        ? state.currentData
        : state is HomeSessionUpdating
        ? state.currentData
        : null;

    if (data == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return FadeTransition(
      opacity: _animationController,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverToBoxAdapter(child: _buildAppBar(context)),

          // Test Notifications Section
          SliverToBoxAdapter(child: _buildTestNotificationsSection()),

          // Hero Card
          SliverToBoxAdapter(child: _buildHeroCard(data)),

          // BAC Archives Card
          SliverToBoxAdapter(child: _buildBacArchivesCard(context)),

          // Sponsors Section - هاد التطبيق برعاية
          SliverToBoxAdapter(child: _buildSponsorsSection()),

          // Stats Row
          SliverToBoxAdapter(child: _buildStatsRow(data)),

          // Sessions Title
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'جلسات اليوم',
              showAll: data.todaySessions.isNotEmpty,
            ),
          ),

          // Today's Sessions
          SliverToBoxAdapter(child: _buildSessionsList(data)),

          // Subjects Title
          SliverToBoxAdapter(child: _buildSectionTitle('موادك الدراسية')),

          // Subjects Grid
          SliverToBoxAdapter(child: _buildSubjectsGrid(data)),

          // View All Subjects Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: OutlinedButton(
                onPressed: () {
                  context.push('/subjects-list');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'عرض جميع المواد',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Featured Courses Title
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'الدورات المدفوعة',
              showAll: true,
              onTapAll: () {
                context.push('/courses');
              },
            ),
          ),

          // Featured Courses List
          SliverToBoxAdapter(child: _buildFeaturedCourses()),

          // Recommended Quizzes Title
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'اختبارات موصى بها',
              showAll: true,
              onTapAll: () {
                context.push('/quiz');
              },
            ),
          ),

          // Recommended Quizzes List
          SliverToBoxAdapter(child: _buildRecommendedQuizzes()),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is Authenticated
            ? state.user.firstName
            : 'الطالب';
        final userAvatar = state is Authenticated ? state.user.avatar : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: userAvatar != null
                    ? NetworkImage(userAvatar)
                    : null,
                child: userAvatar == null
                    ? Icon(Icons.person, color: AppColors.primary, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك 👋',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/user-manual'),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'دليل',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDesignTokens.screenPaddingHorizontal),
      child: GradientHeroCard(
        gradient: GradientHelper.primaryHero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مجموع النقاط',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeBodySmall,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.stats.totalPoints}',
                      style: const TextStyle(
                        fontSize: AppDesignTokens.fontSizeDisplay,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                LevelBadge(
                  level: data.stats.level,
                  style: LevelBadgeStyle.solid,
                  color: Colors.white.withOpacity(0.25),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم للمستوى التالي',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeLabel,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    Text(
                      '${(data.stats.levelProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: AppDesignTokens.fontSizeLabel,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusTiny),
                  child: LinearProgressIndicator(
                    value: data.stats.levelProgress,
                    backgroundColor: AppColors.overlayWhite20,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: AppDesignTokens.progressBarMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBacArchivesCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: BacArchivesCardHorizontal(
        year: '2024',
        title: 'أرشيف الباكالوريا',
        subtitle: 'امتحانات سابقة ومحاكاة',
        icon: Icons.school,
        gradient: GradientHelper.primary,
        onTap: () {
          context.push('/bac-archives-by-year');
        },
      ),
    );
  }

  Widget _buildStatsRow(data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: StatCardMiniHorizontal(
              icon: Icons.local_fire_department,
              iconColor: AppColors.fireRed,
              value: '${data.stats.streak}',
              label: 'يوم متتالي',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardMiniHorizontal(
              icon: Icons.timer_outlined,
              iconColor: AppColors.successGreen,
              value: data.stats.formattedStudyTime,
              label: 'وقت الدراسة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    bool showAll = false,
    VoidCallback? onTapAll,
  }) {
    return SectionHeader(
      title: title,
      onViewAll: showAll ? onTapAll : null,
      viewAllText: 'عرض الكل',
    );
  }

  Widget _buildSessionsList(data) {
    if (data.todaySessions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 28,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد جلسات مجدولة اليوم',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: data.todaySessions.take(3).map<Widget>((session) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SessionCard(
              subjectIcon: Icons.book_rounded,
              subjectGradient: GradientHelper.primary,
              subjectName: session.subjectName,
              sessionTitle: session.typeLabel,
              time: DateFormat('HH:mm').format(session.startTime),
              onTap: () {
                // Navigate to session detail
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectsGrid(data) {
    // Sort subjects by coefficient (descending) and take top 4
    final sortedSubjects = List<SubjectProgressEntity>.from(
      data.subjectsProgress,
    )..sort((a, b) => b.coefficient.compareTo(a.coefficient));

    final topSubjects = sortedSubjects.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: topSubjects.length,
        itemBuilder: (context, index) {
          final subject = topSubjects[index];
          final color = _parseColor(subject.color);

          return ProgressCard(
            icon: subject.iconEmoji != null ? Icons.star : Icons.book_rounded,
            iconColor: color,
            title: subject.nameAr,
            subtitle: subject.coefficientLabel,
            progress: subject.completionPercentage,
            progressLabel: subject.completionLabel,
            onTap: () {
              context.push('/subject/${subject.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendedQuizzes() {
    return BlocBuilder<QuizListBloc, QuizListState>(
      builder: (context, state) {
        if (state is QuizListLoading) {
          return Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is QuizListError) {
          return Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Text(
                'فشل تحميل الاختبارات',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          );
        }

        if (state is QuizListLoaded) {
          final quizzes = state.quizzes.take(3).toList();

          if (quizzes.isEmpty) {
            return Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Text(
                  'لا توجد اختبارات موصى بها حالياً',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            );
          }

          return Container(
            height: 300,
            padding: const EdgeInsets.only(right: 24),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Container(
                  width: 320,
                  margin: EdgeInsets.only(left: 16, bottom: 8),
                  child: QuizCard(
                    quiz: quiz,
                    onTap: () {
                      context.push('/quiz/${quiz.id}');
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeaturedCourses() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is FeaturedCoursesLoaded) {
          if (state.courses.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد دورات متاحة حالياً',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            );
          }

          // Use improved carousel with auto-play and indicators
          return FeaturedCoursesCarouselWidget(
            courses: state.courses,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            height: 220,
          );
        }

        if (state is CoursesError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CoursesBloc>().add(
                        const LoadAllCoursesDataEvent(),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Sponsors carousel section - هاد التطبيق برعاية
  Widget _buildSponsorsSection() {
    if (_sponsors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SponsorsCarouselWidget(
        sponsors: _sponsors,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        itemSize: 75,
      ),
    );
  }

  // ===== TEST NOTIFICATIONS SECTION (DEBUG ONLY) =====

  Widget _buildTestNotificationsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange.shade700, size: 22),
              const SizedBox(width: 8),
              Text(
                'اختبار الإشعارات (Debug)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNotificationButton(
                  'تذكير دراسي', NotificationType.studyReminder, Icons.book),
              _buildNotificationButton(
                  'تنبيه امتحان', NotificationType.examAlert, Icons.alarm),
              _buildNotificationButton(
                  'ملخص يومي', NotificationType.dailySummary, Icons.bar_chart),
              _buildNotificationButton(
                  'تحديث دورة', NotificationType.courseUpdate, Icons.school),
              _buildNotificationButton(
                  'إنجاز', NotificationType.achievement, Icons.emoji_events),
              _buildNotificationButton(
                  'نظام', NotificationType.system, Icons.settings),
              _buildNotificationButton(
                  'إعلان', NotificationType.announcement, Icons.campaign),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(
      String label, NotificationType type, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _sendTestNotification(type),
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: _getColorForNotificationType(type),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _sendTestNotification(NotificationType type) async {
    final notificationService = di.sl<NotificationService>();

    // Simple Arabic text without emoji - clean RTL display
    final Map<NotificationType, Map<String, String>> testData = {
      NotificationType.studyReminder: {
        'title': 'تذكير بجلسة الدراسة',
        'body': 'حان وقت جلسة الرياضيات!\nالمدة: 30 دقيقة\nهيا نبدأ التعلم!',
      },
      NotificationType.examAlert: {
        'title': 'تنبيه امتحان قريب!',
        'body': 'امتحان الفيزياء خلال 3 أيام\nراجع الملخصات والدروس\nاستعد جيداً للنجاح!',
      },
      NotificationType.dailySummary: {
        'title': 'ملخص يومك الدراسي',
        'body': 'أكملت 5 جلسات دراسية اليوم\nإجمالي الوقت: 3 ساعات\nواصل التقدم يا بطل!',
      },
      NotificationType.courseUpdate: {
        'title': 'تحديث جديد في الدورة',
        'body': 'درس جديد متاح الآن!\nدورة الرياضيات المتقدمة\nشاهد الدرس الآن',
      },
      NotificationType.achievement: {
        'title': 'مبروك! إنجاز جديد',
        'body': 'حافظت على الاستمرارية 7 أيام!\nحصلت على 50 نقطة إضافية\nاستمر في التألق!',
      },
      NotificationType.system: {
        'title': 'إشعار من النظام',
        'body': 'تم تحديث التطبيق بنجاح\nميزات جديدة متاحة\nاستمتع بالتجربة المحسنة!',
      },
      NotificationType.announcement: {
        'title': 'إعلان هام',
        'body': 'صيانة مجدولة للخوادم\nغداً من 2:00 إلى 4:00 صباحاً\nنعتذر عن أي إزعاج',
      },
    };

    final data = testData[type]!;

    await notificationService.showLocalNotification(
      title: data['title']!,
      body: data['body']!,
      data: {
        'type': NotificationEntity.typeToString(type),
        'test': true,
      },
    );

    // Show snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال إشعار: ${data['title']}'),
          duration: const Duration(seconds: 2),
          backgroundColor: _getColorForNotificationType(type),
        ),
      );
    }
  }

  Color _getColorForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.studyReminder:
        return Colors.blue;
      case NotificationType.examAlert:
        return Colors.red;
      case NotificationType.dailySummary:
        return Colors.green;
      case NotificationType.weeklySummary:
        return Colors.teal;
      case NotificationType.courseUpdate:
        return Colors.purple;
      case NotificationType.achievement:
        return Colors.amber.shade700;
      case NotificationType.system:
        return Colors.grey.shade700;
      case NotificationType.announcement:
        return Colors.orange;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
