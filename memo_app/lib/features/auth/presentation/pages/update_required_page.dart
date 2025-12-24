import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/constants/app_strings_ar.dart';

class UpdateRequiredPage extends StatelessWidget {
  final String? storeUrl;

  const UpdateRequiredPage({super.key, this.storeUrl});

  Future<void> _openStore() async {
    final url = storeUrl ?? 'https://play.google.com/store/apps/details?id=com.memo.app';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppDesignTokens.spacingLG),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
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
                    child: const Icon(
                      Icons.school,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingXXL),

                  // Update Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update,
                      size: 50,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingLG),

                  // Title
                  Text(
                    AppStringsAr.updateRequired,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeH2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDesignTokens.spacingMD),

                  // Message
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.spacingLG,
                    ),
                    child: Text(
                      AppStringsAr.updateRequiredMessage,
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeBody,
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                        fontFamily: 'Cairo',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingXXL),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textOnPrimary,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDesignTokens.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.borderRadiusMedium,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download, size: 24),
                          SizedBox(width: AppDesignTokens.spacingSM),
                          Text(
                            AppStringsAr.updateNow,
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSizeTitleSmall,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
