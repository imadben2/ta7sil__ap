import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';
import '../../utils/gradient_helper.dart';

/// Large hero card with gradient background and shadow
/// Based on the points display card from home_page.dart
///
/// Example usage:
/// ```dart
/// GradientHeroCard(
///   gradient: GradientHelper.primaryHero,
///   height: 200,
///   child: Column(
///     children: [
///       Text('1,250', style: TextStyle(fontSize: 48, color: Colors.white)),
///       Text('Total Points', style: TextStyle(color: Colors.white70)),
///     ],
///   ),
/// )
/// ```
class GradientHeroCard extends StatelessWidget {
  /// Child widget to display inside the card
  final Widget child;

  /// Gradient to use for the background (defaults to primary hero gradient)
  final LinearGradient? gradient;

  /// Card height (defaults to hero card height)
  final double? height;

  /// Card width (defaults to full width)
  final double? width;

  /// Border radius (defaults to hero card radius)
  final double? borderRadius;

  /// Whether to show decorative circles
  final bool showDecorativeCircles;

  /// Custom padding inside the card
  final EdgeInsetsGeometry? padding;

  /// On tap callback
  final VoidCallback? onTap;

  /// Shadow intensity ('primary', 'primary-light', 'primary-subtle')
  final String shadowIntensity;

  const GradientHeroCard({
    super.key,
    required this.child,
    this.gradient,
    this.height,
    this.width,
    this.borderRadius,
    this.showDecorativeCircles = true,
    this.padding,
    this.onTap,
    this.shadowIntensity = 'primary',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? GradientHelper.primaryHero;
    final effectiveHeight = height ?? AppDesignTokens.heroCardHeight;
    final effectiveBorderRadius =
        borderRadius ?? AppDesignTokens.borderRadiusHero;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: effectiveHeight,
        width: width,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          boxShadow: [
            AppDesignTokens.getShadow(shadowIntensity),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Stack(
            children: [
              // Decorative circles background
              if (showDecorativeCircles) ...[
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.overlayWhite10,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.overlayWhite5,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.overlayWhite5,
                    ),
                  ),
                ),
              ],

              // Content
              Padding(
                padding: padding ?? AppDesignTokens.paddingCardLarge,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builder variant for custom decorative patterns
class GradientHeroCardWithCustomPattern extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String shadowIntensity;
  final Widget Function(BuildContext) patternBuilder;

  const GradientHeroCardWithCustomPattern({
    super.key,
    required this.child,
    required this.patternBuilder,
    this.gradient,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.shadowIntensity = 'primary',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? GradientHelper.primaryHero;
    final effectiveHeight = height ?? AppDesignTokens.heroCardHeight;
    final effectiveBorderRadius =
        borderRadius ?? AppDesignTokens.borderRadiusHero;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: effectiveHeight,
        width: width,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          boxShadow: [
            AppDesignTokens.getShadow(shadowIntensity),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Stack(
            children: [
              // Custom pattern
              patternBuilder(context),

              // Content
              Padding(
                padding: padding ?? AppDesignTokens.paddingCardLarge,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
