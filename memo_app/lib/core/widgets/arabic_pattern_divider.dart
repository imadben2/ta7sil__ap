import 'package:flutter/material.dart';

/// Modern Arabic-inspired decorative divider for RTL layouts
/// فاصل زخرفي مستوحى من الزخارف العربية لتخطيطات RTL
class ArabicPatternDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double opacity;

  const ArabicPatternDivider({
    super.key,
    this.height = 1.5,
    this.color,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Decorative pattern on right (RTL start)
          Container(
            width: 40,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [dividerColor.withOpacity(opacity), Colors.transparent],
              ),
            ),
          ),
          // Center ornament
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.star_border_rounded,
              size: 16,
              color: dividerColor.withOpacity(opacity * 2),
            ),
          ),
          // Expanding line
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    dividerColor.withOpacity(opacity),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Left ornament
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.star_border_rounded,
              size: 16,
              color: dividerColor.withOpacity(opacity * 2),
            ),
          ),
          // Decorative pattern on left (RTL end)
          Container(
            width: 40,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [dividerColor.withOpacity(opacity), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple divider with Arabic aesthetics
class SimpleArabicDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  const SimpleArabicDivider({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      color: color ?? Theme.of(context).dividerColor,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
