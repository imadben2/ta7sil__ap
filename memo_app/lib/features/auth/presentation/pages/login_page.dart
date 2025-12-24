import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/constants/app_strings_ar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/services/google_sign_in_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  void _autoFillTestCredentials() {
    setState(() {
      _emailController.text = 'test@memo.com';
      _passwordController.text = 'Test123456!';
      _rememberMe = true;
    });
  }

  void _autoFillStudent2Credentials() {
    setState(() {
      _emailController.text = 'student2@memo.com';
      _passwordController.text = 'Student2024!';
      _rememberMe = true;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    final result = await GoogleSignInService.signIn();

    if (result.isCancelled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Text(AppStringsAr.googleSignInCancelled),
              ],
            ),
            backgroundColor: AppColors.warningYellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDesignTokens.borderRadiusMedium),
            ),
            margin: EdgeInsets.all(AppDesignTokens.spacingMD),
          ),
        );
      }
      return;
    }

    if (!result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.errorMessage ?? AppStringsAr.googleSignInError,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDesignTokens.borderRadiusMedium),
            ),
            margin: EdgeInsets.all(AppDesignTokens.spacingMD),
          ),
        );
      }
      return;
    }

    // Dispatch event to BLoC
    if (mounted) {
      context.read<AuthBloc>().add(
            GoogleLoginRequested(
              idToken: result.idToken!,
              accessToken: result.accessToken,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.borderRadiusMedium,
                  ),
                ),
                margin: EdgeInsets.all(AppDesignTokens.spacingMD),
              ),
            );

            // Show device mismatch dialog if needed
            if (state.isDeviceMismatch) {
              _showDeviceMismatchDialog(context);
            }
          } else if (state is Authenticated) {
            // Navigation handled by router
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text(AppStringsAr.successLogin),
                  ],
                ),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.borderRadiusMedium,
                  ),
                ),
                margin: EdgeInsets.all(AppDesignTokens.spacingMD),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingWidget(message: AppStringsAr.loading);
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.surface,
                  AppColors.primaryDark.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600
                          ? screenWidth * 0.2
                          : AppDesignTokens.spacingLG,
                      vertical: AppDesignTokens.spacingLG,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: AppDesignTokens.spacingXL),

                              // Logo Container with modern design
                              Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDesignTokens.borderRadiusLarge,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingLG),

                              // App Name with modern typography
                              Text(
                                AppStringsAr.appName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppDesignTokens.fontSizeH3,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: -1,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingSM),

                              // Slogan
                              Text(
                                AppStringsAr.appSlogan,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppDesignTokens.fontSizeBody,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingXXL * 2),

                              // Welcome Card
                              Container(
                                padding: EdgeInsets.all(
                                  AppDesignTokens.spacingLG,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDesignTokens.borderRadiusCard,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Welcome Text
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                AppDesignTokens.spacingMD,
                                            vertical: AppDesignTokens.spacingSM,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary.withValues(
                                                  alpha: 0.1,
                                                ),
                                                AppColors.primaryDark
                                                    .withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppDesignTokens.borderRadiusCard,
                                            ),
                                          ),
                                          child: Text(
                                            AppStringsAr.login,
                                            style: TextStyle(
                                              fontSize:
                                                  AppDesignTokens.fontSizeH5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppDesignTokens.spacingLG),

                                    // Test Auto-Fill Buttons (Dev Mode)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.warningYellow
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDesignTokens
                                                        .borderRadiusMedium,
                                                  ),
                                              border: Border.all(
                                                color: AppColors.warningYellow
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: _autoFillTestCredentials,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDesignTokens
                                                          .borderRadiusMedium,
                                                    ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                    AppDesignTokens.spacingSM,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        color: AppColors
                                                            .warningYellow,
                                                        size: 20,
                                                      ),
                                                      SizedBox(
                                                        height: AppDesignTokens
                                                            .spacingXXS,
                                                      ),
                                                      Text(
                                                        'طالب 1',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .warningYellow,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              AppDesignTokens
                                                                  .fontSizeSmall,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: AppDesignTokens
                                                            .spacingXXS,
                                                      ),
                                                      Text(
                                                        'test@memo.com',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .warningYellow
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          fontSize: AppDesignTokens
                                                              .fontSizeCaption,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: AppDesignTokens.spacingSM,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDesignTokens
                                                        .borderRadiusMedium,
                                                  ),
                                              border: Border.all(
                                                color: AppColors.primary
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap:
                                                    _autoFillStudent2Credentials,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDesignTokens
                                                          .borderRadiusMedium,
                                                    ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                    AppDesignTokens.spacingSM,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        color:
                                                            AppColors.primary,
                                                        size: 20,
                                                      ),
                                                      SizedBox(
                                                        height: AppDesignTokens
                                                            .spacingXXS,
                                                      ),
                                                      Text(
                                                        'طالب 2',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              AppDesignTokens
                                                                  .fontSizeSmall,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: AppDesignTokens
                                                            .spacingXXS,
                                                      ),
                                                      Text(
                                                        'student2@memo.com',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .primary
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          fontSize: AppDesignTokens
                                                              .fontSizeCaption,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppDesignTokens.spacingLG),

                                    // Email Field
                                    AppTextField(
                                      controller: _emailController,
                                      label: AppStringsAr.email,
                                      hint: 'example@email.com',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: Validators.validateEmail,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                    SizedBox(height: AppDesignTokens.spacingMD),

                                    // Password Field
                                    AppTextField(
                                      controller: _passwordController,
                                      label: AppStringsAr.password,
                                      hint: '••••••••',
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      validator: Validators.validatePassword,
                                      prefixIcon: const Icon(
                                        Icons.lock_outlined,
                                      ),
                                      onSubmitted: (_) => _handleLogin(),
                                      textDirection: TextDirection.ltr,
                                    ),
                                    SizedBox(height: AppDesignTokens.spacingMD),

                                    // Remember Me & Forgot Password
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Transform.scale(
                                              scale: 1.1,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              AppStringsAr.rememberMe,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'قريباً - Forgot Password',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppDesignTokens
                                                            .borderRadiusMedium,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  AppDesignTokens.spacingMD,
                                              vertical:
                                                  AppDesignTokens.spacingSM,
                                            ),
                                          ),
                                          child: const Text(
                                            AppStringsAr.forgotPassword,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppDesignTokens.spacingLG),

                                    // Login Button with gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primaryDark,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppDesignTokens.borderRadiusCard,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _handleLogin,
                                          borderRadius: BorderRadius.circular(
                                            AppDesignTokens.borderRadiusCard,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical:
                                                  AppDesignTokens.spacingMD + 2,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.login_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  width:
                                                      AppDesignTokens.spacingMD,
                                                ),
                                                Text(
                                                  AppStringsAr.login,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: AppDesignTokens
                                                        .fontSizeBody,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingLG),

                              // "Or" Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color:
                                          AppColors.border.withValues(alpha: 0.5),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppDesignTokens.spacingMD,
                                    ),
                                    child: Text(
                                      AppStringsAr.orDivider,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppDesignTokens.fontSizeSmall,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color:
                                          AppColors.border.withValues(alpha: 0.5),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppDesignTokens.spacingLG),

                              // Google Sign-In Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDesignTokens.borderRadiusCard,
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _handleGoogleSignIn,
                                    borderRadius: BorderRadius.circular(
                                      AppDesignTokens.borderRadiusCard,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppDesignTokens.spacingMD,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Google "G" logo using text (or you can use an image asset)
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'G',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  foreground: Paint()
                                                    ..shader =
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4285F4), // Blue
                                                        Color(0xFF34A853), // Green
                                                        Color(0xFFFBBC05), // Yellow
                                                        Color(0xFFEA4335), // Red
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ).createShader(
                                                      const Rect.fromLTWH(
                                                        0,
                                                        0,
                                                        24,
                                                        24,
                                                      ),
                                                    ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: AppDesignTokens.spacingMD,
                                          ),
                                          Text(
                                            AppStringsAr.loginWithGoogle,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize:
                                                  AppDesignTokens.fontSizeBody,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingXL),

                              // Register Link with modern design
                              Container(
                                padding: EdgeInsets.all(
                                  AppDesignTokens.spacingMD,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDesignTokens.borderRadiusCard,
                                  ),
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStringsAr.dontHaveAccount,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppDesignTokens.fontSizeBody,
                                      ),
                                    ),
                                    SizedBox(width: AppDesignTokens.spacingXXS),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/auth/register');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppDesignTokens.spacingXS,
                                          vertical: AppDesignTokens.spacingXXS,
                                        ),
                                      ),
                                      child: Text(
                                        AppStringsAr.register,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              AppDesignTokens.fontSizeBody,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppDesignTokens.spacingXL),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeviceMismatchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDesignTokens.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.warningYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusMedium,
                ),
              ),
              child: Icon(
                Icons.devices_other_rounded,
                color: AppColors.warningYellow,
                size: 28,
              ),
            ),
            SizedBox(width: AppDesignTokens.spacingMD),
            Expanded(
              child: Text(
                'جهاز مسجل آخر',
                style: TextStyle(fontSize: AppDesignTokens.fontSizeH5),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هذا الحساب مسجل على جهاز آخر.',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingMD),
            Container(
              padding: EdgeInsets.all(AppDesignTokens.spacingMD),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusMedium,
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 حلول متاحة:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDesignTokens.fontSizeBody,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingXS),
                  Text(
                    '1. سجل خروج من الجهاز الآخر',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeSmall,
                      height: 1.4,
                    ),
                  ),
                  Text(
                    '2. اطلب نقل الحساب لهذا الجهاز',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeSmall,
                      height: 1.4,
                    ),
                  ),
                  Text(
                    '3. اتصل بالدعم الفني',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeSmall,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingMD),
            Text(
              'ملاحظة: في وضع التطوير، يمكنك المتابعة مباشرة',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeSmall,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacingLG,
                vertical: AppDesignTokens.spacingSM,
              ),
            ),
            child: Text(
              'إغلاق',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeBody),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);

              // Dev Mode: Continue anyway
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '🔧 وضع التطوير: يتم المتابعة بدون تحقق من الجهاز',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusMedium,
                    ),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: Text(
              'طلب نقل الحساب',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeBody),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacingLG,
                vertical: AppDesignTokens.spacingSM + 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusMedium,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.all(AppDesignTokens.spacingMD),
      ),
    );
  }
}
