import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Bottom sheet for filtering quizzes
class QuizFilterSheet extends StatefulWidget {
  final bool academicFilter;
  final bool mySubjectsOnly;
  final int? selectedSubjectId;
  final int? selectedChapterId;
  final String? selectedQuizType;
  final String? selectedDifficulty;
  final Function({
    bool? academicFilter,
    bool? mySubjectsOnly,
    int? subjectId,
    int? chapterId,
    String? quizType,
    String? difficulty,
  })
  onApplyFilters;

  const QuizFilterSheet({
    super.key,
    required this.academicFilter,
    required this.mySubjectsOnly,
    this.selectedSubjectId,
    this.selectedChapterId,
    this.selectedQuizType,
    this.selectedDifficulty,
    required this.onApplyFilters,
  });

  @override
  State<QuizFilterSheet> createState() => _QuizFilterSheetState();
}

class _QuizFilterSheetState extends State<QuizFilterSheet> {
  late bool _academicFilter;
  late bool _mySubjectsOnly;
  String? _selectedQuizType;
  String? _selectedDifficulty;

  final List<Map<String, String>> _quizTypes = [
    {'value': 'practice', 'label': 'تدريب'},
    {'value': 'timed', 'label': 'محدود بوقت'},
    {'value': 'exam', 'label': 'امتحان'},
  ];

  final List<Map<String, String>> _difficulties = [
    {'value': 'easy', 'label': 'سهل'},
    {'value': 'medium', 'label': 'متوسط'},
    {'value': 'hard', 'label': 'صعب'},
  ];

  @override
  void initState() {
    super.initState();
    _academicFilter = widget.academicFilter;
    _mySubjectsOnly = widget.mySubjectsOnly;
    _selectedQuizType = widget.selectedQuizType;
    _selectedDifficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تصفية الاختبارات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Academic Filter Toggle
          _buildSwitchTile(
            title: 'تصفية حسب مستواي الدراسي',
            subtitle: 'عرض الاختبارات المتعلقة بمستواي وشعبتي فقط',
            value: _academicFilter,
            onChanged: (value) => setState(() => _academicFilter = value),
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 16),
          // My Subjects Only Toggle
          _buildSwitchTile(
            title: 'موادي المختارة فقط',
            subtitle: 'عرض اختبارات المواد التي أتابعها',
            value: _mySubjectsOnly,
            onChanged: (value) => setState(() => _mySubjectsOnly = value),
            icon: Icons.bookmark_rounded,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Quiz Type Filter
          const Text(
            'نوع الاختبار',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quizTypes.map((type) {
              final isSelected = _selectedQuizType == type['value'];
              return _buildChip(
                label: type['label']!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedQuizType = isSelected ? null : type['value'];
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Difficulty Filter
          const Text(
            'مستوى الصعوبة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _difficulties.map((diff) {
              final isSelected = _selectedDifficulty == diff['value'];
              return _buildChip(
                label: diff['label']!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedDifficulty = isSelected ? null : diff['value'];
                  });
                },
                color: _getDifficultyColor(diff['value']!),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text(
                    'مسح الكل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تطبيق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.textHint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _clearFilters() {
    setState(() {
      _academicFilter = true;
      _mySubjectsOnly = false;
      _selectedQuizType = null;
      _selectedDifficulty = null;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      academicFilter: _academicFilter,
      mySubjectsOnly: _mySubjectsOnly,
      quizType: _selectedQuizType,
      difficulty: _selectedDifficulty,
    );
    Navigator.pop(context);
  }
}
