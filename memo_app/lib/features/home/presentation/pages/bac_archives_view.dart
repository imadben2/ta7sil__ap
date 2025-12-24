import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../content_library/presentation/bloc/subjects/subjects_bloc.dart';
import '../../../content_library/presentation/bloc/subjects/subjects_event.dart';
import '../../../content_library/presentation/bloc/subjects/subjects_state.dart';
import '../../../content_library/data/datasources/content_library_remote_datasource.dart';
import '../../../content_library/data/repositories/content_library_repository_impl.dart';

/// BAC Archives view - بكالوريات category
/// Shows BAC exam archives and simulation options
class BacArchivesView extends StatefulWidget {
  const BacArchivesView({super.key});

  @override
  State<BacArchivesView> createState() => _BacArchivesViewState();
}

class _BacArchivesViewState extends State<BacArchivesView> {
  late SubjectsBloc _subjectsBloc;

  @override
  void initState() {
    super.initState();
    // Create repository and bloc
    final dio = sl<Dio>();
    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
    final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);
    // For BAC archives, we want all subjects (including those without content library content)
    // because they may have BAC exams even if they don't have regular content
    _subjectsBloc = SubjectsBloc(repository: repository)
      ..add(const LoadSubjects(withContentOnly: false));
  }

  @override
  void dispose() {
    _subjectsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _subjectsBloc,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Browse by Years Button
          SliverToBoxAdapter(child: _buildBrowseYearsButton(context)),

          // Subjects Section
          SliverToBoxAdapter(child: _buildSectionTitle('حسب المادة')),

          // Subjects Grid
          SliverToBoxAdapter(child: _buildSubjectsContent()),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أرشيف البكالوريا',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'امتحانات سابقة مع الحلول',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBrowseYearsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GestureDetector(
        onTap: () {
          context.push('/bac-archives-by-year');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                    const Text(
                      'تصفح حسب السنة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'امتحانات من 2008 إلى 2025',
                      style: TextStyle(
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
    );
  }

  Widget _buildSubjectsContent() {
    return BlocBuilder<SubjectsBloc, SubjectsState>(
      builder: (context, state) {
        if (state is SubjectsLoading) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل المواد...',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SubjectsError) {
          return _buildErrorState(state.message);
        }

        if (state is SubjectsLoaded) {
          if (state.subjects.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: state.subjects.length,
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                return _buildSubjectCard(
                  context,
                  subject: subject,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            // Empty state icon
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'لا توجد مواد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'يرجى التحقق من الاتصال بالإنترنت\nوإعادة المحاولة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Retry button
            GestureDetector(
              onTap: () => _subjectsBloc.add(LoadSubjects()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.red500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.red500,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Retry button
            GestureDetector(
              onTap: () => _subjectsBloc.add(LoadSubjects()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required dynamic subject,
  }) {
    final subjectName = subject.nameAr as String? ?? '';
    final subjectId = subject.id as int? ?? 0;
    final subjectSlug = subject.slug as String? ?? '';
    final color = _getSubjectColor(subjectName);
    final icon = _getSubjectIcon(subjectName);

    return GestureDetector(
      onTap: () {
        context.push(
          '/bac-years-by-subject',
          extra: {
            'subjectId': subjectId,
            'subjectSlug': subjectSlug,
            'subjectName': subjectName,
            'color': color,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              subjectName,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Get subject color based on Arabic name
  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('رياضيات') || name.contains('math')) {
      return const Color(0xFF3B82F6); // Blue
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return const Color(0xFF10B981); // Green
    }
    if (name.contains('علوم') || name.contains('طبيعة') || name.contains('حياة')) {
      return const Color(0xFF06B6D4); // Cyan
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return const Color(0xFF10B981); // Green
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return const Color(0xFFEF4444); // Red
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return const Color(0xFFF97316); // Orange
    }
    if (name.contains('تاريخ') || name.contains('histoi')) {
      return const Color(0xFF78716C); // Brown
    }
    if (name.contains('جغرافيا') || name.contains('géog')) {
      return const Color(0xFF14B8A6); // Teal
    }
    if (name.contains('فلسفة') || name.contains('philos')) {
      return const Color(0xFFF59E0B); // Amber
    }
    if (name.contains('إسلامية') || name.contains('islam')) {
      return const Color(0xFF059669); // Emerald
    }

    return const Color(0xFF64748B); // Default slate
  }

  /// Get subject icon based on Arabic name
  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('رياضيات') || name.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return Icons.science_rounded;
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return Icons.biotech_rounded;
    }
    if (name.contains('علوم') || name.contains('طبيعة') || name.contains('حياة')) {
      return Icons.menu_book_rounded;
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return Icons.text_fields_rounded;
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return Icons.language_rounded;
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return Icons.translate_rounded;
    }
    if (name.contains('تاريخ') || name.contains('histoi')) {
      return Icons.history_edu_rounded;
    }
    if (name.contains('جغرافيا') || name.contains('géog')) {
      return Icons.public_rounded;
    }
    if (name.contains('فلسفة') || name.contains('philos')) {
      return Icons.psychology_rounded;
    }
    if (name.contains('إسلامية') || name.contains('islam')) {
      return Icons.mosque_rounded;
    }

    return Icons.menu_book_rounded;
  }
}
