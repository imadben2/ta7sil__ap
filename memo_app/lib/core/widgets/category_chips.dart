import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_design_tokens.dart';

/// Category model for the chips
class CategoryItem {
  final String name;
  final IconData? icon;
  final Color? activeColor;
  final List<Color>? gradientColors;

  const CategoryItem({
    required this.name,
    this.icon,
    this.activeColor,
    this.gradientColors,
  });
}

/// Default categories for the app with custom colors
class AppCategories {
  static const List<CategoryItem> categories = [
    CategoryItem(
      name: 'الرئيسية',
      icon: Icons.home_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    CategoryItem(
      name: 'بلانر',
      icon: Icons.calendar_month_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    CategoryItem(
      name: 'ملخصات و دروس',
      icon: Icons.menu_book_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    CategoryItem(
      name: 'بكالوريات',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    CategoryItem(
      name: 'كويز',
      icon: Icons.quiz_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    CategoryItem(
      name: 'دوراتنا',
      icon: Icons.play_circle_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    ),
    // BAC Study Schedule (shown only for Terminale students)
    CategoryItem(
      name: 'جدول البكالوريا',
      icon: Icons.event_note_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
  ];

  /// Get categories in custom order based on provided order list
  ///
  /// [order] is a list of original indices in the desired display order.
  /// For example, [2, 0, 1, 3, 5, 4] means:
  /// - Position 0 shows category 2 (ملخصات و دروس)
  /// - Position 1 shows category 0 (الرئيسية)
  /// - etc.
  static List<CategoryItem> getOrderedCategories(List<int> order) {
    if (order.length != categories.length) {
      return categories;
    }
    return order.map((index) {
      if (index >= 0 && index < categories.length) {
        return categories[index];
      }
      return categories[0];
    }).toList();
  }

  /// Get category at specific index
  static CategoryItem getCategoryAt(int index) {
    if (index >= 0 && index < categories.length) {
      return categories[index];
    }
    return categories[0];
  }

  /// Get total number of categories
  static int get count => categories.length;
}

/// Horizontal scrollable list of category filter chips with swipe support
/// Modern glassmorphism design with individual category colors
class CategoryChips extends StatefulWidget {
  final List<CategoryItem> categories;
  final int selectedIndex;
  final Function(int) onSelected;
  final bool showIcons;
  final bool useGlassmorphism;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.showIcons = true,
    this.useGlassmorphism = true,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  // Keys for each chip to calculate positions
  final List<GlobalKey> _chipKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Initialize keys for each category
    for (int i = 0; i < 10; i++) {
      _chipKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to selected chip when selection changes
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelectedChip();
      _animationController.forward(from: 0);
    }
  }

  /// Scroll to make the selected chip visible and centered
  void _scrollToSelectedChip() {
    if (!_scrollController.hasClients) return;

    // Calculate approximate position (each chip ~100px wide + spacing)
    const double chipWidth = 110.0;
    const double spacing = 10.0;
    final double targetPosition = widget.selectedIndex * (chipWidth + spacing);

    // Get the viewport width
    final double viewportWidth = _scrollController.position.viewportDimension;

    // Calculate scroll position to center the chip
    double scrollTo = targetPosition - (viewportWidth / 2) + (chipWidth / 2);

    // Clamp to valid scroll range
    scrollTo = scrollTo.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    // Animate to position
    _scrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: widget.useGlassmorphism
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.5),
            )
          : null,
      child: ClipRect(
        child: BackdropFilter(
          filter: widget.useGlassmorphism
              ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignTokens.screenPaddingHorizontal,
              vertical: 2,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isSelected = index == widget.selectedIndex;
              return _buildChip(
                widget.categories[index],
                isSelected,
                () => widget.onSelected(index),
                index,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    CategoryItem category,
    bool isSelected,
    VoidCallback onTap,
    int index,
  ) {
    // Get category-specific gradient or fallback to primary
    final gradientColors = category.gradientColors ?? AppColors.primaryGradient;
    final primaryColor = gradientColors.first;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        key: index < _chipKeys.length ? _chipKeys[index] : null,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcons && category.icon != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.all(isSelected ? 3 : 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  category.icon,
                  size: isSelected ? 16 : 15,
                  color: isSelected ? Colors.white : primaryColor.withOpacity(0.8),
                ),
              ),
              SizedBox(width: isSelected ? 6 : 5),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                letterSpacing: isSelected ? 0.2 : 0,
              ),
              child: Text(category.name),
            ),
          ],
        ),
      ),
    );
  }
}
