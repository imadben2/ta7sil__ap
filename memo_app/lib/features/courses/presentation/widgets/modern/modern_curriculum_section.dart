import 'package:flutter/material.dart';
import '../../../domain/entities/course_module_entity.dart';
import '../../../domain/entities/course_lesson_entity.dart';
import 'modern_lesson_item.dart';

/// Modern curriculum section with gradient header design
/// Shows expandable modules with lesson checklists
class ModernCurriculumSection extends StatefulWidget {
  final List<CourseModuleEntity> modules;
  final bool hasAccess;
  final Set<int> completedLessonIds;
  final Function(CourseLessonEntity)? onLessonTap;
  final int? initialExpandedModuleId;

  const ModernCurriculumSection({
    super.key,
    required this.modules,
    required this.hasAccess,
    this.completedLessonIds = const {},
    this.onLessonTap,
    this.initialExpandedModuleId,
  });

  @override
  State<ModernCurriculumSection> createState() =>
      _ModernCurriculumSectionState();
}

class _ModernCurriculumSectionState extends State<ModernCurriculumSection> {
  late Set<int> _expandedModuleIds;

  @override
  void initState() {
    super.initState();
    _expandedModuleIds = {};
    if (widget.initialExpandedModuleId != null) {
      _expandedModuleIds.add(widget.initialExpandedModuleId!);
    } else if (widget.modules.isNotEmpty) {
      // Expand first module by default
      _expandedModuleIds.add(widget.modules.first.id);
    }
  }

  void _toggleModule(int moduleId) {
    setState(() {
      if (_expandedModuleIds.contains(moduleId)) {
        _expandedModuleIds.remove(moduleId);
      } else {
        _expandedModuleIds.add(moduleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header
            _buildGradientHeader(),

            // Modules
            ...widget.modules.asMap().entries.map((entry) {
              final index = entry.key;
              final module = entry.value;
              final isExpanded = _expandedModuleIds.contains(module.id);
              final isLast = index == widget.modules.length - 1;

              return _ModuleAccordion(
                module: module,
                isExpanded: isExpanded,
                onToggle: () => _toggleModule(module.id),
                hasAccess: widget.hasAccess,
                completedLessonIds: widget.completedLessonIds,
                onLessonTap: widget.onLessonTap,
                showBottomBorder: !isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    final totalLessons = widget.modules.fold<int>(
      0,
      (sum, module) => sum + (module.lessons?.length ?? module.totalLessons ?? 0),
    );
    final completedCount = widget.completedLessonIds.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Content
          Row(
            children: [
              // Icon with glass effect
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محتوى الدورة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.modules.length} وحدات • $totalLessons درس',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Circle
              if (completedCount > 0)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
}

class _ModuleAccordion extends StatelessWidget {
  final CourseModuleEntity module;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool hasAccess;
  final Set<int> completedLessonIds;
  final Function(CourseLessonEntity)? onLessonTap;
  final bool showBottomBorder;

  const _ModuleAccordion({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
    required this.hasAccess,
    required this.completedLessonIds,
    this.onLessonTap,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final lessons = module.lessons ?? [];
    final completedInModule = lessons
        .where((l) => completedLessonIds.contains(l.id))
        .length;
    final isModuleComplete = completedInModule > 0 && completedInModule == lessons.length;

    return Column(
      children: [
        // Module Header
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: isExpanded
                  ? LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.08),
                        const Color(0xFF8B5CF6).withOpacity(0.04),
                      ],
                    )
                  : null,
              border: showBottomBorder && !isExpanded
                  ? const Border(
                      bottom: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Module Number Badge with gradient
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isExpanded
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF8B5CF6),
                            ],
                          )
                        : null,
                    color: isExpanded ? null : const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isExpanded
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${module.order}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isExpanded
                            ? Colors.white
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Module Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.titleAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isExpanded
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 13,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lessons.length} دروس',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (completedInModule > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$completedInModule مكتمل',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Module Complete Badge
                if (isModuleComplete)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),

                // Expand Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? const Color(0xFF3B82F6).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? const Color(0xFF3B82F6)
                          : Colors.grey[500],
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lessons List
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            decoration: showBottomBorder
                ? const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  )
                : null,
            child: Column(
              children: lessons.asMap().entries.map((entry) {
                final index = entry.key;
                final lesson = entry.value;
                final isCompleted = completedLessonIds.contains(lesson.id);

                LessonStatus status;
                if (isCompleted) {
                  status = LessonStatus.completed;
                } else if (hasAccess || lesson.isFreePreview) {
                  status = LessonStatus.available;
                } else {
                  status = LessonStatus.locked;
                }

                return ModernLessonItem(
                  lesson: lesson,
                  status: status,
                  lessonNumber: index + 1,
                  onTap: onLessonTap != null
                      ? () => onLessonTap!(lesson)
                      : null,
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
