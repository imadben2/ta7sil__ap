import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/achievements/achievements_bloc.dart';
import '../bloc/achievements/achievements_event.dart';
import '../bloc/achievements/achievements_state.dart';
import '../widgets/achievement_card.dart';
import '../../domain/entities/achievement.dart';

/// Screen displaying user achievements with gamification
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    // Load achievements when screen opens
    context.read<AchievementsBloc>().add(const LoadAchievementsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'الإنجازات' : 'Achievements'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AchievementsBloc>().add(const RefreshAchievementsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<AchievementsBloc, AchievementsState>(
        builder: (context, state) {
          if (state is AchievementsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? (isRtl ? 'جاري التحميل...' : 'Loading...'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (state is AchievementsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AchievementsBloc>().add(const LoadAchievementsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AchievementsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AchievementsBloc>().add(const RefreshAchievementsEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // Stats Header
                  SliverToBoxAdapter(
                    child: _buildStatsHeader(context, state),
                  ),

                  // Unlocked Achievements Section
                  if (state.unlockedAchievements.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          isRtl ? 'الإنجازات المفتوحة' : 'Unlocked',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final achievement = state.unlockedAchievements[index];
                            return AchievementCard(
                              achievement: achievement,
                              onTap: () => _showAchievementDetail(context, achievement),
                            );
                          },
                          childCount: state.unlockedAchievements.length,
                        ),
                      ),
                    ),
                  ],

                  // Locked Achievements Section
                  if (state.lockedAchievements.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          isRtl ? 'الإنجازات المقفلة' : 'Locked',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final achievement = state.lockedAchievements[index];
                            return AchievementCard(
                              achievement: achievement,
                              onTap: () => _showAchievementDetail(context, achievement),
                            );
                          },
                          childCount: state.lockedAchievements.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, AchievementsLoaded state) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final stats = state.stats;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Achievement Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '${state.response.unlockedCount} / ${state.response.totalCount}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.completionPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? 'اكتمال ${state.completionPercentage.toStringAsFixed(0)}%'
                : '${state.completionPercentage.toStringAsFixed(0)}% Complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                value: '${stats.totalSessions}',
                label: isRtl ? 'جلسات مكتملة' : 'Sessions',
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department,
                value: '${stats.currentStreak}',
                label: isRtl ? 'سلسلة حالية' : 'Streak',
              ),
              _buildStatItem(
                context,
                icon: Icons.star,
                value: '${stats.perfectSessions}',
                label: isRtl ? 'جلسات مثالية' : 'Perfect',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailDialog(achievement: achievement),
    );
  }
}
