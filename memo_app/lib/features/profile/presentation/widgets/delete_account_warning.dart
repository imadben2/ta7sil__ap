import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Warning card widget for account deletion
///
/// Displays a red warning card with:
/// - Warning icon and title
/// - List of data that will be deleted
/// - Important notice about irreversibility
///
/// Used in DeleteAccountPage to inform users before deletion
class DeleteAccountWarning extends StatelessWidget {
  /// Optional custom warning message
  final String? customMessage;

  /// Whether to show the data list (default: true)
  final bool showDataList;

  const DeleteAccountWarning({
    Key? key,
    this.customMessage,
    this.showDataList = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning header
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[700],
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تحذير: هذا الإجراء لا يمكن التراجع عنه!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom message or default warning
          Text(
            customMessage ??
                'سيتم حذف حسابك نهائياً بعد 30 يوماً. خلال هذه الفترة، يمكنك استعادة حسابك بتسجيل الدخول مرة أخرى.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[800],
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),

          // Data list (if enabled)
          if (showDataList) ...[
            const SizedBox(height: 16),
            Text(
              'البيانات التي سيتم حذفها:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            _buildDataItem(
              icon: Icons.person,
              label: 'الملف الشخصي والأكاديمي',
            ),
            _buildDataItem(
              icon: Icons.calendar_today,
              label: 'الجدول الدراسي وجميع الجلسات',
            ),
            _buildDataItem(
              icon: Icons.quiz,
              label: 'نتائج الاختبارات والواجبات',
            ),
            _buildDataItem(
              icon: Icons.bar_chart,
              label: 'الإحصائيات والتقدم',
            ),
            _buildDataItem(
              icon: Icons.emoji_events,
              label: 'الإنجازات والنقاط',
            ),
            _buildDataItem(
              icon: Icons.settings,
              label: 'الإعدادات والتفضيلات',
            ),
          ],
        ],
      ),
    );
  }

  /// Build a single data item in the list
  Widget _buildDataItem({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.red[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[800],
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Icon(
            Icons.close,
            size: 16,
            color: Colors.red[700],
          ),
        ],
      ),
    );
  }
}

/// Compact version of delete account warning (no data list)
class CompactDeleteAccountWarning extends StatelessWidget {
  final String? message;

  const CompactDeleteAccountWarning({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DeleteAccountWarning(
      customMessage: message,
      showDataList: false,
    );
  }
}
