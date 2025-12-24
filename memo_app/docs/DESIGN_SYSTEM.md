# 🎨 Memo App V2 - Unified Design System

**Version:** 1.0.0
**Last Updated:** November 25, 2025
**Color Scheme:** Blue (#2196F3)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Sizing](#spacing--sizing)
5. [Component Library](#component-library)
6. [Design Patterns](#design-patterns)
7. [Usage Examples](#usage-examples)
8. [Migration Guide](#migration-guide)

---

## Overview

This unified design system ensures visual consistency across all 45+ screens in the Memo App. Based on Material 3 design principles with custom Blue theming, it provides a modern, clean, and professional look.

### Design Philosophy
- **Consistency First:** All pages share the same visual language
- **Blue Theme:** Primary color #2196F3 (Material Blue)
- **Modern & Clean:** Minimalist approach with subtle shadows
- **RTL Support:** Arabic-first design with full RTL support
- **Accessibility:** WCAG AA compliant color contrast

---

## Color System

### Primary Colors

```dart
import '../../../../core/constants/app_colors.dart';

AppColors.primary        // #2196F3 - Main blue
AppColors.primaryLight   // #64B5F6 - Light blue
AppColors.primaryDark    // #1976D2 - Dark blue
```

### Gradients

```dart
import '../../../../core/utils/gradient_helper.dart';

GradientHelper.primary          // 2-color gradient
GradientHelper.primaryHero      // 3-color hero gradient
GradientHelper.primaryVertical  // Vertical gradient
```

### Semantic Colors

```dart
AppColors.success       // #4CAF50 - Green
AppColors.error         // #F44336 - Red
AppColors.warning       // #FF9800 - Orange
AppColors.info          // #2196F3 - Blue
```

### Accent Colors

```dart
AppColors.fireRed         // #EF4444 - Streak indicator
AppColors.successGreen    // #10B981 - Study time
AppColors.warningYellow   // #F59E0B - Coefficients
```

### Subject Colors

```dart
AppColors.mathematics   // Blue
AppColors.physics       // Purple
AppColors.chemistry     // Cyan
AppColors.arabic        // Green
AppColors.french        // Deep Orange
AppColors.english       // Red
```

### Text Colors

```dart
AppColors.textDark       // #0F172A - Primary text
AppColors.textSecondary  // #757575 - Secondary text
AppColors.textHint       // #BDBDBD - Hints
```

### Shadow Colors

```dart
AppColors.shadowPrimary        // Primary @ 40% opacity
AppColors.shadowPrimaryLight   // Primary @ 30% opacity
AppColors.shadowPrimarySubtle  // Primary @ 20% opacity
```

---

## Typography

### Font Family
**Cairo** - Google Fonts (optimized for Arabic)

### Text Styles

```dart
import '../../../../core/constants/app_design_tokens.dart';

// Display (48px, bold)
fontSize: AppDesignTokens.fontSizeDisplay

// Headlines (28px, 24px)
fontSize: AppDesignTokens.fontSizeHeadline

// Titles (20px, 18px, bold)
fontSize: AppDesignTokens.fontSizeTitle

// Body (16px, 14px)
fontSize: AppDesignTokens.fontSizeBody

// Labels (12px, 11px)
fontSize: AppDesignTokens.fontSizeLabel
```

---

## Spacing & Sizing

### Spacing Scale

```dart
AppDesignTokens.spacingXS   // 4px
AppDesignTokens.spacingSM   // 8px
AppDesignTokens.spacingMD   // 12px
AppDesignTokens.spacingLG   // 16px
AppDesignTokens.spacingXL   // 20px
AppDesignTokens.spacingXXL  // 24px
```

### Border Radius

```dart
AppDesignTokens.borderRadiusHero   // 28px - Hero cards
AppDesignTokens.borderRadiusCard   // 20px - Standard cards
AppDesignTokens.borderRadiusMedium // 18px - Session cards
AppDesignTokens.borderRadiusIcon   // 14px - Icon containers
AppDesignTokens.borderRadiusSmall  // 12px - Buttons
AppDesignTokens.borderRadiusTiny   // 10px - Progress bars
```

### Container Sizes

```dart
AppDesignTokens.heroCardHeight        // 200px
AppDesignTokens.iconContainerXL       // 56px
AppDesignTokens.iconContainerLG       // 50px
AppDesignTokens.iconContainerMD       // 44px
AppDesignTokens.progressBarThin       // 6px
AppDesignTokens.progressBarMedium     // 8px
```

### Animation

```dart
AppDesignTokens.animationFast     // 200ms
AppDesignTokens.animationNormal   // 300ms
AppDesignTokens.animationSlow     // 800ms

AppDesignTokens.curveStandard     // Curves.easeInOut
AppDesignTokens.curveEmphasized   // Curves.easeInOutCubic
```

---

## Component Library

### 1. Cards

#### GradientHeroCard
Large feature card with gradient background (hero sections).

```dart
import '../../../../core/widgets/cards/gradient_hero_card.dart';

GradientHeroCard(
  gradient: GradientHelper.primaryHero,
  child: Column(
    children: [
      Text('Total Points'),
      Text('1,250'),
    ],
  ),
)
```

#### StatCardMini
Small statistic display cards.

```dart
import '../../../../core/widgets/cards/stat_card_mini.dart';

StatCardMini(
  icon: Icons.local_fire_department,
  iconColor: AppColors.fireRed,
  value: '7',
  label: 'Day Streak',
)

// Horizontal variant
StatCardMiniHorizontal(
  icon: Icons.timer_outlined,
  iconColor: AppColors.successGreen,
  value: '2.5h',
  label: 'Study Time',
)
```

#### ProgressCard
Subject/course cards with progress bars.

```dart
import '../../../../core/widgets/cards/progress_card.dart';

ProgressCard(
  icon: Icons.calculate,
  iconColor: AppColors.mathematics,
  title: 'Mathematics',
  subtitle: '12 lessons',
  progress: 0.75,
  progressLabel: '75%',
  onTap: () {},
)
```

#### SessionCard
Study session cards with time and subject info.

```dart
import '../../../../core/widgets/cards/session_card.dart';

SessionCard(
  subjectIcon: Icons.book_rounded,
  subjectGradient: GradientHelper.primary,
  subjectName: 'Mathematics',
  sessionTitle: 'Algebra - Functions',
  time: '10:00 - 11:30',
  duration: '1h 30m',
  onTap: () {},
)
```

#### InfoCard
General-purpose information cards.

```dart
import '../../../../core/widgets/cards/info_card.dart';

InfoCard(
  icon: Icons.quiz,
  iconColor: AppColors.primary,
  title: 'Chapter 1 Quiz',
  subtitle: '10 questions · 15 min',
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

#### BacArchivesCard
BAC exam archive cards with gradient.

```dart
import '../../../../core/widgets/cards/bac_archives_card.dart';

BacArchivesCard(
  year: '2024',
  title: 'BAC 2024',
  subtitle: 'All streams',
  stats: '125 Exams',
  gradient: GradientHelper.primary,
  icon: Icons.archive,
  onTap: () {},
)

// Horizontal variant
BacArchivesCardHorizontal(
  year: '2024',
  title: 'BAC Archives',
  subtitle: 'Past exams',
  icon: Icons.school,
  gradient: GradientHelper.primary,
  onTap: () {},
)
```

### 2. Badges

#### StatBadge
Circular stat badges with icon and value.

```dart
import '../../../../core/widgets/badges/stat_badge.dart';

StatBadge(
  icon: Icons.star,
  value: '4.5',
  color: AppColors.warningYellow,
  size: BadgeSize.medium,
  label: 'Rating',
)
```

#### TimeBadge
Time display badges for sessions.

```dart
import '../../../../core/widgets/badges/time_badge.dart';

TimeBadge(
  time: '10:00 - 11:30',
  color: AppColors.primary,
  showIcon: true,
  style: TimeBadgeStyle.filled,
)

// Live timer with pulse animation
LiveTimerBadge(
  time: '1:23:45',
  color: AppColors.fireRed,
)
```

#### CoefficientBadge
Subject coefficient badges.

```dart
import '../../../../core/widgets/badges/coefficient_badge.dart';

CoefficientBadge(
  coefficient: 7,
  color: AppColors.warningYellow,
  showLabel: true,
  style: CoefficientBadgeStyle.filled,
)
```

#### LevelBadge
User level and achievement badges.

```dart
import '../../../../core/widgets/badges/level_badge.dart';

LevelBadge(
  level: 12,
  color: AppColors.primary,
  label: 'Expert',
  style: LevelBadgeStyle.gradient,
)

// Circular variant
LevelBadgeCircular(
  level: 12,
  size: 36,
  color: AppColors.primary,
)
```

### 3. Layouts

#### SectionHeader
Section titles with optional "View All" button.

```dart
import '../../../../core/widgets/layouts/section_header.dart';

SectionHeader(
  title: 'Today\'s Sessions',
  subtitle: '3 sessions scheduled',
  icon: Icons.calendar_today,
  onViewAll: () {},
  viewAllText: 'View All',
)
```

#### PageScaffold
Standard page wrapper with consistent structure.

```dart
import '../../../../core/widgets/layouts/page_scaffold.dart';

PageScaffold(
  title: 'My Page',
  showAppBar: true,
  applyHorizontalPadding: true,
  body: Column(
    children: [
      // Your content
    ],
  ),
)

// With refresh indicator
PageScaffoldWithRefresh(
  title: 'My Page',
  body: YourContent(),
  onRefresh: () async {
    // Refresh logic
  },
)
```

#### GridLayout
Responsive grid for cards.

```dart
import '../../../../core/widgets/layouts/grid_layout.dart';

GridLayout(
  itemCount: subjects.length,
  columnCount: 2,
  spacing: 14,
  itemBuilder: (context, index) {
    return ProgressCard(...);
  },
)

// Responsive grid (auto-adjusts columns)
ResponsiveGrid(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return YourCard(...);
  },
)
```

### 4. Inputs

#### AppSearchBar
Styled search bar.

```dart
import '../../../../core/widgets/inputs/app_search_bar.dart';

AppSearchBar(
  hintText: 'Search subjects...',
  controller: _searchController,
  onChanged: (query) {
    // Search logic
  },
  showClearButton: true,
)
```

#### FilterChipGroup
Filter chip selection.

```dart
import '../../../../core/widgets/inputs/filter_chip_group.dart';

FilterChipGroup(
  items: ['All', 'Math', 'Physics', 'Chemistry'],
  selectedIndex: 0,
  onSelected: (index) {
    // Handle selection
  },
)

// Multi-select variant
MultiSelectFilterChipGroup(
  items: ['Math', 'Physics', 'Chemistry'],
  selectedIndices: [0, 2],
  onSelectionChanged: (indices) {
    // Handle selection
  },
)
```

---

## Design Patterns

### 1. Hero Sections

Use `GradientHeroCard` for prominent features:
- Points display
- User stats
- Featured content
- Call-to-action sections

### 2. Lists & Grids

**Lists:** Use `SessionCard` or `InfoCard`
**Grids:** Use `ProgressCard` in `GridLayout`
**Mixed:** Combine with `SectionHeader`

### 3. Statistics

**Large stats:** `GradientHeroCard`
**Mini stats:** `StatCardMini`
**Badges:** `StatBadge` for compact display

### 4. Navigation

**Bottom Nav:** `ModernBottomNavigationBar` (automatically styled)
**Section Navigation:** `SectionHeader` with `onViewAll`

---

## Usage Examples

### Complete Page Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/widgets/layouts/page_scaffold.dart';
import '../../../../core/widgets/layouts/section_header.dart';
import '../../../../core/widgets/cards/gradient_hero_card.dart';
import '../../../../core/widgets/cards/progress_card.dart';
import '../../../../core/widgets/layouts/grid_layout.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageScaffoldWithRefresh(
      title: 'Dashboard',
      onRefresh: () async {
        // Refresh logic
      },
      body: Column(
        children: [
          // Hero Section
          GradientHeroCard(
            gradient: GradientHelper.primaryHero,
            child: Column(
              children: [
                Text('Total Points',
                  style: TextStyle(color: Colors.white)),
                Text('1,250',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeDisplay,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
              ],
            ),
          ),

          SizedBox(height: AppDesignTokens.sectionSpacing),

          // Section
          SectionHeader(
            title: 'My Subjects',
            onViewAll: () {},
          ),

          // Grid
          GridLayout(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return ProgressCard(
                icon: Icons.book,
                iconColor: AppColors.primary,
                title: subjects[index].name,
                progress: subjects[index].progress,
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Migration Guide

### Migrating Existing Pages

#### Step 1: Update Imports
```dart
// Old
import '../../../../core/constants/app_colors.dart';

// New - Add these
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/widgets/cards/gradient_hero_card.dart';
// ... other components
```

#### Step 2: Replace Hardcoded Colors
```dart
// Old
Color(0xFF6366F1)

// New
AppColors.primary
```

#### Step 3: Replace Custom Cards
```dart
// Old
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(...),
    borderRadius: BorderRadius.circular(20),
  ),
  child: ...,
)

// New
GradientHeroCard(
  gradient: GradientHelper.primaryHero,
  child: ...,
)
```

#### Step 4: Use Design Tokens
```dart
// Old
fontSize: 22

// New
fontSize: AppDesignTokens.fontSizeTitle
```

---

## Best Practices

### ✅ DO

- Use `AppColors` constants for all colors
- Use `AppDesignTokens` for spacing, sizing, and animations
- Use provided components instead of creating custom cards
- Maintain consistent spacing with design tokens
- Use `GradientHelper` for gradients
- Apply proper shadows from `AppDesignTokens`

### ❌ DON'T

- Hardcode colors (#2196F3 directly)
- Create duplicate card components
- Use arbitrary spacing values
- Mix different design patterns on same page
- Skip using section headers for lists
- Forget to apply RTL support

---

## Component Checklist

When creating a new page, use this checklist:

- [ ] Used `PageScaffold` or `PageScaffoldWithRefresh` as wrapper
- [ ] Applied proper horizontal padding with `AppDesignTokens.paddingScreen`
- [ ] Used `SectionHeader` for all section titles
- [ ] Replaced custom cards with library components
- [ ] Applied Blue color scheme throughout
- [ ] Used `GradientHelper` for any gradients
- [ ] Applied consistent spacing with design tokens
- [ ] Tested RTL layout
- [ ] Added proper loading/error states
- [ ] Used `ModernBottomNavigationBar` if needed

---

## Resources

### File Locations

**Colors:** `lib/core/constants/app_colors.dart`
**Design Tokens:** `lib/core/constants/app_design_tokens.dart`
**Gradients:** `lib/core/utils/gradient_helper.dart`
**Cards:** `lib/core/widgets/cards/`
**Badges:** `lib/core/widgets/badges/`
**Layouts:** `lib/core/widgets/layouts/`
**Inputs:** `lib/core/widgets/inputs/`

### Reference Implementation

**Home Page:** `lib/features/home/presentation/pages/home_page.dart`
This serves as the reference implementation showcasing all design patterns.

---

## Version History

**v1.0.0** (Nov 25, 2025)
- Initial unified design system
- Blue color scheme implementation
- 15 reusable components created
- Complete documentation

---

## Support

For questions or issues with the design system:
1. Check this documentation
2. Review the home_page.dart reference implementation
3. Consult the component source code
4. Check project_tree.md for file locations

---

**Made with 💙 for Memo App V2**
