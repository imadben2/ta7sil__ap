import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/constants/app_strings_ar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
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
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        ),
      );
    }
  }

  void _autoFillTestCredentials() {
    setState(() {
      _firstNameController.text = 'أحمد';
      _lastNameController.text = 'بن علي';
      _emailController.text = 'ahmed.benali@memo.com';
      _phoneController.text = '0555123456';
      _passwordController.text = 'Ahmed2025!';
      _confirmPasswordController.text = 'Ahmed2025!';
    });
  }

  void _autoFillStudent2Credentials() {
    setState(() {
      _firstNameController.text = 'فاطمة';
      _lastNameController.text = 'زهرة';
      _emailController.text = 'fatima.zahra@memo.com';
      _phoneController.text = '0666789012';
      _passwordController.text = 'Fatima2025!';
      _confirmPasswordController.text = 'Fatima2025!';
    });
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
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text(AppStringsAr.successRegister),
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
              child: Column(
                children: [
                  // Modern AppBar
                  Padding(
                    padding: EdgeInsets.all(AppDesignTokens.spacingMD),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusMedium,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => context.go('/auth/login'),
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppDesignTokens.spacingMD),
                        Text(
                          AppStringsAr.register,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeH5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600
                              ? screenWidth * 0.2
                              : AppDesignTokens.spacingLG,
                          vertical: AppDesignTokens.spacingMD,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Logo with modern design
                                  Center(
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            AppColors.primaryDark,
                                            AppColors.primary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppDesignTokens.borderRadiusLarge,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryDark
                                                .withOpacity(0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppDesignTokens.spacingLG),

                                  // Header text
                                  Text(
                                    'إنشاء حساب جديد',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppDesignTokens.fontSizeH4,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: AppDesignTokens.spacingSM),
                                  Text(
                                    'املأ البيانات التالية للتسجيل',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppDesignTokens.fontSizeBody,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppDesignTokens.spacingXL),

                                  // Form Card
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
                                        // Section Header
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppDesignTokens.spacingMD,
                                                vertical:
                                                    AppDesignTokens.spacingSM,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primaryDark
                                                        .withOpacity(0.1),
                                                    AppColors.primary
                                                        .withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDesignTokens
                                                          .borderRadiusCard,
                                                    ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.edit_document,
                                                    size: 18,
                                                    color: AppColors.primary,
                                                  ),
                                                  SizedBox(
                                                    width: AppDesignTokens
                                                        .spacingXS,
                                                  ),
                                                  Text(
                                                    'بيانات التسجيل',
                                                    style: TextStyle(
                                                      fontSize: AppDesignTokens
                                                          .fontSizeBody,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppDesignTokens.spacingLG,
                                        ),

                                        // Test Auto-Fill Buttons
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.successGreen
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppDesignTokens
                                                            .borderRadiusMedium,
                                                      ),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .successGreen
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap:
                                                        _autoFillTestCredentials,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppDesignTokens
                                                              .borderRadiusMedium,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            AppDesignTokens
                                                                .spacingSM,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.person_add,
                                                            color: AppColors
                                                                .successGreen,
                                                            size: 20,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                AppDesignTokens
                                                                    .spacingXXS,
                                                          ),
                                                          Text(
                                                            'طالب 1',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .successGreen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  AppDesignTokens
                                                                      .fontSizeSmall,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                AppDesignTokens
                                                                    .spacingXXS,
                                                          ),
                                                          Text(
                                                            'أحمد بن علي',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .successGreen
                                                                  .withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                              fontSize:
                                                                  AppDesignTokens
                                                                      .fontSizeCaption,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                            AppDesignTokens
                                                                .spacingSM,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .person_add_alt_1,
                                                            color: AppColors
                                                                .primary,
                                                            size: 20,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                AppDesignTokens
                                                                    .spacingXXS,
                                                          ),
                                                          Text(
                                                            'طالب 2',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  AppDesignTokens
                                                                      .fontSizeSmall,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                AppDesignTokens
                                                                    .spacingXXS,
                                                          ),
                                                          Text(
                                                            'فاطمة زهرة',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary
                                                                  .withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                              fontSize:
                                                                  AppDesignTokens
                                                                      .fontSizeCaption,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
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
                                        const SizedBox(
                                          height: AppDesignTokens.spacingLG,
                                        ),

                                        // First Name
                                        AppTextField(
                                          controller: _firstNameController,
                                          label: AppStringsAr.firstName,
                                          hint: 'أحمد',
                                          textInputAction: TextInputAction.next,
                                          validator: Validators.validateName,
                                          prefixIcon: const Icon(
                                            Icons.person_outlined,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingMD,
                                        ),

                                        // Last Name
                                        AppTextField(
                                          controller: _lastNameController,
                                          label: AppStringsAr.lastName,
                                          hint: 'بن علي',
                                          textInputAction: TextInputAction.next,
                                          validator: Validators.validateName,
                                          prefixIcon: const Icon(
                                            Icons.person_outlined,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingMD,
                                        ),

                                        // Email
                                        AppTextField(
                                          controller: _emailController,
                                          label: AppStringsAr.email,
                                          hint: 'example@email.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          validator: Validators.validateEmail,
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingMD,
                                        ),

                                        // Phone (Optional)
                                        AppTextField(
                                          controller: _phoneController,
                                          label:
                                              '${AppStringsAr.phone} (اختياري)',
                                          hint: '0555123456',
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            if (value == null || value.isEmpty)
                                              return null;
                                            return Validators.validatePhone(
                                              value,
                                            );
                                          },
                                          prefixIcon: const Icon(
                                            Icons.phone_outlined,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingMD,
                                        ),

                                        // Password
                                        AppTextField(
                                          controller: _passwordController,
                                          label: AppStringsAr.password,
                                          hint: '••••••••',
                                          obscureText: true,
                                          textInputAction: TextInputAction.next,
                                          validator:
                                              Validators.validatePassword,
                                          prefixIcon: const Icon(
                                            Icons.lock_outlined,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingMD,
                                        ),

                                        // Confirm Password
                                        AppTextField(
                                          controller:
                                              _confirmPasswordController,
                                          label: AppStringsAr.confirmPassword,
                                          hint: '••••••••',
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          validator: (value) =>
                                              Validators.validateConfirmPassword(
                                                value,
                                                _passwordController.text,
                                              ),
                                          prefixIcon: const Icon(
                                            Icons.lock_outlined,
                                          ),
                                          onSubmitted: (_) => _handleRegister(),
                                          textDirection: TextDirection.ltr,
                                        ),
                                        const SizedBox(
                                          height: AppDesignTokens.spacingXL,
                                        ),

                                        // Register Button with gradient
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                AppColors.primaryDark,
                                                AppColors.primary,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppDesignTokens.borderRadiusCard,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryDark
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _handleRegister,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDesignTokens
                                                        .borderRadiusCard,
                                                  ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical:
                                                          AppDesignTokens
                                                              .spacingMD +
                                                          2,
                                                    ),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.person_add_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      AppStringsAr.register,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                  const SizedBox(
                                    height: AppDesignTokens.spacingLG,
                                  ),

                                  // Login Link
                                  Container(
                                    padding: const EdgeInsets.all(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStringsAr.alreadyHaveAccount,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        TextButton(
                                          onPressed: () =>
                                              context.go('/auth/login'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                          ),
                                          child: const Text(
                                            AppStringsAr.login,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDesignTokens.spacingXL,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
