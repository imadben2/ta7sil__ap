import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/subject.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/app_colors.dart';

/// Modern screen for adding/editing exams
class AddExamScreen extends StatefulWidget {
  final Exam? exam; // null for new exam, non-null for editing
  final List<Subject> subjects;

  const AddExamScreen({super.key, this.exam, required this.subjects});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  Subject? _selectedSubject;
  ExamType _examType = ExamType.test;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay? _selectedTime;
  int _durationMinutes = 120;
  ImportanceLevel _importanceLevel = ImportanceLevel.medium;
  int _preparationDays = 7;
  double? _targetScore;
  final List<String> _selectedChapters = [];

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _loadExamData();
    } else if (widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.first;
    }
  }

  void _loadExamData() {
    final exam = widget.exam!;
    _selectedSubject = widget.subjects.firstWhere(
      (s) => s.id == exam.subjectId,
      orElse: () => widget.subjects.first,
    );
    _examType = exam.examType;
    _selectedDate = exam.examDate;
    _selectedTime = exam.examTime;
    _durationMinutes = exam.durationMinutes;
    _importanceLevel = exam.importanceLevel;
    _preparationDays = exam.preparationDaysBefore;
    _targetScore = exam.targetScore;
    if (exam.chaptersCovered != null) {
      _selectedChapters.addAll(exam.chaptersCovered!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exam != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'تعديل الامتحان' : 'إضافة امتحان جديد',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => context.go('/home'),
            tooltip: 'الصفحة الرئيسية',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Header card with icon
            _buildHeaderCard(),

            const SizedBox(height: 24),

            // Subject selection
            _buildSubjectSelection(),

            const SizedBox(height: 20),

            // Exam type
            _buildExamTypeSelection(),

            const SizedBox(height: 20),

            // Date and time
            _buildDateTimeSection(),

            const SizedBox(height: 20),

            // Duration
            _buildDurationSection(),

            const SizedBox(height: 16),

            // Importance level
            _buildImportanceSection(),

            const SizedBox(height: 16),

            // Preparation days
            _buildPreparationSection(),

            const SizedBox(height: 16),

            // Target score (optional)
            _buildTargetScoreSection(),

            const SizedBox(height: 24),

            // Save button
            _buildSaveButton(isEdit),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظيم الامتحانات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أضف امتحاناتك للتخطيط الأفضل',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primaryLight.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'المادة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.red500,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Subject>(
            initialValue: _selectedSubject,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2.5,
                ),
              ),
            ),
            items: widget.subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(
                  subject.name,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار المادة';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.15),
                      AppColors.primaryLight.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'نوع الامتحان',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            // Filter out quiz type - only show test, exam, finalExam
            children: ExamType.values
                .where((type) => type != ExamType.quiz)
                .map((type) {
              final isSelected = _examType == type;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _examType = type;
                      // Auto-adjust importance based on exam type
                      if (type == ExamType.finalExam) {
                        _importanceLevel = ImportanceLevel.critical;
                        _preparationDays = 14;
                      } else if (type == ExamType.exam) {
                        _importanceLevel = ImportanceLevel.high;
                        _preparationDays = 10;
                      } else if (type == ExamType.test) {
                        _importanceLevel = ImportanceLevel.medium;
                        _preparationDays = 7;
                      } else {
                        _importanceLevel = ImportanceLevel.low;
                        _preparationDays = 3;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        Text(
                          _getExamTypeLabel(type),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF374151),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.emerald500.withOpacity(0.15),
                      AppColors.emerald500.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'التاريخ والوقت',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Date picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ar'),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.emerald500,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      DateFormat(
                        'EEEE، d MMMM yyyy',
                        'ar',
                      ).format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Time picker (optional)
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    _selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.emerald500,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'وقت الامتحان (اختياري)',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Cairo',
                      color: _selectedTime != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
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

  Widget _buildDurationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: AppColors.blue500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'مدة الامتحان',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_durationMinutes دقيقة',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: AppColors.blue500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _durationMinutes.toDouble(),
                      min: 30,
                      max: 240,
                      divisions: 21,
                      activeColor: AppColors.blue500,
                      label: '$_durationMinutes دقيقة',
                      onChanged: (value) {
                        setState(() {
                          _durationMinutes = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '30د',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '240د',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'مستوى الأهمية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ImportanceLevel.values.map((level) {
            final isSelected = _importanceLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _importanceLevel = level;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getImportanceColor(level).withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getImportanceColor(level)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _getImportanceColor(level),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getImportanceLabel(level),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Cairo',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? _getImportanceColor(level)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreparationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.amber500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'أيام التحضير',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_preparationDays يوم',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: AppColors.amber500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _preparationDays.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: AppColors.amber500,
                      label: '$_preparationDays يوم',
                      onChanged: (value) {
                        setState(() {
                          _preparationDays = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'يوم واحد',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '30 يوم',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetScoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'الدرجة المستهدفة (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _targetScore?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'مثال: 18.5',
              suffixText: '/ 20',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _targetScore = null;
              } else {
                _targetScore = double.tryParse(value);
              }
            },
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final score = double.tryParse(value);
                if (score == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                if (score < 0 || score > 20) {
                  return 'الدرجة يجب أن تكون بين 0 و 20';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveExam,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEdit ? Icons.check_rounded : Icons.add_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              isEdit ? 'حفظ التعديلات' : 'إضافة الامتحان',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExam() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى اختيار المادة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current user ID from AuthBloc
      final authState = context.read<AuthBloc>().state;
      final String userId;
      if (authState is Authenticated) {
        userId = authState.user.id.toString();
      } else {
        // Fallback: should not happen if auth is required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create exam object
      final exam = Exam(
        id: widget.exam?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        subjectId: _selectedSubject!.id,
        subjectName: _selectedSubject!.name,
        examType: _examType,
        examDate: _selectedDate,
        examTime: _selectedTime,
        durationMinutes: _durationMinutes,
        importanceLevel: _importanceLevel,
        preparationDaysBefore: _preparationDays,
        targetScore: _targetScore,
        chaptersCovered: _selectedChapters.isEmpty ? null : _selectedChapters,
      );

      // Return the exam
      Navigator.pop(context, exam);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.exam != null
                      ? 'تم تحديث الامتحان بنجاح'
                      : 'تم إضافة الامتحان بنجاح',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.emerald500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _getExamTypeLabel(ExamType type) {
    switch (type) {
      case ExamType.quiz:
        return 'اختبار قصير';
      case ExamType.test:
        return 'فرض';
      case ExamType.exam:
        return 'امتحان';
      case ExamType.finalExam:
        return 'امتحان نهائي';
    }
  }

  Color _getImportanceColor(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.critical:
        return Colors.red;
      case ImportanceLevel.high:
        return Colors.orange;
      case ImportanceLevel.medium:
        return Colors.blue;
      case ImportanceLevel.low:
        return Colors.grey;
    }
  }

  String _getImportanceLabel(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.critical:
        return 'حرج جداً';
      case ImportanceLevel.high:
        return 'مهم';
      case ImportanceLevel.medium:
        return 'متوسط';
      case ImportanceLevel.low:
        return 'عادي';
    }
  }
}
