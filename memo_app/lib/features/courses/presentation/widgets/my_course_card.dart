import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_subscription_entity.dart';

/// بطاقة الدورة المشترك فيها - تصميم حديث ومبسط
class MyCourseCard extends StatelessWidget {
  final UserSubscriptionEntity subscription;
  final VoidCallback? onTap;

  const MyCourseCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _cardColor = AppColors.surface;
  static const _textPrimary = AppColors.slate900;
  static const _textMuted = AppColors.slate600;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (subscription.courseId != null) {
          context.push('/courses/${subscription.courseId}/learn');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Content Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_primaryPurple, _secondaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          subscription.courseName ?? 'دورة غير محددة',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Status & Expiry Row
                        Row(
                          children: [
                            _buildStatusBadge(),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: _getExpiryColor(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subscription.remainingDaysText,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getExpiryColor(),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _primaryPurple,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section - Continue Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Activation Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _primaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: _primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تاريخ التفعيل',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: _textMuted,
                              ),
                            ),
                            Text(
                              _formatDate(subscription.activatedAt),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Continue Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryPurple, _secondaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryPurple.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (subscription.courseId != null) {
                            context.push('/courses/${subscription.courseId}/learn');
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'متابعة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = subscription.statusText;
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (!subscription.isActive) return const Color(0xFF9E9E9E);
    if (subscription.isExpired) return const Color(0xFFEF4444);
    if (subscription.remainingDays <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _getExpiryColor() {
    if (subscription.isExpired) return const Color(0xFFEF4444);
    if (subscription.remainingDays <= 7) return const Color(0xFFF59E0B);
    return _textMuted;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
