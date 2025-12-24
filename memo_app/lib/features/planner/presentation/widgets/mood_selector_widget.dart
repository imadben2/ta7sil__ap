import 'package:flutter/material.dart';

/// Widget for selecting mood after completing a study session
/// Supports 3 mood states: happy, neutral, sad
/// RTL-compatible with Arabic labels
class MoodSelectorWidget extends StatefulWidget {
  final Function(String mood) onMoodSelected;
  final String? initialMood;

  const MoodSelectorWidget({
    Key? key,
    required this.onMoodSelected,
    this.initialMood,
  }) : super(key: key);

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget> {
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كيف كانت جلسة الدراسة؟',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMoodButton(
              mood: 'positive',
              emoji: '😊',
              label: 'إيجابي',
              color: Colors.green,
              colorScheme: colorScheme,
            ),
            _buildMoodButton(
              mood: 'neutral',
              emoji: '😐',
              label: 'عادي',
              color: Colors.orange,
              colorScheme: colorScheme,
            ),
            _buildMoodButton(
              mood: 'negative',
              emoji: '😟',
              label: 'سلبي',
              color: Colors.red,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodButton({
    required String mood,
    required String emoji,
    required String label,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedMood == mood;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Material(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedMood = mood;
              });
              widget.onMoodSelected(mood);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? color
                      : colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: TextStyle(fontSize: isSelected ? 48 : 40)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : colorScheme.onSurface,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact version for smaller spaces
class CompactMoodSelector extends StatelessWidget {
  final Function(String mood) onMoodSelected;
  final String? selectedMood;

  const CompactMoodSelector({
    Key? key,
    required this.onMoodSelected,
    this.selectedMood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactMoodButton(context: context, mood: 'positive', emoji: '😊'),
        const SizedBox(width: 8),
        _buildCompactMoodButton(context: context, mood: 'neutral', emoji: '😐'),
        const SizedBox(width: 8),
        _buildCompactMoodButton(context: context, mood: 'negative', emoji: '😟'),
      ],
    );
  }

  Widget _buildCompactMoodButton({
    required BuildContext context,
    required String mood,
    required String emoji,
  }) {
    final isSelected = selectedMood == mood;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onMoodSelected(mood),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 24)),
      ),
    );
  }
}
