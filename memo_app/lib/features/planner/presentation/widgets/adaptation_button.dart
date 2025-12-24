import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';

/// A button widget for triggering schedule adaptation
class AdaptationButton extends StatelessWidget {
  /// Whether to show as an icon button or full button
  final bool iconOnly;

  /// Custom callback after successful adaptation
  final VoidCallback? onAdaptationComplete;

  const AdaptationButton({
    super.key,
    this.iconOnly = false,
    this.onAdaptationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocConsumer<PlannerBloc, PlannerState>(
      listenWhen: (previous, current) =>
          current is AdaptationCompleted || current is PlannerError,
      listener: (context, state) {
        if (state is AdaptationCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRtl
                    ? 'تم تكييف الجدول بنجاح! ${state.result.sessionsAffected} جلسة متأثرة'
                    : 'Schedule adapted! ${state.result.sessionsAffected} sessions affected',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: isRtl ? 'التفاصيل' : 'Details',
                textColor: Colors.white,
                onPressed: () {
                  _showAdaptationDetails(context, state);
                },
              ),
            ),
          );
          onAdaptationComplete?.call();
        } else if (state is PlannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      buildWhen: (previous, current) => current is AdaptationInProgress,
      builder: (context, state) {
        final isLoading = state is AdaptationInProgress;

        if (iconOnly) {
          return IconButton(
            onPressed: isLoading
                ? null
                : () => _triggerAdaptation(context),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high),
            tooltip: isRtl ? 'تكييف الجدول' : 'Adapt Schedule',
          );
        }

        return ElevatedButton.icon(
          onPressed: isLoading ? null : () => _triggerAdaptation(context),
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_fix_high),
          label: Text(
            isRtl ? 'تكييف الجدول' : 'Adapt Schedule',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        );
      },
    );
  }

  void _triggerAdaptation(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.auto_fix_high, size: 48, color: Colors.amber),
        title: Text(isRtl ? 'تكييف الجدول؟' : 'Adapt Schedule?'),
        content: Text(
          isRtl
              ? 'سيتم تحليل أدائك وتعديل الجدول الدراسي بناءً على:\n\n• نتائج الامتحانات\n• أوقات الدراسة المفضلة\n• معدل إتمام الجلسات\n\nهل تريد المتابعة؟'
              : 'Your schedule will be analyzed and adjusted based on:\n\n• Exam results\n• Preferred study times\n• Session completion rate\n\nDo you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<PlannerBloc>().add(const TriggerAdaptationEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text(isRtl ? 'تكييف' : 'Adapt'),
          ),
        ],
      ),
    );
  }

  void _showAdaptationDetails(BuildContext context, AdaptationCompleted state) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'نتائج التكييف' : 'Adaptation Results',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isRtl
                              ? '${state.result.sessionsAffected} جلسة متأثرة'
                              : '${state.result.sessionsAffected} sessions affected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Adaptations list
            Expanded(
              child: state.result.adaptations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: Colors.green.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRtl
                                ? 'جدولك الحالي مثالي!'
                                : 'Your current schedule is optimal!',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.result.adaptations.length,
                      itemBuilder: (_, index) {
                        final change = state.result.adaptations[index];
                        return _buildAdaptationChangeCard(
                          context,
                          change,
                          isRtl,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptationChangeCard(
    BuildContext context,
    dynamic change,
    bool isRtl,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (change.type) {
      case 'rescheduled':
        icon = Icons.schedule;
        color = Colors.blue;
        break;
      case 'duration_changed':
        icon = Icons.timer;
        color = Colors.orange;
        break;
      case 'priority_adjusted':
        icon = Icons.priority_high;
        color = Colors.purple;
        break;
      case 'added':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'removed':
        icon = Icons.remove_circle;
        color = Colors.red;
        break;
      default:
        icon = Icons.auto_fix_high;
        color = Colors.amber;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          isRtl ? change.descriptionAr : change.description,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: change.subjectName != null
            ? Text(
                change.subjectName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            : null,
        trailing: change.oldValue != null && change.newValue != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    change.oldValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    change.newValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
