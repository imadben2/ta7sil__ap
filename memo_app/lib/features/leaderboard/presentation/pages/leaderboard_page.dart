import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_list_item.dart';
import '../widgets/period_filter_tabs.dart';
import '../widgets/scope_filter_tabs.dart';

/// Full-screen leaderboard page
class LeaderboardPage extends StatefulWidget {
  final int subjectId;
  final String subjectName;
  final String? subjectColor;

  const LeaderboardPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.subjectColor,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  LeaderboardScope _selectedScope = LeaderboardScope.subject;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.all;

  Color get _accentColor {
    if (widget.subjectColor != null && widget.subjectColor!.isNotEmpty) {
      try {
        final colorString = widget.subjectColor!.replaceFirst('#', '');
        return Color(int.parse(colorString, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return AppColors.primary;
  }

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    if (_selectedScope == LeaderboardScope.subject) {
      context.read<LeaderboardBloc>().add(LoadSubjectLeaderboard(
            subjectId: widget.subjectId,
            period: _selectedPeriod,
          ));
    } else {
      context.read<LeaderboardBloc>().add(LoadStreamLeaderboard(
            period: _selectedPeriod,
          ));
    }
  }

  void _onScopeChanged(LeaderboardScope scope) {
    setState(() {
      _selectedScope = scope;
    });
    _loadLeaderboard();
  }

  void _onPeriodChanged(LeaderboardPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1E293B)),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard_rounded, color: _accentColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'الترتيب - ${widget.subjectName}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Scope filter (Subject / Stream)
            ScopeFilterTabs(
              selectedScope: _selectedScope,
              onScopeChanged: _onScopeChanged,
              accentColor: _accentColor,
            ),

            const SizedBox(height: 12),

            // Period filter (Week / Month / All)
            PeriodFilterTabs(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
              accentColor: _accentColor,
            ),

            const SizedBox(height: 16),

            // Leaderboard content
            Expanded(
              child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                builder: (context, state) {
                  if (state is LeaderboardLoading) {
                    return _buildLoadingState();
                  }

                  if (state is LeaderboardError) {
                    return _buildErrorState(state.message);
                  }

                  LeaderboardData? data;
                  if (state is SubjectLeaderboardLoaded) {
                    data = state.data;
                  } else if (state is StreamLeaderboardLoaded) {
                    data = state.data;
                  }

                  if (data == null || data.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildLeaderboardContent(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _accentColor),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الترتيب...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLeaderboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: _accentColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد ترتيب حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أكمل بعض الاختبارات لتظهر في لوحة المتصدرين',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadLeaderboard();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: _accentColor,
      child: CustomScrollView(
        slivers: [
          // Podium (Top 3)
          SliverToBoxAdapter(
            child: LeaderboardPodium(
              podium: data.podium,
              accentColor: _accentColor,
            ),
          ),

          // Rankings header
          SliverToBoxAdapter(
            child: _buildRankingsHeader(data),
          ),

          // Rankings list (4th place and below)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rankings = data.rankingsAfterPodium;
                if (index >= rankings.length) return null;
                return LeaderboardListItem(
                  entry: rankings[index],
                  accentColor: _accentColor,
                );
              },
              childCount: data.rankingsAfterPodium.length,
            ),
          ),

          // Current user (if not in top 50)
          if (data.currentUser.entry != null && !data.currentUser.inList)
            SliverToBoxAdapter(
              child: _buildCurrentUserSection(data.currentUser),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsHeader(LeaderboardData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentColor, _accentColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'قائمة الترتيب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${data.totalParticipants} مشارك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserSection(CurrentUserRank currentUser) {
    if (currentUser.entry == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, color: _accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'ترتيبك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LeaderboardListItem(
            entry: currentUser.entry!,
            accentColor: _accentColor,
          ),
        ],
      ),
    );
  }
}
