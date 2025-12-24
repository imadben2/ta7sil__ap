import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';

/// Results page showing simulation results with detailed analysis
class BacResultsPage extends StatelessWidget {
  const BacResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج المحاكاة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment, size: 100, color: AppColors.successGreen),
              SizedBox(height: AppDesignTokens.spacingXXL),
              Text(
                'صفحة النتائج',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeH3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingLG),
              Text(
                'ستظهر هنا النتائج التفصيلية والتحليلات',
                style: TextStyle(fontSize: AppDesignTokens.fontSizeBody),
              ),
              SizedBox(height: AppDesignTokens.spacingXXXL),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacingXXL,
                    vertical: AppDesignTokens.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                  ),
                ),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
