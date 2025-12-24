import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Standard page scaffold with consistent padding and structure
/// Use this as the base wrapper for all pages to maintain consistency
///
/// Example usage:
/// ```dart
/// PageScaffold(
///   title: 'My Page',
///   body: Column(
///     children: [
///       // Your content here
///     ],
///   ),
/// )
/// ```
class PageScaffold extends StatelessWidget {
  /// Page title (shown in app bar)
  final String? title;

  /// Page body content
  final Widget body;

  /// Show app bar
  final bool showAppBar;

  /// Custom app bar (overrides title)
  final PreferredSizeWidget? appBar;

  /// Floating action button
  final Widget? floatingActionButton;

  /// Bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Apply horizontal padding to body
  final bool applyHorizontalPadding;

  /// Custom padding override
  final EdgeInsetsGeometry? padding;

  /// Background color
  final Color? backgroundColor;

  /// Safe area settings
  final bool safeAreaTop;
  final bool safeAreaBottom;

  /// Show back button in app bar
  final bool showBackButton;

  /// Custom actions for app bar
  final List<Widget>? actions;

  /// On back button pressed
  final VoidCallback? onBackPressed;

  /// Scroll controller for body
  final ScrollController? scrollController;

  /// Enable scroll for body
  final bool enableScroll;

  /// App bar elevation
  final double appBarElevation;

  const PageScaffold({
    super.key,
    this.title,
    required this.body,
    this.showAppBar = true,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.applyHorizontalPadding = true,
    this.padding,
    this.backgroundColor,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.scrollController,
    this.enableScroll = true,
    this.appBarElevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        (applyHorizontalPadding ? AppDesignTokens.paddingScreen : EdgeInsets.zero);

    Widget bodyWidget = Padding(
      padding: effectivePadding,
      child: body,
    );

    if (enableScroll) {
      bodyWidget = SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: bodyWidget,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: showAppBar
          ? (appBar ??
              AppBar(
                title: title != null ? Text(title!) : null,
                elevation: appBarElevation,
                leading: showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBackPressed ?? () => Navigator.pop(context),
                      )
                    : null,
                actions: actions,
                backgroundColor: backgroundColor ?? AppColors.background,
              ))
          : null,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: bodyWidget,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Page scaffold with refresh indicator
class PageScaffoldWithRefresh extends StatelessWidget {
  final String? title;
  final Widget body;
  final Future<void> Function() onRefresh;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool applyHorizontalPadding;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const PageScaffoldWithRefresh({
    super.key,
    this.title,
    required this.body,
    required this.onRefresh,
    this.showAppBar = true,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.applyHorizontalPadding = true,
    this.padding,
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        (applyHorizontalPadding ? AppDesignTokens.paddingScreen : EdgeInsets.zero);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: showAppBar
          ? (appBar ??
              AppBar(
                title: title != null ? Text(title!) : null,
                elevation: 0,
                actions: actions,
                backgroundColor: backgroundColor ?? AppColors.background,
              ))
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: effectivePadding,
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Empty state page scaffold
class EmptyStateScaffold extends StatelessWidget {
  final String? title;
  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const EmptyStateScaffold({
    super.key,
    this.title,
    required this.icon,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              elevation: 0,
              backgroundColor: backgroundColor ?? AppColors.background,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppDesignTokens.paddingScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeBody,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onActionPressed != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onActionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: AppDesignTokens.paddingButton,
                    ),
                    child: Text(actionText!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
