import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/planner_sync_queue.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_state.dart';

/// Sync status indicator widget showing:
/// ✓ Synced (green) - No pending items
/// ⟳ Syncing (blue, animated) - Sync in progress
/// ⚠ Pending (orange) - Items waiting to sync
/// ✗ Error (red) - Sync failed
class SyncStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const SyncStatusIndicator({
    Key? key,
    this.showLabel = true,
    this.iconSize = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      buildWhen: (previous, current) =>
          current is PlannerLoading ||
          current is OfflineChangesSynced ||
          current is PlannerError,
      builder: (context, state) {
        final syncQueue = context.read<PlannerSyncQueue>();
        final pendingCount = syncQueue.pendingCount;

        // Determine status
        SyncStatus status;
        if (state is PlannerLoading && (state.message?.contains('مزامنة') ?? false)) {
          status = SyncStatus.syncing;
        } else if (state is PlannerError) {
          status = SyncStatus.error;
        } else if (pendingCount > 0) {
          status = SyncStatus.pending;
        } else {
          status = SyncStatus.synced;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(status),
            if (showLabel && pendingCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$pendingCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getColor(status),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icon(
          Icons.check_circle,
          color: Colors.green,
          size: iconSize,
        );
      case SyncStatus.syncing:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case SyncStatus.pending:
        return Icon(
          Icons.sync,
          color: Colors.orange,
          size: iconSize,
        );
      case SyncStatus.error:
        return Icon(
          Icons.error,
          color: Colors.red,
          size: iconSize,
        );
    }
  }

  Color _getColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}

enum SyncStatus {
  synced,
  syncing,
  pending,
  error,
}
