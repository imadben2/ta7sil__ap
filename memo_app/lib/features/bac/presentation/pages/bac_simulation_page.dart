import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../cubit/simulation_timer_cubit.dart';

/// Main simulation/exam interface page
/// TODO: Implement full question navigation, answer selection, timer integration
class BacSimulationPage extends StatelessWidget {
  const BacSimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محاكاة الامتحان'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<SimulationTimerCubit, SimulationTimerState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(AppDesignTokens.spacingLG),
                child: Center(
                  child: Text(
                    state.formattedRemainingTime,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeH5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 100, color: AppColors.primary),
              SizedBox(height: AppDesignTokens.spacingXXL),
              Text(
                'صفحة المحاكاة',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeH3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingLG),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXXXL),
                child: Text(
                  'سيتم تطوير واجهة الأسئلة والإجابات في النسخة القادمة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppDesignTokens.fontSizeBody),
                ),
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
