import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/centralized_subject.dart';
import '../bloc/subjects_bloc.dart';
import '../bloc/subjects_event.dart';
import '../bloc/subjects_state.dart';

/// Dropdown selector for centralized subjects
///
/// Displays subjects in format: "المادة (معامل X)"
/// Shows coefficient badges for each subject
class SubjectDropdownSelector extends StatelessWidget {
  final CentralizedSubject? selectedSubject;
  final ValueChanged<CentralizedSubject?> onChanged;
  final String? hint;
  final bool enabled;

  const SubjectDropdownSelector({
    Key? key,
    this.selectedSubject,
    required this.onChanged,
    this.hint,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectsBloc, SubjectsState>(
      builder: (context, state) {
        if (state is CentralizedSubjectsLoading) {
          return const _LoadingDropdown();
        }

        if (state is CentralizedSubjectsError) {
          return _ErrorDropdown(
            message: state.message,
            onRetry: () {
              context.read<SubjectsBloc>().add(
                const LoadCentralizedSubjectsEvent(),
              );
            },
          );
        }

        if (state is CentralizedSubjectsLoaded) {
          return _SubjectsDropdown(
            subjects: state.centralizedSubjects,
            selectedSubject: selectedSubject,
            onChanged: enabled ? onChanged : null,
            hint: hint ?? 'اختر المادة',
          );
        }

        // Initial state - load subjects
        context.read<SubjectsBloc>().add(const LoadCentralizedSubjectsEvent());
        return const _LoadingDropdown();
      },
    );
  }
}

class _SubjectsDropdown extends StatelessWidget {
  final List<CentralizedSubject> subjects;
  final CentralizedSubject? selectedSubject;
  final ValueChanged<CentralizedSubject?>? onChanged;
  final String hint;

  const _SubjectsDropdown({
    Key? key,
    required this.subjects,
    this.selectedSubject,
    this.onChanged,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CentralizedSubject>(
      value: selectedSubject,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      isExpanded: true,
      items: subjects.map((subject) {
        return DropdownMenuItem<CentralizedSubject>(
          value: subject,
          child: _SubjectItem(subject: subject),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text(hint),
    );
  }
}

class _SubjectItem extends StatelessWidget {
  final CentralizedSubject subject;

  const _SubjectItem({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Subject icon if available
        if (subject.icon != null) ...[
          Icon(
            _getIconData(subject.icon!),
            size: 20,
            color: _parseColor(subject.color),
          ),
          const SizedBox(width: 8),
        ],
        // Subject name
        Expanded(
          child: Text(
            subject.nameAr,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Coefficient badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _parseColor(subject.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _parseColor(subject.color).withOpacity(0.3),
            ),
          ),
          child: Text(
            'معامل ${subject.coefficient.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _parseColor(subject.color),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.grey;
    try {
      final hexColor = colorString.replaceAll('#', '');
      final colorValue = hexColor.length == 6 ? 'FF$hexColor' : hexColor;
      return Color(int.parse(colorValue, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'book':
        return Icons.book;
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;
      case 'history_edu':
        return Icons.history_edu;
      case 'language':
        return Icons.language;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.book;
    }
  }
}

class _LoadingDropdown extends StatelessWidget {
  const _LoadingDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('جاري تحميل المواد...'),
        ],
      ),
    );
  }
}

class _ErrorDropdown extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorDropdown({Key? key, required this.message, required this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
        color: Colors.red.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'خطأ: $message',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
