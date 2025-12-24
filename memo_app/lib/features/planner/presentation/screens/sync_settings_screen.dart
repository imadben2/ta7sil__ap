import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/planner_sync_queue.dart';
import '../../data/services/background_sync_service.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../widgets/sync_status_indicator.dart';
import 'package:intl/intl.dart';

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final syncQueue = context.read<PlannerSyncQueue>();
    final syncService = context.read<BackgroundSyncService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المزامنة'),
      ),
      body: BlocListener<PlannerBloc, PlannerState>(
        listener: (context, state) {
          if (state is OfflineChangesSynced) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.syncedCount > 0 ? Colors.green : Colors.orange,
              ),
            );
          } else if (state is PlannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'حالة المزامنة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const SyncStatusIndicator(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'التغييرات المعلقة',
                      '${syncQueue.pendingCount}',
                    ),
                    _buildInfoRow(
                      'آخر مزامنة',
                      _formatLastSync(syncQueue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Sync Button
            ElevatedButton.icon(
              onPressed: syncQueue.pendingCount > 0
                  ? () {
                      context.read<PlannerBloc>().add(
                            const SyncOfflineChangesEvent(),
                          );
                    }
                  : null,
              icon: const Icon(Icons.sync),
              label: const Text('مزامنة الآن'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Queue Items List
            if (syncQueue.pendingCount > 0) ...[
              const Text(
                'التغييرات المعلقة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...syncQueue.getItemsToRetry().map((item) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.pending_actions),
                    title: Text(item.description),
                    subtitle: Text(
                      'محاولة ${item.retryCount + 1} من 5',
                    ),
                    trailing: item.errorMessage != null
                        ? const Icon(Icons.error, color: Colors.red)
                        : null,
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 16),

            // Developer Options (debug mode only)
            if (const bool.fromEnvironment('dart.vm.product') == false) ...[
              const Divider(),
              const Text(
                'خيارات المطور',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await syncQueue.clearQueue();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح قائمة الانتظار')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('مسح قائمة الانتظار'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await syncService.cancelAllTasks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إلغاء مهام WorkManager')),
                  );
                },
                child: const Text('إلغاء مهام الخلفية'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(PlannerSyncQueue syncQueue) {
    final lastSync = syncQueue.lastSyncTimestamp;
    if (lastSync == null) {
      return 'لم تتم المزامنة بعد';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(lastSync);
    }
  }
}
