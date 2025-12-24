import 'package:flutter/material.dart';

/// Tab item data for ModernSegmentedTabs
class TabItem {
  final IconData icon;
  final String label;

  const TabItem({
    required this.icon,
    required this.label,
  });
}

/// Modern segmented tabs with gradient indicator and animations
///
/// Replaces standard TabBar with a modern design featuring:
/// - Gradient indicator with smooth animation
/// - Bounce effect on selection
/// - RTL support
/// - Customizable colors and sizing
class ModernSegmentedTabs extends StatefulWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  final Duration animationDuration;
  final double height;
  final EdgeInsetsGeometry? padding;

  const ModernSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.height = 56,
    this.padding,
  });

  @override
  State<ModernSegmentedTabs> createState() => _ModernSegmentedTabsState();
}

class _ModernSegmentedTabsState extends State<ModernSegmentedTabs>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int? _bouncingIndex;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == widget.selectedIndex) return;

    setState(() => _bouncingIndex = index);
    _bounceController.forward().then((_) {
      _bounceController.reverse().then((_) {
        setState(() => _bouncingIndex = null);
      });
    });

    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? const Color(0xFF2196F3);
    final unselectedColor = widget.unselectedColor ?? const Color(0xFF64748B);
    final backgroundColor = widget.backgroundColor ?? const Color(0xFFF1F5F9);

    return Container(
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 8) / widget.tabs.length;

            return Stack(
              children: [
                // Animated indicator
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOutCubic,
                  left: Directionality.of(context) == TextDirection.rtl
                      ? null
                      : widget.selectedIndex * tabWidth,
                  right: Directionality.of(context) == TextDirection.rtl
                      ? widget.selectedIndex * tabWidth
                      : null,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          selectedColor,
                          selectedColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab items
                Row(
                  children: List.generate(widget.tabs.length, (index) {
                    final isSelected = index == widget.selectedIndex;
                    final tab = widget.tabs[index];

                    return Expanded(
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          final scale = _bouncingIndex == index
                              ? _bounceAnimation.value
                              : 1.0;

                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTabTap(index),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: selectedColor.withOpacity(0.1),
                            highlightColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: widget.animationDuration,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : unselectedColor,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontFamily: 'Cairo',
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tab.icon,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : unselectedColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            tab.label,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
