import 'package:flutter/material.dart';

/// Modern Section Card - matches session_detail_screen design
/// White card with section header (icon + title + optional "view all" button)
///
/// Example usage:
/// ```dart
/// ModernSectionCard(
///   icon: Icons.library_books_rounded,
///   iconColor: Color(0xFF3B82F6),
///   title: 'جلسات اليوم',
///   onViewAll: () => navigateToAllSessions(),
///   child: SessionsList(),
/// )
/// ```
class ModernSectionCard extends StatelessWidget {
  /// Icon for the section header
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Section title
  final String title;

  /// Callback for "view all" button (null to hide)
  final VoidCallback? onViewAll;

  /// View all button text
  final String viewAllText;

  /// Content of the section
  final Widget child;

  /// Whether to show card background
  final bool showBackground;

  /// Padding inside the card
  final EdgeInsets padding;

  const ModernSectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onViewAll,
    this.viewAllText = 'عرض الكل',
    required this.child,
    this.showBackground = true,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        const SizedBox(height: 16),
        // Content
        child,
      ],
    );

    if (!showBackground) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: content,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewAllText,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: iconColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Section Header without card wrapper
/// Use when you need just the header row outside a card
class ModernSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onViewAll;
  final String viewAllText;

  const ModernSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onViewAll,
    this.viewAllText = 'عرض الكل',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllText,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: iconColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
