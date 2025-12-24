import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/content_library_remote_datasource.dart';
import '../../data/repositories/content_library_repository_impl.dart';
import '../bloc/subjects/subjects_bloc.dart';
import '../bloc/subjects/subjects_event.dart';
import '../bloc/subjects/subjects_state.dart';
import '../bloc/subject_detail/subject_detail_bloc.dart';
import '../bloc/subject_detail/subject_detail_event.dart';
import '../widgets/subject_list_card.dart';
import 'subject_detail_page.dart';

/// Page displaying all subjects in the content library
class SubjectsListPage extends StatefulWidget {
  const SubjectsListPage({super.key});

  @override
  State<SubjectsListPage> createState() => _SubjectsListPageState();
}

class _SubjectsListPageState extends State<SubjectsListPage> {
  @override
  void initState() {
    super.initState();
    // Get user's academic profile and load subjects
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final academicProfile = authState.user.academicProfile;
      context.read<SubjectsBloc>().add(
        LoadSubjects(
          yearId: academicProfile?.yearId,
          streamId: academicProfile?.streamId,
        ),
      );
    } else {
      // Load subjects without academic profile (will likely fail with 400)
      context.read<SubjectsBloc>().add(const LoadSubjects());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDesignTokens.spacingLG,
                AppDesignTokens.spacingXL,
                AppDesignTokens.spacingLG,
                AppDesignTokens.spacingLG,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDesignTokens.spacingLG),
                  Expanded(
                    child: Text(
                      'مكتبة المحتوى',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeH3,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 56), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<SubjectsBloc, SubjectsState>(
                builder: (context, state) {
                  if (state is SubjectsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SubjectsError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is SubjectsLoaded) {
                    return _buildLoadedState(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, SubjectsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        // Get user's academic profile for refresh
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          final academicProfile = authState.user.academicProfile;
          context.read<SubjectsBloc>().add(
            RefreshSubjects(
              yearId: academicProfile?.yearId,
              streamId: academicProfile?.streamId,
            ),
          );
        } else {
          context.read<SubjectsBloc>().add(const RefreshSubjects());
        }
      },
      color: AppColors.primary,
      child: state.subjects.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppDesignTokens.spacingXL,
                AppDesignTokens.spacingSM,
                AppDesignTokens.spacingXL,
                AppDesignTokens.spacingXXL,
              ),
              itemCount: state.subjects.length,
              separatorBuilder: (context, index) => SizedBox(height: AppDesignTokens.spacingLG),
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                return SubjectListCard(
                  subject: subject,
                  onTap: () {
                    // Create repository for SubjectDetailBloc
                    final dio = sl<Dio>();
                    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
                    final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => SubjectDetailBloc(repository: repository)
                            ..add(LoadSubjectContents(subject)),
                          child: SubjectDetailPage(subject: subject),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeH5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingSM),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXXL),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppDesignTokens.fontSizeBody, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingXXL),
          ElevatedButton.icon(
            onPressed: () {
              // Get user's academic profile for retry
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                final academicProfile = authState.user.academicProfile;
                context.read<SubjectsBloc>().add(
                  LoadSubjects(
                    yearId: academicProfile?.yearId,
                    streamId: academicProfile?.streamId,
                  ),
                );
              } else {
                context.read<SubjectsBloc>().add(const LoadSubjects());
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacingXXL,
                vertical: AppDesignTokens.spacingMD,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            'لا توجد مواد',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingSM),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: TextStyle(fontSize: AppDesignTokens.fontSizeBody, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
