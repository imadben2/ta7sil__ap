import 'dart:convert';

/// Model for storing user's preferred tab order
///
/// The default order is [0, 1, 2, 3, 4, 5] which corresponds to:
/// 0: الرئيسية (Home)
/// 1: بلانر (Planner)
/// 2: ملخصات و دروس (Content Library)
/// 3: بكالوريات (BAC Archives)
/// 4: كويز (Quiz)
/// 5: دوراتنا (Our Courses)
class TabOrderPreferences {
  /// List of category indices in user's preferred order
  final List<int> categoryOrder;

  /// Set of disabled tab indices (won't show in menu bar)
  /// Note: Index 0 (Home) and 5 (Courses) cannot be disabled
  final Set<int> disabledTabs;

  /// Total number of categories
  static const int categoryCount = 6;

  /// Tabs that cannot be disabled
  static const Set<int> nonDisableableTabs = {0, 5}; // Home and Courses

  const TabOrderPreferences({
    required this.categoryOrder,
    this.disabledTabs = const {},
  });

  /// Default order factory
  factory TabOrderPreferences.defaultOrder() {
    return const TabOrderPreferences(
      categoryOrder: [0, 1, 2, 3, 4, 5],
    );
  }

  /// Create from JSON
  factory TabOrderPreferences.fromJson(Map<String, dynamic> json) {
    final order = (json['categoryOrder'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList();

    // Validate order
    if (order == null || !_isValidOrder(order)) {
      return TabOrderPreferences.defaultOrder();
    }

    // Parse disabled tabs
    final disabledList = (json['disabledTabs'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toSet() ?? {};
    // Filter out non-disableable tabs
    final filteredDisabled = disabledList.difference(nonDisableableTabs);

    return TabOrderPreferences(
      categoryOrder: order,
      disabledTabs: filteredDisabled,
    );
  }

  /// Create from JSON string
  factory TabOrderPreferences.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TabOrderPreferences.fromJson(json);
    } catch (e) {
      return TabOrderPreferences.defaultOrder();
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryOrder': categoryOrder,
      'disabledTabs': disabledTabs.toList(),
    };
  }

  /// Check if a tab is disabled
  bool isTabDisabled(int tabIndex) {
    return disabledTabs.contains(tabIndex);
  }

  /// Check if a tab is enabled
  bool isTabEnabled(int tabIndex) {
    return !disabledTabs.contains(tabIndex);
  }

  /// Check if a tab can be disabled (Home and Courses cannot)
  bool canDisableTab(int tabIndex) {
    return !nonDisableableTabs.contains(tabIndex);
  }

  /// Get list of enabled tabs in order
  List<int> get enabledTabsInOrder {
    return categoryOrder.where((index) => !disabledTabs.contains(index)).toList();
  }

  /// Create a copy with a tab enabled/disabled
  TabOrderPreferences toggleTab(int tabIndex, bool enabled) {
    if (!canDisableTab(tabIndex)) return this;

    final newDisabled = Set<int>.from(disabledTabs);
    if (enabled) {
      newDisabled.remove(tabIndex);
    } else {
      newDisabled.add(tabIndex);
    }
    return TabOrderPreferences(
      categoryOrder: categoryOrder,
      disabledTabs: newDisabled,
    );
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Check if the order is valid (contains all indices 0 to categoryCount-1 exactly once)
  static bool _isValidOrder(List<int> order) {
    if (order.length != categoryCount) return false;

    final sorted = List<int>.from(order)..sort();
    for (int i = 0; i < categoryCount; i++) {
      if (sorted[i] != i) return false;
    }
    return true;
  }

  /// Check if this is the default order
  bool get isDefaultOrder {
    for (int i = 0; i < categoryCount; i++) {
      if (categoryOrder[i] != i) return false;
    }
    return true;
  }

  /// Get the UI position for a given category index
  int getPositionOf(int categoryIndex) {
    return categoryOrder.indexOf(categoryIndex);
  }

  /// Get the category index at a given UI position
  int getCategoryAt(int position) {
    if (position < 0 || position >= categoryOrder.length) {
      return position;
    }
    return categoryOrder[position];
  }

  /// Create a new preferences with reordered categories
  TabOrderPreferences reorder(int oldIndex, int newIndex) {
    final newOrder = List<int>.from(categoryOrder);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    return TabOrderPreferences(
      categoryOrder: newOrder,
      disabledTabs: disabledTabs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TabOrderPreferences) return false;
    if (categoryOrder.length != other.categoryOrder.length) return false;
    for (int i = 0; i < categoryOrder.length; i++) {
      if (categoryOrder[i] != other.categoryOrder[i]) return false;
    }
    if (disabledTabs.length != other.disabledTabs.length) return false;
    if (!disabledTabs.containsAll(other.disabledTabs)) return false;
    return true;
  }

  @override
  int get hashCode => Object.hash(categoryOrder.hashCode, disabledTabs.hashCode);

  @override
  String toString() {
    return 'TabOrderPreferences(categoryOrder: $categoryOrder, disabledTabs: $disabledTabs)';
  }
}
