import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Navigation item data model
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color> gradientColors;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradientColors,
  });
}

/// Modern bottom navigation bar with glassmorphism design
///
/// Features:
/// - Glassmorphism with backdrop blur
/// - Smooth animations (300ms)
/// - Individual gradient colors per item
/// - Multi-layer shadows with glow effect
/// - Active indicator line with animation
/// - Icon size animations with bounce
/// - Haptic feedback on tap
/// - 5 items: الرئيسية, دوراتي, الدورات, بلانر, حسابي
class ModernBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ModernBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<ModernBottomNavigationBar> createState() =>
      _ModernBottomNavigationBarState();
}

class _ModernBottomNavigationBarState extends State<ModernBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Unified purple gradient for all selected items (same as الدورات)
  static const List<Color> _selectedGradient = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];

  // Navigation items with unified selection color
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
      gradientColors: _selectedGradient,
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'دوراتي',
      gradientColors: _selectedGradient,
    ),
    BottomNavItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_rounded,
      label: 'الدورات',
      gradientColors: _selectedGradient,
    ),
    BottomNavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'بلانر',
      gradientColors: _selectedGradient,
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'حسابي',
      gradientColors: _selectedGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.98),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, -15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (index) {
                    return _buildBottomNavItem(
                      context,
                      item: _navItems[index],
                      index: index,
                      isSelected: widget.selectedIndex == index,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required BottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    final primaryColor = item.gradientColors.first;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Always trigger tap (even if selected) to allow resetting to home view
            HapticFeedback.lightImpact();
            widget.onItemTapped(index);
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              vertical: isSelected ? 10 : 8,
              horizontal: 4,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.gradientColors,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  padding: EdgeInsets.all(isSelected ? 6 : 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? Colors.white : Colors.grey[500],
                      size: isSelected ? 26 : 22,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Label with animation
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontFamily: 'Cairo',
                    letterSpacing: isSelected ? 0.2 : 0,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Active indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(top: 4),
                  width: isSelected ? 16 : 0,
                  height: isSelected ? 3 : 0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
