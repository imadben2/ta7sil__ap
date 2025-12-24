import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Filter chip group for filtering content
/// Used in lists and search pages
///
/// Example usage:
/// ```dart
/// FilterChipGroup(
///   items: ['All', 'Math', 'Physics', 'Chemistry'],
///   selectedIndex: 0,
///   onSelected: (index) => print('Selected: $index'),
/// )
/// ```
class FilterChipGroup extends StatelessWidget {
  /// List of filter items
  final List<String> items;

  /// Currently selected index
  final int selectedIndex;

  /// On item selected callback
  final ValueChanged<int> onSelected;

  /// Chip color
  final Color? chipColor;

  /// Selected chip color
  final Color? selectedChipColor;

  /// Scroll direction
  final Axis scrollDirection;

  /// Padding around the group
  final EdgeInsetsGeometry? padding;

  const FilterChipGroup({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.chipColor,
    this.selectedChipColor,
    this.scrollDirection = Axis.horizontal,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: 44,
        child: ListView.builder(
          padding: padding ?? AppDesignTokens.paddingScreen,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < items.length - 1
                    ? AppDesignTokens.spacingSM
                    : 0,
              ),
              child: _buildChip(index),
            );
          },
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: AppDesignTokens.spacingSM,
        runSpacing: AppDesignTokens.spacingSM,
        children: List.generate(
          items.length,
          (index) => _buildChip(index),
        ),
      ),
    );
  }

  Widget _buildChip(int index) {
    final isSelected = index == selectedIndex;
    final effectiveSelectedColor = selectedChipColor ?? AppColors.primary;
    final effectiveChipColor = chipColor ?? AppColors.borderLight;

    return GestureDetector(
      onTap: () => onSelected(index),
      child: AnimatedContainer(
        duration: AppDesignTokens.animationNormal,
        curve: AppDesignTokens.curveStandard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveSelectedColor
              : effectiveChipColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusTiny),
          border: Border.all(
            color: isSelected
                ? effectiveSelectedColor
                : effectiveChipColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          items[index],
          style: TextStyle(
            fontSize: AppDesignTokens.fontSizeBodySmall,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

/// Icon filter chip (with icon and text)
class IconFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const IconFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDesignTokens.animationNormal,
        curve: AppDesignTokens.curveStandard,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : AppColors.borderLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusTiny),
          border: Border.all(
            color: isSelected ? effectiveColor : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDesignTokens.iconSizeSM,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBodySmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select filter chips
class MultiSelectFilterChipGroup extends StatelessWidget {
  final List<String> items;
  final List<int> selectedIndices;
  final ValueChanged<List<int>> onSelectionChanged;
  final Color? chipColor;
  final Color? selectedChipColor;
  final EdgeInsetsGeometry? padding;

  const MultiSelectFilterChipGroup({
    super.key,
    required this.items,
    required this.selectedIndices,
    required this.onSelectionChanged,
    this.chipColor,
    this.selectedChipColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: AppDesignTokens.spacingSM,
        runSpacing: AppDesignTokens.spacingSM,
        children: List.generate(
          items.length,
          (index) => _buildChip(index),
        ),
      ),
    );
  }

  Widget _buildChip(int index) {
    final isSelected = selectedIndices.contains(index);
    final effectiveSelectedColor = selectedChipColor ?? AppColors.primary;
    final effectiveChipColor = chipColor ?? AppColors.borderLight;

    return GestureDetector(
      onTap: () {
        final newSelection = List<int>.from(selectedIndices);
        if (isSelected) {
          newSelection.remove(index);
        } else {
          newSelection.add(index);
        }
        onSelectionChanged(newSelection);
      },
      child: AnimatedContainer(
        duration: AppDesignTokens.animationNormal,
        curve: AppDesignTokens.curveStandard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveSelectedColor
              : effectiveChipColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusTiny),
          border: Border.all(
            color: isSelected ? effectiveSelectedColor : effectiveChipColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check,
                size: AppDesignTokens.iconSizeXS,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              items[index],
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBodySmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
