import 'package:flutter/material.dart';
import '../../domain/entities/subject.dart';

/// Dialog for selecting subjects to include in schedule generation
///
/// Displays a checkbox list of all available subjects with:
/// - Subject name and coefficient
/// - Select all / Deselect all buttons
/// - RTL Arabic layout
class SubjectSelectionDialog extends StatefulWidget {
  final List<Subject> allSubjects;
  final List<String> selectedSubjectIds;
  final Function(List<String>) onSelectionChanged;

  const SubjectSelectionDialog({
    Key? key,
    required this.allSubjects,
    required this.selectedSubjectIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<SubjectSelectionDialog> createState() => _SubjectSelectionDialogState();

  /// Show the dialog and return selected subject IDs
  static Future<List<String>?> show({
    required BuildContext context,
    required List<Subject> allSubjects,
    required List<String> selectedSubjectIds,
  }) {
    return showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        List<String> currentSelection = List.from(selectedSubjectIds);

        return SubjectSelectionDialog(
          allSubjects: allSubjects,
          selectedSubjectIds: currentSelection,
          onSelectionChanged: (ids) {
            currentSelection = ids;
          },
        );
      },
    );
  }
}

class _SubjectSelectionDialogState extends State<SubjectSelectionDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    // If no subjects selected initially, select all
    if (widget.selectedSubjectIds.isEmpty) {
      _selectedIds = widget.allSubjects.map((s) => s.id).toSet();
    } else {
      _selectedIds = widget.selectedSubjectIds.toSet();
    }
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      if (_selectedIds.contains(subjectId)) {
        _selectedIds.remove(subjectId);
      } else {
        _selectedIds.add(subjectId);
      }
    });
    widget.onSelectionChanged(_selectedIds.toList());
  }

  void _selectAll() {
    setState(() {
      _selectedIds = widget.allSubjects.map((s) => s.id).toSet();
    });
    widget.onSelectionChanged(_selectedIds.toList());
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
    });
    widget.onSelectionChanged(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),

              // Subject list
              Flexible(
                child: _buildSubjectList(),
              ),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختيار المواد للجدول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_selectedIds.length} من ${widget.allSubjects.length} مادة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    // Sort subjects by coefficient (descending)
    final sortedSubjects = List<Subject>.from(widget.allSubjects)
      ..sort((a, b) => b.coefficient.compareTo(a.coefficient));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select all / Deselect all buttons
          Row(
            children: [
              TextButton.icon(
                onPressed: _selectAll,
                icon: const Icon(Icons.select_all, size: 18),
                label: const Text(
                  'تحديد الكل',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _deselectAll,
                icon: const Icon(Icons.deselect, size: 18),
                label: const Text(
                  'إلغاء التحديد',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Subject list
          Expanded(
            child: ListView.builder(
              itemCount: sortedSubjects.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final subject = sortedSubjects[index];
                final isSelected = _selectedIds.contains(subject.id);

                return _buildSubjectTile(subject, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject, bool isSelected) {
    final color = subject.color ?? const Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _toggleSubject(subject.id),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.5)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, color.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // Color indicator
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Subject info
              Expanded(
                child: Text(
                  subject.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : const Color(0xFF374151),
                  ),
                ),
              ),

              // Coefficient badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'معامل: ${subject.coefficient}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canConfirm = _selectedIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Confirm button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canConfirm
                  ? () => Navigator.pop(context, _selectedIds.toList())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFE5E7EB),
                foregroundColor: canConfirm
                    ? Colors.white
                    : const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: canConfirm
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تأكيد (${_selectedIds.length})',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for quick subject selection in schedule wizard
class SubjectSelectionChips extends StatelessWidget {
  final List<Subject> allSubjects;
  final List<String> selectedSubjectIds;
  final Function(List<String>) onSelectionChanged;

  const SubjectSelectionChips({
    Key? key,
    required this.allSubjects,
    required this.selectedSubjectIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allSubjects.map((subject) {
        final isSelected = selectedSubjectIds.contains(subject.id);
        final color = subject.color ?? const Color(0xFF6366F1);

        return FilterChip(
          label: Text(
            subject.name,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : color,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = List<String>.from(selectedSubjectIds);
            if (selected) {
              newSelection.add(subject.id);
            } else {
              newSelection.remove(subject.id);
            }
            onSelectionChanged(newSelection);
          },
          selectedColor: color,
          backgroundColor: color.withOpacity(0.1),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? color : color.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }
}
