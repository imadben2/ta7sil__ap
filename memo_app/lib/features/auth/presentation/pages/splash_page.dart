import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/constants/app_strings_ar.dart';
import '../../../../injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _updateRequired = false;
  bool _versionCheckComplete = false;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _animationController.forward();

    // Check version after animation, then auth
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkVersionAndProceed();
      }
    });
  }

  /// Check app version against server minimum version
  Future<void> _checkVersionAndProceed() async {
    try {
      debugPrint('=== VERSION CHECK START ===');
      debugPrint('App Version: ${ApiConstants.appVersion}');
      debugPrint('API URL: ${ApiConstants.baseUrl}${ApiConstants.versionCheck}');

      final dio = sl<DioClient>();
      final response = await dio.get(ApiConstants.versionCheck);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final minVersion = data['min_version'] as String? ?? '1.0';
        final storeUrls = data['store_url'] as Map<String, dynamic>?;

        debugPrint('Min Version from server: $minVersion');
        debugPrint('Is version lower: ${_isVersionLower(ApiConstants.appVersion, minVersion)}');

        // Compare versions
        if (_isVersionLower(ApiConstants.appVersion, minVersion)) {
          // Update required - redirect to update page
          debugPrint('=== UPDATE REQUIRED - Redirecting ===');
          _updateRequired = true; // Prevent BlocListener from navigating
          if (mounted) {
            String? storeUrl;
            if (Platform.isIOS) {
              storeUrl = storeUrls?['ios'] as String?;
            } else {
              storeUrl = storeUrls?['android'] as String?;
            }
            debugPrint('Store URL: $storeUrl');
            debugPrint('Calling context.go(/update-required)...');
            context.go('/update-required', extra: storeUrl);
          }
          return;
        }
      }

      // Version OK or API error (fail open) - proceed with auth check
      debugPrint('=== VERSION OK - Proceeding to auth ===');
      _versionCheckComplete = true;
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    } catch (e, stackTrace) {
      // On network error, allow app to continue (fail open)
      debugPrint('=== VERSION CHECK FAILED ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      _versionCheckComplete = true;
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    }
  }

  /// Compare version strings (e.g., "1.2" vs "1.3")
  /// Returns true if current is lower than minimum
  bool _isVersionLower(String current, String minimum) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final minParts = minimum.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < minParts.length; i++) {
      final curr = i < currentParts.length ? currentParts[i] : 0;
      final min = minParts[i];
      if (curr < min) return true;
      if (curr > min) return false;
    }
    return false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Don't navigate until version check is complete
          // and don't navigate if update is required
          if (!_versionCheckComplete || _updateRequired) return;

          if (state is Authenticated) {
            // Check if user has academic profile
            final hasAcademicProfile =
                state.user.academicProfile != null &&
                state.user.academicProfile!.phaseId != null;

            if (hasAcademicProfile) {
              context.go('/home');
            } else {
              context.go('/auth/academic-selection');
            }
          } else if (state is Unauthenticated) {
            // Check if first time (show onboarding)
            // For now, go directly to login
            context.go('/auth/login');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary,
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusLarge,
                            ),
                            child: Image.asset(
                              'assets/logo/logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppDesignTokens.spacingLG),

                // App Name
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    AppStringsAr.appName,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeH2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingSM),

                // Slogan
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    AppStringsAr.appSlogan,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBody,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingXXXL),

                // Loading Indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textOnPrimary,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
