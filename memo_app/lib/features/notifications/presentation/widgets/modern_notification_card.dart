import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/notification_entity.dart';

/// بطاقة إشعار حديثة
class ModernNotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final List<Color>? accentGradient;

  const ModernNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.accentGradient,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(context);
    final gradient = accentGradient ?? [typeColor, typeColor.withOpacity(0.7)];

    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDismiss?.call(),
            backgroundColor: Colors.transparent,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade100
                  : gradient[0].withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? Colors.black.withOpacity(0.04)
                    : gradient[0].withOpacity(0.15),
                blurRadius: notification.isRead ? 8 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Gradient accent bar on left for unread
                if (!notification.isRead)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradient,
                        ),
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    notification.isRead ? 16 : 20,
                    14,
                    14,
                    14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container with gradient
                      _buildTypeIcon(context, typeColor, gradient),
                      const SizedBox(width: 14),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Unread dot with glow
                                if (!notification.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsetsDirectional.only(start: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: gradient),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradient[0].withOpacity(0.5),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Body text
                            Text(
                              notification.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),

                            // Footer
                            Row(
                              children: [
                                // Time with icon
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTime(notification.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Type badge with gradient
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        typeColor.withOpacity(0.15),
                                        typeColor.withOpacity(0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        notification.typeIcon,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        notification.typeNameAr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: typeColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // Arrow for actionable notifications
                                if (notification.actionType != null)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradient.map((c) => c.withOpacity(0.15)).toList(),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 12,
                                      color: gradient[0],
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildTypeIcon(BuildContext context, Color typeColor, List<Color> gradient) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: notification.isRead
              ? [typeColor.withOpacity(0.15), typeColor.withOpacity(0.08)]
              : [gradient[0].withOpacity(0.2), gradient[1].withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: notification.isRead
            ? null
            : [
                BoxShadow(
                  color: gradient[0].withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          notification.typeIcon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Color _getTypeColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.studyReminder:
        return const Color(0xFF4A90D9);
      case NotificationType.examAlert:
        return const Color(0xFFE53935);
      case NotificationType.dailySummary:
        return const Color(0xFF43A047);
      case NotificationType.weeklySummary:
        return const Color(0xFF00897B);
      case NotificationType.courseUpdate:
        return const Color(0xFF8E24AA);
      case NotificationType.achievement:
        return const Color(0xFFFFA726);
      case NotificationType.system:
        return const Color(0xFF78909C);
      case NotificationType.announcement:
        return const Color(0xFF00ACC1);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} س';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} ي';
    } else {
      return DateFormat('d/M', 'ar').format(dateTime);
    }
  }
}
