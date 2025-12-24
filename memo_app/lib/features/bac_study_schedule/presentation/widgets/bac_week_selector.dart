import 'package:flutter/material.dart';

/// Modern horizontal week selector with pill-style design
class BacWeekSelector extends StatefulWidget {
  final int selectedWeek;
  final int totalWeeks;
  final int currentWeek;
  final ValueChanged<int> onWeekSelected;

  const BacWeekSelector({
    super.key,
    required this.selectedWeek,
    required this.totalWeeks,
    required this.currentWeek,
    required this.onWeekSelected,
  });

  @override
  State<BacWeekSelector> createState() => _BacWeekSelectorState();
}

class _BacWeekSelectorState extends State<BacWeekSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Auto-scroll to selected week after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedWeek();
    });
  }

  @override
  void didUpdateWidget(BacWeekSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _scrollToSelectedWeek();
    }
  }

  void _scrollToSelectedWeek() {
    if (!_scrollController.hasClients) return;
    final itemWidth = 72.0; // width + margin
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (widget.selectedWeek - 1) * itemWidth -
        (screenWidth / 2) + (itemWidth / 2);
    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.date_range_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'الأسابيع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الأسبوع ${widget.currentWeek}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Week pills
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: widget.totalWeeks,
              itemBuilder: (context, index) {
                final weekNumber = index + 1;
                return _WeekPill(
                  weekNumber: weekNumber,
                  isSelected: weekNumber == widget.selectedWeek,
                  isCurrent: weekNumber == widget.currentWeek,
                  isPast: weekNumber < widget.currentWeek,
                  onTap: () => widget.onWeekSelected(weekNumber),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekPill extends StatelessWidget {
  final int weekNumber;
  final bool isSelected;
  final bool isCurrent;
  final bool isPast;
  final VoidCallback onTap;

  const _WeekPill({
    required this.weekNumber,
    required this.isSelected,
    required this.isCurrent,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 64,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFFA855F7),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isPast
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isCurrent && !isSelected
              ? Border.all(
                  color: const Color(0xFF8B5CF6),
                  width: 2,
                )
              : isSelected
                  ? null
                  : Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Week number with animated styling
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: isSelected ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isPast
                            ? const Color(0xFF10B981)
                            : const Color(0xFF334155),
                  ),
                  child: Text('$weekNumber'),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : isPast
                            ? const Color(0xFF10B981).withOpacity(0.7)
                            : const Color(0xFF94A3B8),
                  ),
                  child: const Text('أسبوع'),
                ),
              ],
            ),
            // Completion indicator for past weeks
            if (isPast && !isSelected)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            // Current week indicator
            if (isCurrent && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
