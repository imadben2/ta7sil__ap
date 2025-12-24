# 🔄 Complete Migration Guide - Unified Design System

**Version:** 1.0.0
**Target:** 43 remaining pages across 7 features
**Estimated Time:** 3-5 hours total

---

## 📋 Table of Contents

1. [Migration Overview](#migration-overview)
2. [Feature-by-Feature Guide](#feature-by-feature-guide)
3. [Common Patterns](#common-patterns)
4. [Before & After Examples](#before--after-examples)
5. [Component Mapping Reference](#component-mapping-reference)
6. [Troubleshooting](#troubleshooting)

---

## Migration Overview

### Current Status
- ✅ **Foundation:** Complete (3 files)
- ✅ **Component Library:** Complete (15 components)
- ✅ **Reference Implementation:** home_page.dart complete
- ⏳ **Remaining:** 43 pages to migrate

### Migration Priority
1. **Auth Pages** (5) - Entry points
2. **Profile Pages** (6) - High traffic
3. **Quiz Pages** (5) - Core feature
4. **Courses Pages** (6) - Revenue
5. **Planner Pages** (13) - Complex feature
6. **BAC Archives** (5) - Special feature
7. **Content Library** (3) - Supporting

---

## Feature-by-Feature Guide

## 📱 Phase 4A: Auth Feature (5 Pages)

### File Locations
```
lib/features/auth/presentation/pages/
├── splash_page.dart
├── onboarding_page.dart
├── login_page.dart
├── register_page.dart
└── academic_selection_page.dart
```

### 1. splash_page.dart

**Changes Needed:**
- Replace gradient colors with Blue theme
- Use `GradientHelper.primaryHero` for background

**Before:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
  ),
)
```

**After:**
```dart
import '../../../../core/utils/gradient_helper.dart';

Container(
  decoration: BoxDecoration(
    gradient: GradientHelper.primaryVertical,
  ),
)
```

### 2. onboarding_page.dart

**Changes Needed:**
- Update page indicator dots to Blue
- Use `AppColors.primary` for active indicator
- Use design tokens for spacing

**Before:**
```dart
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: isActive ? Color(0xFF6366F1) : Colors.grey,
    shape: BoxShape.circle,
  ),
)
```

**After:**
```dart
import '../../../../core/constants/app_colors.dart';

Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: isActive ? AppColors.primary : Colors.grey[300],
    shape: BoxShape.circle,
  ),
)
```

### 3. login_page.dart

**Changes Needed:**
- Replace custom card with `GradientHeroCard` for logo section
- Use `AppColors.primary` for buttons
- Apply `AppDesignTokens` for spacing

**Migration Steps:**
1. Add imports:
```dart
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/widgets/cards/gradient_hero_card.dart';
```

2. Replace button colors:
```dart
// Before
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2196F3),
  ),
)

// After
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: AppDesignTokens.paddingButton,
  ),
)
```

### 4. register_page.dart

**Same as login_page.dart** - Apply identical changes

### 5. academic_selection_page.dart

**Changes Needed:**
- Use `ProgressCard` or `InfoCard` for stream selection
- Apply Blue color scheme

**Before:**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.grey[300]!),
  ),
  child: // Stream selection card
)
```

**After:**
```dart
import '../../../../core/widgets/cards/info_card.dart';

InfoCard(
  icon: Icons.school,
  iconColor: AppColors.primary,
  title: streamName,
  subtitle: streamDescription,
  onTap: () => selectStream(stream),
)
```

---

## 👤 Phase 4G: Profile Feature (6 Pages)

### File Locations
```
lib/features/profile/presentation/pages/
├── profile_page.dart
├── edit_profile_page.dart
├── statistics_page.dart
├── settings_page.dart
├── change_password_page.dart
└── devices_page.dart
```

### 1. profile_page.dart

**Priority:** HIGH (most visited)

**Changes Needed:**
- Hero stats section: Use `GradientHeroCard`
- Stats cards: Use `StatCardMini`
- Achievement badges: Use `LevelBadge` or `AchievementBadge`
- Settings items: Use `InfoCardListTile`

**Code Example:**
```dart
// Hero section with user stats
GradientHeroCard(
  gradient: GradientHelper.primaryHero,
  height: 180,
  child: Row(
    children: [
      CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(userAvatar),
      ),
      SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeTitle,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            LevelBadge(
              level: userLevel,
              style: LevelBadgeStyle.solid,
              color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    ],
  ),
)

// Stats row
Row(
  children: [
    Expanded(
      child: StatCardMini(
        icon: Icons.star,
        iconColor: AppColors.warningYellow,
        value: totalPoints.toString(),
        label: 'Points',
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: StatCardMini(
        icon: Icons.timer,
        iconColor: AppColors.successGreen,
        value: studyHours,
        label: 'Hours',
      ),
    ),
  ],
)
```

### 2. statistics_page.dart

**Changes Needed:**
- Use `StatCardMini` for metric cards
- Use `GradientHeroCard` for featured stats
- Charts should use `AppColors.primary` for main color

**Example:**
```dart
GridLayout(
  itemCount: stats.length,
  columnCount: 2,
  itemBuilder: (context, index) {
    return StatCardMini(
      icon: stats[index].icon,
      iconColor: AppColors.primary,
      value: stats[index].value,
      label: stats[index].label,
    );
  },
)
```

### 3. settings_page.dart

**Changes Needed:**
- Use `InfoCardListTile` for settings items
- Use `SectionHeader` for section titles

**Example:**
```dart
Column(
  children: [
    SectionHeader(title: 'Account'),
    InfoCardListTile(
      leadingIcon: Icons.person,
      title: 'Edit Profile',
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    ),
    InfoCardListTile(
      leadingIcon: Icons.lock,
      title: 'Change Password',
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    ),
  ],
)
```

### 4-6. Other Profile Pages

**edit_profile_page.dart, change_password_page.dart, devices_page.dart:**
- Use `PageScaffold` wrapper
- Apply `AppDesignTokens.paddingScreen`
- Use `InfoCard` for device cards
- Replace colors with `AppColors.*`

---

## 🎯 Phase 4E: Quiz Feature (5 Pages)

### File Locations
```
lib/features/quiz/presentation/pages/
├── quiz_list_page.dart
├── quiz_detail_page.dart
├── quiz_taking_page.dart
├── quiz_results_page.dart
└── quiz_review_page.dart
```

### 1. quiz_list_page.dart

**Changes Needed:**
- Use `InfoCard` for quiz cards in list
- Use `FilterChipGroup` for filtering
- Use `AppSearchBar` for search
- Use `SectionHeader` for sections

**Example:**
```dart
Column(
  children: [
    // Search bar
    AppSearchBar(
      hintText: 'Search quizzes...',
      onChanged: (query) => searchQuizzes(query),
    ),

    SizedBox(height: AppDesignTokens.spacingLG),

    // Filters
    FilterChipGroup(
      items: ['All', 'Math', 'Physics', 'Chemistry'],
      selectedIndex: selectedFilter,
      onSelected: (index) => filterQuizzes(index),
    ),

    SizedBox(height: AppDesignTokens.sectionSpacing),

    // Quiz list
    ...quizzes.map((quiz) => InfoCard(
      icon: Icons.quiz,
      iconColor: AppColors.primary,
      title: quiz.title,
      subtitle: '${quiz.questionCount} questions · ${quiz.duration}',
      trailing: Icon(Icons.chevron_right),
      onTap: () => navigateToQuiz(quiz),
    )).toList(),
  ],
)
```

### 2. quiz_detail_page.dart

**Changes Needed:**
- Hero section: Use `GradientHeroCard`
- Stats: Use `StatCardMiniHorizontal`
- Start button: Use `AppColors.primary`

**Example:**
```dart
GradientHeroCard(
  gradient: GradientHelper.primaryHero,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(quiz.title,
        style: TextStyle(
          fontSize: AppDesignTokens.fontSizeHeadline,
          color: Colors.white,
          fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text(quiz.description,
        style: TextStyle(color: Colors.white70)),
    ],
  ),
)

// Stats row
Row(
  children: [
    Expanded(
      child: StatCardMiniHorizontal(
        icon: Icons.quiz,
        iconColor: AppColors.primary,
        value: '${quiz.questionCount}',
        label: 'Questions',
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: StatCardMiniHorizontal(
        icon: Icons.timer,
        iconColor: AppColors.successGreen,
        value: quiz.duration,
        label: 'Duration',
      ),
    ),
  ],
)
```

### 3. quiz_taking_page.dart

**Changes Needed:**
- Progress bar: Use `AppColors.primary`
- Question cards: Use `InfoCard`
- Timer badge: Use `LiveTimerBadge`

### 4. quiz_results_page.dart

**Changes Needed:**
- Score display: Use `GradientHeroCard`
- Result stats: Use `StatCardMini`
- Score badge: Use `GradeBadge`

**Example:**
```dart
GradientHeroCard(
  gradient: scorePercentage >= 0.75
    ? GradientHelper.success
    : GradientHelper.primary,
  child: Column(
    children: [
      Text('Your Score',
        style: TextStyle(color: Colors.white)),
      SizedBox(height: 8),
      Text('${score}/${totalQuestions}',
        style: TextStyle(
          fontSize: AppDesignTokens.fontSizeDisplay,
          color: Colors.white,
          fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      GradeBadge(
        grade: score.toDouble(),
        maxGrade: totalQuestions.toDouble(),
      ),
    ],
  ),
)
```

### 5. quiz_review_page.dart

**Changes Needed:**
- Question cards: Use `InfoCard`
- Correct/Wrong indicators: Use `AppColors.success`/`AppColors.error`

---

## 🎓 Phase 4F: Courses Feature (6 Pages)

### File Locations
```
lib/features/courses/presentation/pages/
├── courses_page.dart
├── course_detail_page.dart
├── video_player_page.dart
├── subscriptions_page.dart
├── payment_receipt_page.dart
└── my_receipts_page.dart
```

### 1. courses_page.dart

**Changes Needed:**
- Course cards: Use `ProgressCard`
- Featured section: Use `GradientHeroCard`
- Search: Use `AppSearchBar`
- Filters: Use `FilterChipGroup`

### 2. course_detail_page.dart

**Changes Needed:**
- Hero section: Use `GradientHeroCard`
- Lesson list: Use `InfoCard`
- Progress: Use `ProgressCard`

### 3. subscriptions_page.dart

**Changes Needed:**
- Subscription cards: Use `InfoCard` with gradient background
- Price badges: Custom styling with `AppColors.primary`

**Example:**
```dart
InfoCard(
  icon: Icons.star,
  iconColor: AppColors.warningYellow,
  title: 'Premium Plan',
  subtitle: '\$9.99/month',
  trailing: Text('Popular',
    style: TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold)),
  onTap: () => selectPlan(plan),
)
```

### 4-6. Payment Pages

**payment_receipt_page.dart, my_receipts_page.dart:**
- Receipt cards: Use `InfoCard`
- Status badges: Use `StatBadge` or create custom status badges
- Use `AppColors.success` for completed payments

---

## 📅 Phase 4D: Planner Feature (13 Screens)

### File Locations
```
lib/features/planner/presentation/screens/
├── planner_main_screen.dart
├── today_view_screen.dart
├── week_view_screen.dart
├── full_schedule_screen.dart
├── schedule_wizard_screen.dart
├── session_detail_screen.dart
├── active_session_screen.dart
├── session_history_screen.dart
└── analytics_dashboard_screen.dart

lib/features/planner/presentation/pages/
├── subjects_page.dart
├── exams_page.dart
├── add_exam_screen.dart
└── planner_settings_page.dart
```

### Common Patterns for Planner

**Session Cards:**
```dart
SessionCard(
  subjectIcon: Icons.book,
  subjectGradient: GradientHelper.getSubjectGradient(subject.slug),
  subjectName: subject.name,
  sessionTitle: session.title,
  time: session.timeRange,
  duration: session.duration,
  status: session.status,
  statusColor: session.statusColor,
)
```

**Calendar Events:**
- Use `AppColors.primary` for primary events
- Use subject colors from `AppColors.getSubjectColor()`
- Use `TimeBadge` for time displays

**Analytics:**
- Use `StatCardMini` for metric displays
- Use `GradientHeroCard` for featured metrics
- Charts should use `AppColors.primary`

---

## 📚 Phase 4C: BAC Archives (5 Pages)

### File Locations
```
lib/features/bac/presentation/pages/
├── bac_archives_page.dart
├── bac_subject_detail_page.dart
├── bac_simulation_page.dart
├── bac_results_page.dart
└── bac_performance_page.dart
```

### 1. bac_archives_page.dart

**Changes Needed:**
- Year cards: Use `BacArchivesCard` or `BacArchivesCardCompact`
- Grid: Use `GridLayout`

**Example:**
```dart
GridLayout(
  itemCount: years.length,
  columnCount: 2,
  itemBuilder: (context, index) {
    return BacArchivesCardCompact(
      year: years[index].year,
      title: 'BAC ${years[index].year}',
      stats: '${years[index].examCount} Exams',
      gradient: GradientHelper.primary,
      onTap: () => navigateToYear(years[index]),
    );
  },
)
```

### 2-5. Other BAC Pages

- Use same components as Quiz pages
- Apply Blue theme throughout
- Use `ProgressCard` for subject progress
- Use `StatCardMini` for performance metrics

---

## 📖 Phase 4B: Content Library (3 Pages)

### File Locations
```
lib/features/content_library/presentation/pages/
├── subjects_list_page.dart
├── subject_detail_page.dart
└── content_viewer_page.dart
```

### Quick Migration

**subjects_list_page.dart:**
- Use `ProgressCard` in `GridLayout`

**subject_detail_page.dart:**
- Hero: `GradientHeroCard`
- Lessons: `InfoCard` list

**content_viewer_page.dart:**
- Keep as is, apply color fixes only

---

## Common Patterns

### Pattern 1: Page with Hero Section

```dart
PageScaffold(
  title: 'Page Title',
  body: Column(
    children: [
      GradientHeroCard(
        gradient: GradientHelper.primaryHero,
        child: // Hero content
      ),
      SizedBox(height: AppDesignTokens.sectionSpacing),
      SectionHeader(title: 'Section'),
      // Rest of content
    ],
  ),
)
```

### Pattern 2: List Page

```dart
Column(
  children: [
    AppSearchBar(hintText: 'Search...'),
    SizedBox(height: AppDesignTokens.spacingLG),
    FilterChipGroup(items: filters, selectedIndex: 0, onSelected: (_) {}),
    SizedBox(height: AppDesignTokens.sectionSpacing),
    ...items.map((item) => InfoCard(...)).toList(),
  ],
)
```

### Pattern 3: Grid Page

```dart
Column(
  children: [
    SectionHeader(title: 'Items', onViewAll: () {}),
    GridLayout(
      itemCount: items.length,
      itemBuilder: (context, index) => ProgressCard(...),
    ),
  ],
)
```

---

## Component Mapping Reference

| Old Pattern | New Component | Import |
|-------------|---------------|--------|
| Custom gradient card | `GradientHeroCard` | `cards/gradient_hero_card.dart` |
| Small stat display | `StatCardMini` | `cards/stat_card_mini.dart` |
| Subject/course card | `ProgressCard` | `cards/progress_card.dart` |
| Session display | `SessionCard` | `cards/session_card.dart` |
| Info/list card | `InfoCard` | `cards/info_card.dart` |
| Section title | `SectionHeader` | `layouts/section_header.dart` |
| Page wrapper | `PageScaffold` | `layouts/page_scaffold.dart` |
| Grid container | `GridLayout` | `layouts/grid_layout.dart` |
| Search input | `AppSearchBar` | `inputs/app_search_bar.dart` |
| Filter chips | `FilterChipGroup` | `inputs/filter_chip_group.dart` |
| `Color(0xFF6366F1)` | `AppColors.primary` | `constants/app_colors.dart` |
| Hardcoded spacing | `AppDesignTokens.*` | `constants/app_design_tokens.dart` |
| Custom gradient | `GradientHelper.*` | `utils/gradient_helper.dart` |

---

## Before & After Examples

### Example 1: Card Migration

**Before:**
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.grey[300]!),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
      ),
    ],
  ),
  child: Row(
    children: [
      Icon(Icons.book, color: Color(0xFF2196F3)),
      SizedBox(width: 12),
      Text('Mathematics'),
    ],
  ),
)
```

**After:**
```dart
InfoCard(
  icon: Icons.book,
  iconColor: AppColors.primary,
  title: 'Mathematics',
)
```

**Savings:** 20 lines → 4 lines (80% reduction!)

### Example 2: Color Migration

**Before:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
  ),
)
```

**After:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: GradientHelper.primary,
  ),
)
```

---

## Troubleshooting

### Issue: Import errors

**Solution:** Ensure all imports use correct relative paths:
```dart
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/widgets/cards/gradient_hero_card.dart';
```

### Issue: Component doesn't match design

**Solution:** Check home_page.dart for reference implementation

### Issue: Colors look wrong

**Solution:** Verify using `AppColors.primary` (#2196F3) not old colors

### Issue: Spacing inconsistent

**Solution:** Use `AppDesignTokens` constants, not hardcoded values

---

## Migration Checklist

For each page, verify:

- [ ] All colors use `AppColors.*`
- [ ] All spacing uses `AppDesignTokens.*`
- [ ] All gradients use `GradientHelper.*`
- [ ] Custom cards replaced with library components
- [ ] Section titles use `SectionHeader`
- [ ] Page wrapped in `PageScaffold` if applicable
- [ ] Imports are correct
- [ ] No hardcoded design values
- [ ] Blue theme throughout
- [ ] RTL tested

---

## Summary

**Total Migration:**
- 43 pages to update
- ~5-10 minutes per page
- ~4-7 hours total effort

**Benefits:**
- 70-80% code reduction in UI code
- 100% visual consistency
- Easy future maintenance
- Professional appearance

**Next Steps:**
1. Start with Auth pages (quick wins)
2. Move to Profile (high value)
3. Continue feature by feature
4. Test each feature after migration
5. Update documentation

---

**For detailed component documentation, see [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)**

**For reference implementation, see [home_page.dart](../lib/features/home/presentation/pages/home_page.dart)**
