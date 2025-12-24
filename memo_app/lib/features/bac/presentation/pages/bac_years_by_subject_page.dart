import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/bac_bloc.dart';
import '../bloc/bac_event.dart';
import '../bloc/bac_state.dart';
import '../../domain/entities/bac_year_entity.dart';

/// Page showing BAC years for a specific subject
/// Flow: Subject selected → Show years → Select year → Show exams for that subject/year
class BacYearsBySubjectPage extends StatefulWidget {
  final int subjectId;
  final String subjectSlug;
  final String subjectName;
  final Color? subjectColor;

  const BacYearsBySubjectPage({
    super.key,
    required this.subjectId,
    required this.subjectSlug,
    required this.subjectName,
    this.subjectColor,
  });

  @override
  State<BacYearsBySubjectPage> createState() => _BacYearsBySubjectPageState();
}

class _BacYearsBySubjectPageState extends State<BacYearsBySubjectPage> {
  @override
  void initState() {
    super.initState();
    // Load BAC years
    context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.subjectColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.subjectName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<BacBloc, BacState>(
        builder: (context, state) {
          if (state is BacLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BacError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is BacYearsLoaded) {
            return _buildYearsList(state.years, color);
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildYearsList(List<BacYearEntity> years, Color color) {
    if (years.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سنوات متاحة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        return _buildYearCard(year, color, index);
      },
    );
  }

  Widget _buildYearCard(BacYearEntity year, Color color, int index) {
    final gradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Navigate to subject detail page with subject info
            await context.push(
              '/bac-subject-exams',
              extra: {
                'subjectId': widget.subjectId,
                'subjectSlug': widget.subjectSlug,
                'subjectName': widget.subjectName,
                'yearSlug': year.slug,
                'yearName': year.year.toString(),
                'color': widget.subjectColor,
              },
            );
            // Reload years when returning
            if (mounted) {
              context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'باكالوريا ${year.year}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'امتحانات ${widget.subjectName}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
