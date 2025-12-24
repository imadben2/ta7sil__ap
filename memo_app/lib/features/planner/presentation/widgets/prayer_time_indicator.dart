import 'package:flutter/material.dart';
import '../../domain/entities/prayer_times.dart';

/// Prayer Time Indicator Widget
///
/// Shows prayer name and time with visual indicator for current/upcoming prayer
/// Used in timeline and calendar views
class PrayerTimeIndicator extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;
  final bool isCurrent;
  final bool isUpcoming;

  const PrayerTimeIndicator({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
    this.isCurrent = false,
    this.isUpcoming = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: isCurrent ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPrayerIcon(), color: _getIconColor(), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getArabicPrayerName(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              Text(
                _formatTime(prayerTime),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: _getTextColor().withOpacity(0.8),
                ),
              ),
            ],
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get Arabic prayer name
  String _getArabicPrayerName() {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return prayerName;
    }
  }

  /// Get prayer icon
  IconData _getPrayerIcon() {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_cloudy;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.bedtime;
      default:
        return Icons.mosque;
    }
  }

  /// Get background color based on state
  Color _getBackgroundColor() {
    if (isCurrent) {
      return Colors.green.shade50;
    } else if (isUpcoming) {
      return Colors.blue.shade50;
    }
    return Colors.grey.shade100;
  }

  /// Get border color based on state
  Color _getBorderColor() {
    if (isCurrent) {
      return Colors.green;
    } else if (isUpcoming) {
      return Colors.blue;
    }
    return Colors.grey.shade300;
  }

  /// Get icon color based on state
  Color _getIconColor() {
    if (isCurrent) {
      return Colors.green.shade700;
    } else if (isUpcoming) {
      return Colors.blue.shade700;
    }
    return Colors.grey.shade600;
  }

  /// Get text color based on state
  Color _getTextColor() {
    if (isCurrent) {
      return Colors.green.shade900;
    } else if (isUpcoming) {
      return Colors.blue.shade900;
    }
    return Colors.grey.shade800;
  }

  /// Format time to HH:MM
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Prayer Times List Widget
///
/// Displays a list of all prayer times for a day
class PrayerTimesList extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final DateTime? currentTime;

  const PrayerTimesList({Key? key, required this.prayerTimes, this.currentTime})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = currentTime ?? DateTime.now();
    final prayers = _getPrayersList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mosque, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  'مواقيت الصلاة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prayers.map((prayer) {
                final isCurrent = _isCurrentPrayer(prayer['time'], now);
                final isUpcoming = _isUpcomingPrayer(prayer['time'], now);

                return PrayerTimeIndicator(
                  prayerName: prayer['name'],
                  prayerTime: prayer['time'],
                  isCurrent: isCurrent,
                  isUpcoming: isUpcoming,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Get list of prayers with names and times
  List<Map<String, dynamic>> _getPrayersList() {
    return [
      {'name': 'fajr', 'time': prayerTimes.fajr},
      {'name': 'dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'asr', 'time': prayerTimes.asr},
      {'name': 'maghrib', 'time': prayerTimes.maghrib},
      {'name': 'isha', 'time': prayerTimes.isha},
    ];
  }

  /// Check if prayer is currently active (within 30 minutes after time)
  bool _isCurrentPrayer(DateTime prayerTime, DateTime now) {
    final difference = now.difference(prayerTime).inMinutes;
    return difference >= 0 && difference < 30;
  }

  /// Check if prayer is upcoming (within 1 hour before time)
  bool _isUpcomingPrayer(DateTime prayerTime, DateTime now) {
    final difference = prayerTime.difference(now).inMinutes;
    return difference > 0 && difference <= 60;
  }
}

/// Compact Prayer Time Indicator for Timeline
///
/// Minimal version for use in timeline view
class CompactPrayerTimeIndicator extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;

  const CompactPrayerTimeIndicator({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mosque, color: Colors.green.shade700, size: 14),
          const SizedBox(width: 4),
          Text(
            _getArabicPrayerName(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  /// Get Arabic prayer name
  String _getArabicPrayerName() {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return prayerName;
    }
  }
}
