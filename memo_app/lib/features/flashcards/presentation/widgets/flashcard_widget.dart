import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/flashcard_entity.dart';

/// A flashcard widget with 3D flip animation
class FlashcardWidget extends StatefulWidget {
  final FlashcardEntity card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final Duration animationDuration;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animation.addListener(_updateShowFront);
  }

  void _updateShowFront() {
    if (_animation.value >= 0.5 && _showFront) {
      setState(() => _showFront = false);
    } else if (_animation.value < 0.5 && !_showFront) {
      setState(() => _showFront = true);
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    // Reset when card changes
    if (oldWidget.card.id != widget.card.id) {
      _controller.reset();
      _showFront = true;
    }
  }

  @override
  void dispose() {
    _animation.removeListener(_updateShowFront);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _showFront
                ? _buildFrontSide()
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBackSide(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    return _CardSide(
      color: AppColors.primary,
      child: _buildCardContent(
        text: widget.card.frontTextAr,
        imageUrl: widget.card.frontImageUrl,
        isCloze: widget.card.type == FlashcardType.cloze,
        clozeTemplate: widget.card.clozeTemplate,
        label: 'السؤال',
        labelIcon: Icons.help_outline_rounded,
      ),
    );
  }

  Widget _buildBackSide() {
    return _CardSide(
      color: AppColors.success,
      child: _buildCardContent(
        text: widget.card.backTextAr,
        imageUrl: widget.card.backImageUrl,
        isCloze: false,
        label: 'الإجابة',
        labelIcon: Icons.lightbulb_outline_rounded,
      ),
    );
  }

  Widget _buildCardContent({
    required String text,
    String? imageUrl,
    bool isCloze = false,
    String? clozeTemplate,
    required String label,
    required IconData labelIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header label
        Row(
          children: [
            Icon(
              labelIcon,
              color: AppColors.textOnPrimary.withOpacity(0.8),
              size: AppSizes.iconSM,
            ),
            const SizedBox(width: AppSizes.spacingSM),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textOnPrimary.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingLG),

        // Main content
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingMD),
                  ],
                  if (isCloze && clozeTemplate != null)
                    _buildClozeText(clozeTemplate)
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),

        // Hint at bottom
        if (widget.card.hintAr != null && widget.card.hintAr!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.overlayWhite10,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.textOnPrimary,
                  size: AppSizes.iconSM,
                ),
                const SizedBox(width: AppSizes.spacingSM),
                Expanded(
                  child: Text(
                    widget.card.hintAr!,
                    style: TextStyle(
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Tap to flip hint
        const SizedBox(height: AppSizes.spacingMD),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_outlined,
                color: AppColors.textOnPrimary.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'اضغط للقلب',
                style: TextStyle(
                  color: AppColors.textOnPrimary.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClozeText(String template) {
    // Parse cloze template and show blanks
    // Format: "Text {{c1::answer::hint}} more text"
    final regex = RegExp(r'\{\{c\d+::([^:}]+)(?:::([^}]+))?\}\}');
    final parts = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(template)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: template.substring(lastEnd, match.start),
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ));
      }

      // Add blank placeholder
      parts.add(WidgetSpan(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.overlayWhite20,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(
              color: AppColors.textOnPrimary.withOpacity(0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: const Text(
            '______',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < template.length) {
      parts.add(TextSpan(
        text: template.substring(lastEnd),
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: parts),
    );
  }
}

/// Card side container with styling
class _CardSide extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CardSide({
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
