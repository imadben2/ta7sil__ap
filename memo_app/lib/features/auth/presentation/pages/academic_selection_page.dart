import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings_ar.dart';
import '../../domain/entities/academic_entities.dart';
import '../bloc/academic_setup_bloc.dart';
import '../bloc/academic_setup_event.dart';
import '../bloc/academic_setup_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Academic Selection Page - Wizard with 3 steps
class AcademicSelectionPage extends StatefulWidget {
  /// Whether this page is opened in edit mode (from profile) vs first-time setup
  final bool isEditMode;

  const AcademicSelectionPage({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<AcademicSelectionPage> createState() => _AcademicSelectionPageState();
}

class _AcademicSelectionPageState extends State<AcademicSelectionPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  AcademicPhase? _selectedPhase;
  AcademicYear? _selectedYear;
  AcademicStream? _selectedStream;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Load phases on init
    context.read<AcademicSetupBloc>().add(const LoadAcademicPhases());
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.infoGradient,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AcademicSetupBloc, AcademicSetupState>(
            listener: (context, state) {
              if (state is AcademicProfileUpdated) {
                // Refresh user data in auth bloc
                context.read<AuthBloc>().add(const AuthCheckRequested());

                if (widget.isEditMode) {
                  // Edit mode: show success message and go to home
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث المرحلة الدراسية بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
                // Always navigate to home
                context.go('/home');
              } else if (state is AcademicSetupError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(),
                  _buildProgressBar(),
                  Expanded(child: _buildContent(state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Back button when in edit mode
          if (widget.isEditMode)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: 'رجوع',
              ),
            ),
          Text(
            widget.isEditMode
                ? 'تغيير المرحلة الدراسية'
                : AppStringsAr.academicSetupTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditMode
                ? 'اختر الطور والسنة والشعبة الجديدة'
                : AppStringsAr.academicSetupSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${AppStringsAr.step} ${_currentStep + 1} ${AppStringsAr.of} 3',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 2 ? 0 : 4,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AcademicSetupState state) {
    if (state is AcademicSetupLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (state is AcademicPhasesLoaded) {
      return _buildPhaseSelection(state.phases);
    }

    if (state is AcademicYearsLoaded) {
      return _buildYearSelection(state.years);
    }

    if (state is AcademicStreamsLoaded) {
      return _buildStreamSelection(state.streams);
    }

    if (state is AcademicSetupError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildPhaseSelection(List<AcademicPhase> phases) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                AppStringsAr.selectYourPhase,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: phases.length,
                  itemBuilder: (context, index) {
                    final phase = phases[index];
                    return _buildAnimatedCard(
                      delay: index * 100,
                      child: _buildPhaseCard(phase),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelection(List<AcademicYear> years) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                AppStringsAr.selectYourYear,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    return _buildAnimatedCard(
                      delay: index * 100,
                      child: _buildYearCard(year),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamSelection(List<AcademicStream> streams) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                AppStringsAr.selectYourStream,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final stream = streams[index];
                    return _buildAnimatedCard(
                      delay: index * 100,
                      child: _buildStreamCard(stream),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildPhaseCard(AcademicPhase phase) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPhase = phase;
          _currentStep = 1;
        });
        _resetAnimations();
        context.read<AcademicSetupBloc>().add(LoadAcademicYears(phase.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      phase.nameAr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearCard(AcademicYear year) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedYear = year;
          _currentStep = 2;
        });
        _resetAnimations();
        context.read<AcademicSetupBloc>().add(LoadAcademicStreams(year.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: year.levelNumber != null
                          ? Text(
                              '${year.levelNumber}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            )
                          : const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      year.nameAr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamCard(AcademicStream stream) {
    final gradientColors = AppColors.getStreamGradient(stream.slug ?? '');

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStream = stream;
        });
        _submitProfile();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0].withOpacity(0.3),
                  gradientColors[1].withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStreamIcon(stream.slug ?? ''),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    stream.nameAr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      height: 1.4,
                    ),
                  ),
                  if (stream.descriptionAr != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      stream.descriptionAr!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AcademicSetupBloc>().add(
                  const LoadAcademicPhases(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStringsAr.retry,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitProfile() {
    if (_selectedPhase != null &&
        _selectedYear != null &&
        _selectedStream != null) {
      context.read<AcademicSetupBloc>().add(
        SubmitAcademicProfile(
          phaseId: _selectedPhase!.id,
          yearId: _selectedYear!.id,
          streamId: _selectedStream!.id,
        ),
      );
    }
  }

  IconData _getStreamIcon(String? slug) {
    switch (slug) {
      case 'math':
      case 'sciences-math':
        return Icons.calculate;
      case 'experimental':
      case 'sciences-exp':
        return Icons.science;
      case 'literature':
      case 'lettres':
        return Icons.menu_book;
      case 'languages':
        return Icons.language;
      case 'law-economy':
        return Icons.gavel;
      default:
        return Icons.school;
    }
  }
}
