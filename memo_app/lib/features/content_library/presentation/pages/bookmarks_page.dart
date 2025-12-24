import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../data/datasources/content_library_remote_datasource.dart';
import '../../data/repositories/content_library_repository_impl.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';
import '../bloc/content_viewer/content_viewer_bloc.dart';
import 'content_viewer_page.dart';
// BAC imports
import '../../../bac/presentation/bloc/bac_bookmark/bac_bookmark_bloc.dart';
import '../../../bac/presentation/bloc/bac_bookmark/bac_bookmark_event.dart';
import '../../../bac/presentation/bloc/bac_bookmark/bac_bookmark_state.dart';
import '../../../bac/domain/entities/bac_subject_entity.dart';
// Profile header widget
import '../../../profile/presentation/widgets/profile_page_header.dart';

/// صفحة العلامات المرجعية
/// تعرض قائمة المحتويات المحفوظة (دروس + امتحانات باكالوريا)
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BacBookmarkBloc _bacBookmarkBloc;
  int _selectedTabIndex = 0;

  // Store the last loaded bookmarks to use when state changes
  List<ContentEntity>? _cachedBookmarks;
  List<BacSubjectEntity>? _cachedBacBookmarks;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _bacBookmarkBloc = sl<BacBookmarkBloc>();

    // Load bookmarks when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkBloc>().add(const LoadBookmarks());
      _bacBookmarkBloc.add(const LoadBacBookmarks());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.slateBackground,
        body: Column(
          children: [
            // الهيدر الموحد
            ProfilePageHeader(
              title: 'العلامات المرجعية',
              subtitle: 'الدروس والامتحانات المحفوظة',
              icon: Icons.bookmark_rounded,
              onBack: () => Navigator.pop(context),
              onAction: () {
                context.read<BookmarkBloc>().add(const RefreshBookmarks());
                _bacBookmarkBloc.add(const RefreshBacBookmarks());
              },
              actionIcon: Icons.refresh_rounded,
            ),
            // المحتوى
            Expanded(
              child: Column(
                children: [
                  _buildModernTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Content Library Bookmarks
                        _buildContentBookmarksTab(),
                        // Tab 2: BAC Bookmarks
                        _buildBacBookmarksTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.menu_book_rounded, 'الدروس'),
          _buildTabItem(1, Icons.school_rounded, 'امتحانات الباكالوريا'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CONTENT LIBRARY BOOKMARKS TAB =====
  Widget _buildContentBookmarksTab() {
    return BlocConsumer<BookmarkBloc, BookmarkState>(
      listener: (context, state) {
        if (state is BookmarkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is BookmarkToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Cache the bookmarks when loaded
        if (state is BookmarksLoaded) {
          _cachedBookmarks = state.bookmarks;
        }

        // Use cached bookmarks for toggling state
        if (state is BookmarkToggling && _cachedBookmarks != null) {
          return _buildContentBookmarksList(context, _cachedBookmarks!);
        }

        if (state is BookmarkLoading) {
          return _buildLoadingState();
        }

        if (state is BookmarksLoaded) {
          if (state.bookmarks.isEmpty) {
            return _buildEmptyState(
              icon: Icons.bookmark_border_rounded,
              message: 'لا توجد دروس محفوظة',
              subtitle: 'قم بحفظ الدروس للوصول إليها لاحقاً',
            );
          }
          return _buildContentBookmarksList(context, state.bookmarks);
        }

        if (state is BookmarkError) {
          return _buildErrorState(state.message, () {
            context.read<BookmarkBloc>().add(const LoadBookmarks());
          });
        }

        return _buildLoadingState();
      },
    );
  }

  // ===== BAC BOOKMARKS TAB =====
  Widget _buildBacBookmarksTab() {
    return BlocConsumer<BacBookmarkBloc, BacBookmarkState>(
      bloc: _bacBookmarkBloc,
      listener: (context, state) {
        if (state is BacBookmarkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is BacBookmarkToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Cache the bookmarks when loaded
        if (state is BacBookmarksLoaded) {
          _cachedBacBookmarks = state.bookmarks;
        }

        // Use cached bookmarks for toggling state
        if (state is BacBookmarkToggling && _cachedBacBookmarks != null) {
          return _buildBacBookmarksList(context, _cachedBacBookmarks!);
        }

        if (state is BacBookmarkLoading) {
          return _buildLoadingState();
        }

        if (state is BacBookmarksLoaded) {
          if (state.bookmarks.isEmpty) {
            return _buildEmptyState(
              icon: Icons.school_outlined,
              message: 'لا توجد امتحانات محفوظة',
              subtitle: 'قم بحفظ الامتحانات للوصول إليها لاحقاً',
            );
          }
          return _buildBacBookmarksList(context, state.bookmarks);
        }

        if (state is BacBookmarkError) {
          return _buildErrorState(state.message, () {
            _bacBookmarkBloc.add(const LoadBacBookmarks());
          });
        }

        return _buildLoadingState();
      },
    );
  }

  // ===== COMMON UI COMPONENTS =====
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CONTENT BOOKMARKS LIST =====
  Widget _buildContentBookmarksList(BuildContext context, List<ContentEntity> bookmarks) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookmarkBloc>().add(const RefreshBookmarks());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(AppDesignTokens.spacingLG),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final content = bookmarks[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppDesignTokens.spacingMD),
            child: _buildContentBookmarkItem(context, content),
          );
        },
      ),
    );
  }

  Widget _buildContentBookmarkItem(BuildContext context, ContentEntity content) {
    final subject = SubjectEntity(
      id: content.subjectId,
      nameAr: 'مادة',
      slug: 'subject-${content.subjectId}',
      color: '#2563EB',
      coefficient: 1,
      academicStreamIds: const [],
      academicYearId: 0,
      order: 0,
      isActive: true,
    );

    final subjectColor = _parseColor('#2563EB');

    return InkWell(
      onTap: () {
        _navigateToContent(context, content, subject, subjectColor);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getContentIcon(content),
                color: subjectColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.titleAr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.nameAr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            _buildDeleteButton(
              onTap: () => _showModernDeleteDialog(
                context: context,
                title: content.titleAr,
                onConfirm: () {
                  context.read<BookmarkBloc>().add(ToggleBookmark(content.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BAC BOOKMARKS LIST =====
  Widget _buildBacBookmarksList(BuildContext context, List<BacSubjectEntity> bookmarks) {
    return RefreshIndicator(
      onRefresh: () async {
        _bacBookmarkBloc.add(const RefreshBacBookmarks());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(AppDesignTokens.spacingLG),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bacSubject = bookmarks[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppDesignTokens.spacingMD),
            child: _buildBacBookmarkItem(context, bacSubject),
          );
        },
      ),
    );
  }

  Widget _buildBacBookmarkItem(BuildContext context, BacSubjectEntity bacSubject) {
    final subjectColor = _parseColor(bacSubject.color);

    return InkWell(
      onTap: () {
        // Navigate to BAC subject detail page with PDF viewer
        debugPrint('🔖 Opening BAC bookmark: id=${bacSubject.id}, nameAr=${bacSubject.nameAr}');
        debugPrint('🔖 fileUrl=${bacSubject.fileUrl}');
        debugPrint('🔖 downloadUrl=${bacSubject.downloadUrl}');
        debugPrint('🔖 correctionUrl=${bacSubject.correctionUrl}');
        context.push('/bac-subject-detail', extra: bacSubject);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: subjectColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bacSubject.nameAr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      // Year info
                      if (bacSubject.bacYear != null)
                        _buildInfoChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'باكالوريا ${bacSubject.bacYear}',
                        ),
                      // Session info
                      if (bacSubject.bacSessionName != null)
                        _buildInfoChip(
                          icon: Icons.event_outlined,
                          label: bacSubject.bacSessionName!,
                        ),
                      // Correction badge
                      if (bacSubject.hasCorrection)
                        _buildInfoChip(
                          icon: Icons.check_circle_outline,
                          label: 'مع الحل',
                          color: AppColors.successGreen,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            _buildDeleteButton(
              onTap: () => _showModernDeleteDialog(
                context: context,
                title: bacSubject.nameAr,
                onConfirm: () {
                  _bacBookmarkBloc.add(ToggleBacBookmark(bacSubject.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey[500];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: chipColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: chipColor,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _showModernDeleteDialog({
    required BuildContext context,
    required String title,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'إزالة العلامة المرجعية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'هل تريد إزالة "$title" من العلامات المرجعية؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إزالة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  void _navigateToContent(
    BuildContext context,
    ContentEntity content,
    SubjectEntity subject,
    Color subjectColor,
  ) async {
    final dio = sl<Dio>();
    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
    final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);

    final bookmarkBloc = context.read<BookmarkBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ContentViewerBloc(repository: repository),
            ),
            BlocProvider.value(
              value: bookmarkBloc,
            ),
          ],
          child: ContentViewerPage(
            content: content,
            subject: subject,
            subjectColor: subjectColor,
          ),
        ),
      ),
    );

    if (mounted) {
      bookmarkBloc.add(const LoadBookmarks());
    }
  }

  IconData _getContentIcon(ContentEntity content) {
    if (content.hasVideo) return Icons.play_circle_outline;
    if (content.hasFile) return Icons.description_outlined;
    return Icons.article_outlined;
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
