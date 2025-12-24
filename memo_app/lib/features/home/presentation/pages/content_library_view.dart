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
import '../../../content_library/domain/entities/subject_entity.dart';

/// Content Library view - ملخصات و دروس category
/// Modern design with gradient cards and RTL Arabic support
class ContentLibraryView extends StatefulWidget {
  const ContentLibraryView({super.key});

  @override
  State<ContentLibraryView> createState() => _ContentLibraryViewState();
}

class _ContentLibraryViewState extends State<ContentLibraryView> {
  late SubjectsBloc _subjectsBloc;

  @override
  void initState() {
    super.initState();
    // Create repository and bloc
    final dio = sl<Dio>();
    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
    final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);
    _subjectsBloc = SubjectsBloc(repository: repository)..add(LoadSubjects());
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
      child: RefreshIndicator(
        onRefresh: () async {
          _subjectsBloc.add(LoadSubjects());
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header
            SliverToBoxAdapter(child: _buildModernHeader()),

            // Subjects Grid
            SliverToBoxAdapter(child: _buildSubjectsContent()),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
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
                  Icons.menu_book_rounded,
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
                      'ملخصات ودروس',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'اختر المادة للوصول إلى الملخصات والدروس',
                      style: TextStyle(
                        fontFamily: 'Cairo',
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

  Widget _buildSubjectsContent() {
    return BlocBuilder<SubjectsBloc, SubjectsState>(
      builder: (context, state) {
        if (state is SubjectsLoading) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
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
          final subjects = state.subjects;

          if (subjects.isEmpty) {
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
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return _buildSimpleSubjectCard(context, subject);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSimpleSubjectCard(BuildContext context, SubjectEntity subject) {
    final subjectName = subject.nameAr;
    final color = _getSubjectColor(subjectName);
    final icon = _getSubjectIcon(subjectName);

    return GestureDetector(
      onTap: () {
        // Pass subject directly to avoid extra API call
    context.push('/subject/${subject.id}', extra: subject);
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'لا توجد مواد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),

            Text(
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
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
                color: AppColors.red500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.red500,
              ),
            ),
            const SizedBox(height: 24),

            Text(
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
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
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

  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('رياضيات') || name.contains('math')) {
      return AppColors.blue500; // Blue
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return AppColors.violet500; // Purple
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return AppColors.emerald500; // Green
    }
    if (name.contains('علوم') || name.contains('طبيعة') || name.contains('حياة')) {
      return AppColors.cyan500; // Cyan
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return AppColors.emerald500; // Green
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return AppColors.red500; // Red
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return AppColors.orange500; // Orange
    }
    if (name.contains('تاريخ') || name.contains('histoi')) {
      return AppColors.stone500; // Brown
    }
    if (name.contains('جغرافيا') || name.contains('géog')) {
      return AppColors.teal500; // Teal
    }
    if (name.contains('فلسفة') || name.contains('philos')) {
      return AppColors.amber500; // Amber
    }
    if (name.contains('إسلامية') || name.contains('islam')) {
      return AppColors.emerald500; // Emerald
    }

    return AppColors.slate500; // Default slate
  }

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
