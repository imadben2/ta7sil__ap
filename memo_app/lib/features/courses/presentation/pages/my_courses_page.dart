import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../bloc/subscription/subscription_bloc.dart';
import '../bloc/subscription/subscription_event.dart';
import '../bloc/subscription/subscription_state.dart';
import '../widgets/my_course_card.dart';

/// صفحة دوراتي - تعرض الدورات المشترك فيها المستخدم
class MyCoursesPage extends StatefulWidget {
  final bool showAppBar;

  const MyCoursesPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _bgColor = AppColors.slateBackground;
  static const _cardColor = AppColors.surface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionDataLoaded) {
            final courseSubscriptions = state.subscriptions
                .where((sub) => sub.isSingleCourse && sub.isValid)
                .toList();

            if (state.isLoadingSubscriptions) {
              return _buildLoadingState();
            }

            if (courseSubscriptions.isEmpty) {
              return _buildEmptyState();
            }

            return _buildCoursesList(courseSubscriptions);
          }

          if (state is SubscriptionLoading) {
            return _buildLoadingState();
          }

          if (state is SubscriptionError) {
            return _buildErrorState(state.message);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(0, 0),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري تحميل دوراتك...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(const LoadMySubscriptionsEvent());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverHeader(0, 0),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryPurple.withOpacity(0.1),
                            _secondaryPurple.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 56,
                        color: _primaryPurple.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'لا توجد دورات مشترك فيها',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اشترك في دورة جديدة لبدء رحلة التعلم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryPurple, _secondaryPurple],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPurple.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/courses'),
                        icon: const Icon(Icons.explore_rounded, size: 20),
                        label: const Text(
                          'تصفح الدورات',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(0, 0),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(const LoadMySubscriptionsEvent());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList(List<UserSubscriptionEntity> subscriptions) {
    final activeCourses = subscriptions.where((s) => s.isValid).length;
    final expiringSoon = subscriptions.where((s) => s.remainingDays <= 7 && s.isValid).length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(const LoadMySubscriptionsEvent());
      },
      child: CustomScrollView(
        slivers: [
          _buildSliverHeader(activeCourses, expiringSoon),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_primaryPurple, _secondaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'دوراتي النشطة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$activeCourses دورة',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Courses List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subscription = subscriptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MyCourseCard(
                      subscription: subscription,
                      onTap: () {
                        if (subscription.courseId != null) {
                          context.push('/courses/${subscription.courseId}');
                        }
                      },
                    ),
                  );
                },
                childCount: subscriptions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(int activeCourses, int expiringSoon) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryPurple, _secondaryPurple],
          ),
        ),
        child: Column(
          children: [
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دوراتي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          activeCourses > 0
                            ? '$activeCourses دورة نشطة'
                            : 'لا توجد دورات نشطة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh Button
                  GestureDetector(
                    onTap: () {
                      context.read<SubscriptionBloc>().add(const LoadMySubscriptionsEvent());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.play_circle_rounded,
                    value: activeCourses.toString(),
                    label: 'نشطة',
                    iconBgColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.schedule_rounded,
                    value: expiringSoon.toString(),
                    label: 'تنتهي قريباً',
                    iconBgColor: expiringSoon > 0
                      ? const Color(0xFFF59E0B)
                      : Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Curved bottom
            Container(
              height: 24,
              decoration: const BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconBgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
