import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/exams_bloc.dart';
import '../bloc/exams_event.dart';
import '../bloc/exams_state.dart';
import '../../domain/entities/exam.dart';

/// Screen for recording exam results
class ExamResultScreen extends StatefulWidget {
  final Exam exam;

  const ExamResultScreen({
    super.key,
    required this.exam,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _maxScoreController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  double? _percentage;
  String? _grade;
  String? _gradeAr;

  @override
  void initState() {
    super.initState();
    // Default max score is 20 (Algerian system)
    _maxScoreController.text = '20';
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _maxScoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateGrade() {
    final score = double.tryParse(_scoreController.text);
    final maxScore = double.tryParse(_maxScoreController.text);

    if (score != null && maxScore != null && maxScore > 0) {
      final pct = (score / maxScore) * 100;
      setState(() {
        _percentage = pct;
        if (pct >= 80) {
          _grade = 'Excellent';
          _gradeAr = 'ممتاز';
        } else if (pct >= 70) {
          _grade = 'Very Good';
          _gradeAr = 'جيد جداً';
        } else if (pct >= 60) {
          _grade = 'Good';
          _gradeAr = 'جيد';
        } else if (pct >= 50) {
          _grade = 'Pass';
          _gradeAr = 'مقبول';
        } else {
          _grade = 'Fail';
          _gradeAr = 'راسب';
        }
      });
    } else {
      setState(() {
        _percentage = null;
        _grade = null;
        _gradeAr = null;
      });
    }
  }

  void _submitResult() {
    if (_formKey.currentState?.validate() ?? false) {
      final score = double.parse(_scoreController.text);
      final maxScore = double.parse(_maxScoreController.text);
      final notes = _notesController.text.isEmpty ? null : _notesController.text;

      setState(() => _isLoading = true);

      context.read<ExamsBloc>().add(
        RecordExamResultEvent(
          examId: widget.exam.id,
          score: score,
          maxScore: maxScore,
          notes: notes,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocListener<ExamsBloc, ExamsState>(
      listener: (context, state) {
        if (state is ExamResultRecorded) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRtl ? 'تم تسجيل النتيجة بنجاح!' : 'Result recorded successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Show adaptation dialog if triggered
          if (state.adaptationTriggered) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                icon: const Icon(Icons.auto_fix_high, size: 48, color: Colors.amber),
                title: Text(isRtl ? 'تم تكييف الجدول' : 'Schedule Adapted'),
                content: Text(
                  isRtl
                      ? 'تم تعديل جدولك الدراسي بناءً على نتيجة الامتحان.'
                      : 'Your study schedule has been adjusted based on the exam result.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(isRtl ? 'حسناً' : 'OK'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.of(context).pop(true);
          }
        } else if (state is ExamsError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isRtl ? 'تسجيل النتيجة' : 'Record Result'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Exam Info Card
                _buildExamInfoCard(theme, isRtl),
                const SizedBox(height: 24),

                // Score Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _scoreController,
                        decoration: InputDecoration(
                          labelText: isRtl ? 'النقطة' : 'Score',
                          hintText: isRtl ? 'أدخل النقطة' : 'Enter score',
                          prefixIcon: const Icon(Icons.grade),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isRtl ? 'مطلوب' : 'Required';
                          }
                          final score = double.tryParse(value);
                          if (score == null) {
                            return isRtl ? 'رقم غير صالح' : 'Invalid number';
                          }
                          final maxScore = double.tryParse(_maxScoreController.text) ?? 20;
                          if (score < 0 || score > maxScore) {
                            return isRtl ? 'يجب أن تكون بين 0 و $maxScore' : 'Must be between 0 and $maxScore';
                          }
                          return null;
                        },
                        onChanged: (_) => _calculateGrade(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '/',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxScoreController,
                        decoration: InputDecoration(
                          labelText: isRtl ? 'من' : 'Max',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isRtl ? 'مطلوب' : 'Required';
                          }
                          final maxScore = double.tryParse(value);
                          if (maxScore == null || maxScore <= 0) {
                            return isRtl ? 'رقم غير صالح' : 'Invalid';
                          }
                          return null;
                        },
                        onChanged: (_) => _calculateGrade(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grade Preview
                if (_percentage != null && _grade != null) ...[
                  _buildGradePreview(theme, isRtl),
                  const SizedBox(height: 24),
                ],

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: isRtl ? 'ملاحظات (اختياري)' : 'Notes (optional)',
                    hintText: isRtl ? 'أضف ملاحظات...' : 'Add notes...',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitResult,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isRtl ? 'حفظ النتيجة' : 'Save Result',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamInfoCard(ThemeData theme, bool isRtl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.exam.subjectName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.book,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.exam.subjectName,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.exam.examDate.day}/${widget.exam.examDate.month}/${widget.exam.examDate.year}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradePreview(ThemeData theme, bool isRtl) {
    Color gradeColor;
    if (_percentage! >= 70) {
      gradeColor = Colors.green;
    } else if (_percentage! >= 50) {
      gradeColor = Colors.orange;
    } else {
      gradeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${_percentage!.toStringAsFixed(1)}%',
            style: theme.textTheme.displaySmall?.copyWith(
              color: gradeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: gradeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRtl ? _gradeAr! : _grade!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
