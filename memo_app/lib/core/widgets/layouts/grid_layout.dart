import 'package:flutter/material.dart';
import '../../constants/app_design_tokens.dart';

/// Responsive grid layout for cards
/// Automatically adjusts columns based on screen size
///
/// Example usage:
/// ```dart
/// GridLayout(
///   itemCount: subjects.length,
///   itemBuilder: (context, index) {
///     return ProgressCard(...);
///   },
/// )
/// ```
class GridLayout extends StatelessWidget {
  /// Number of items in the grid
  final int itemCount;

  /// Builder for grid items
  final Widget Function(BuildContext, int) itemBuilder;

  /// Number of columns (null for auto-responsive)
  final int? columnCount;

  /// Spacing between items
  final double? spacing;

  /// Aspect ratio for grid items
  final double? aspectRatio;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  /// Shrink wrap the grid
  final bool shrinkWrap;

  /// Physics for scrolling
  final ScrollPhysics? physics;

  const GridLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.columnCount,
    this.spacing,
    this.aspectRatio,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppDesignTokens.gridSpacing;
    final effectiveColumnCount =
        columnCount ?? AppDesignTokens.gridColumnsSubjects;
    final effectiveAspectRatio =
        aspectRatio ?? AppDesignTokens.aspectRatioSubjectCard;

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumnCount,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: effectiveSpacing,
        childAspectRatio: effectiveAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Responsive grid that changes columns based on screen width
class ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? spacing;
  final double? aspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  /// Breakpoints for different column counts
  final double smallScreenBreakpoint; // < this: 1 column
  final double mediumScreenBreakpoint; // < this: 2 columns, >= this: 3 columns

  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing,
    this.aspectRatio,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.smallScreenBreakpoint = 400,
    this.mediumScreenBreakpoint = 600,
  });

  int _getColumnCount(double width) {
    if (width < smallScreenBreakpoint) return 1;
    if (width < mediumScreenBreakpoint) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(screenWidth);
    final effectiveSpacing = spacing ?? AppDesignTokens.gridSpacing;
    final effectiveAspectRatio =
        aspectRatio ?? AppDesignTokens.aspectRatioSubjectCard;

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: effectiveSpacing,
        childAspectRatio: effectiveAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Staggered grid layout (for items with varying heights)
class StaggeredGridLayout extends StatelessWidget {
  final List<Widget> children;
  final int columnCount;
  final double? spacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StaggeredGridLayout({
    super.key,
    required this.children,
    this.columnCount = 2,
    this.spacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppDesignTokens.gridSpacing;

    // Create column lists
    final List<List<Widget>> columns =
        List.generate(columnCount, (index) => []);

    // Distribute children across columns
    for (int i = 0; i < children.length; i++) {
      columns[i % columnCount].add(children[i]);
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          columnCount,
          (columnIndex) => Expanded(
            child: Column(
              children: List.generate(
                columns[columnIndex].length,
                (itemIndex) => Padding(
                  padding: EdgeInsets.only(
                    right: columnIndex < columnCount - 1
                        ? effectiveSpacing / 2
                        : 0,
                    left: columnIndex > 0 ? effectiveSpacing / 2 : 0,
                    bottom: effectiveSpacing,
                  ),
                  child: columns[columnIndex][itemIndex],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrolling grid
class HorizontalGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? itemWidth;
  final double? itemHeight;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  const HorizontalGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemWidth,
    this.itemHeight,
    this.spacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppDesignTokens.gridSpacing;
    final effectiveItemWidth = itemWidth ?? 160.0;
    final effectiveItemHeight = itemHeight ?? 200.0;

    return SizedBox(
      height: effectiveItemHeight,
      child: ListView.builder(
        padding: padding ?? AppDesignTokens.paddingScreen,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: effectiveItemWidth,
            margin: EdgeInsets.only(
              right: index < itemCount - 1 ? effectiveSpacing : 0,
            ),
            child: itemBuilder(context, index),
          );
        },
      ),
    );
  }
}

/// Wrap layout (for tags, chips, etc.)
class WrapLayout extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment alignment;
  final EdgeInsetsGeometry? padding;

  const WrapLayout({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppDesignTokens.spacingSM;
    final effectiveRunSpacing = runSpacing ?? AppDesignTokens.spacingSM;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: effectiveSpacing,
        runSpacing: effectiveRunSpacing,
        alignment: alignment,
        children: children,
      ),
    );
  }
}
