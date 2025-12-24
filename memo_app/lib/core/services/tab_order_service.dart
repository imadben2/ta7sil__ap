import 'dart:async';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/tab_order_preferences.dart';
import '../storage/hive_service.dart';

/// Service for managing tab order preferences
///
/// This service handles loading and saving the user's preferred
/// order of category tabs to Hive local storage.
class TabOrderService extends ChangeNotifier {
  final HiveService _hiveService;

  /// Storage key for tab order preferences
  static const String _storageKey = 'tab_order_preferences';

  /// Current tab order preferences
  TabOrderPreferences _preferences = TabOrderPreferences.defaultOrder();

  /// Stream controller for order changes
  final _orderController = StreamController<TabOrderPreferences>.broadcast();

  TabOrderService({required HiveService hiveService})
      : _hiveService = hiveService;

  /// Get current preferences
  TabOrderPreferences get preferences => _preferences;

  /// Get current category order
  List<int> get categoryOrder => _preferences.categoryOrder;

  /// Get enabled tabs in order (for menu bar display)
  List<int> get enabledTabsInOrder => _preferences.enabledTabsInOrder;

  /// Get disabled tabs set
  Set<int> get disabledTabs => _preferences.disabledTabs;

  /// Stream of order changes
  Stream<TabOrderPreferences> get orderStream => _orderController.stream;

  /// Check if using default order
  bool get isDefaultOrder => _preferences.isDefaultOrder;

  /// Check if a tab is enabled
  bool isTabEnabled(int tabIndex) => _preferences.isTabEnabled(tabIndex);

  /// Check if a tab can be disabled
  bool canDisableTab(int tabIndex) => _preferences.canDisableTab(tabIndex);

  /// Initialize service and load saved preferences
  Future<void> init() async {
    await _loadPreferences();
  }

  /// Load preferences from Hive storage
  Future<void> _loadPreferences() async {
    try {
      final jsonString = _hiveService.get(
        ApiConstants.hiveBoxCache,
        _storageKey,
        defaultValue: null,
      );

      if (jsonString != null && jsonString is String) {
        _preferences = TabOrderPreferences.fromJsonString(jsonString);
        debugPrint('[TabOrderService] Loaded preferences: $_preferences');
      } else {
        _preferences = TabOrderPreferences.defaultOrder();
        debugPrint('[TabOrderService] Using default preferences');
      }
    } catch (e) {
      debugPrint('[TabOrderService] Error loading preferences: $e');
      _preferences = TabOrderPreferences.defaultOrder();
    }
    notifyListeners();
  }

  /// Save preferences to Hive storage
  Future<bool> savePreferences(TabOrderPreferences newPreferences) async {
    try {
      await _hiveService.save(
        ApiConstants.hiveBoxCache,
        _storageKey,
        newPreferences.toJsonString(),
      );
      _preferences = newPreferences;
      _orderController.add(_preferences);
      notifyListeners();
      debugPrint('[TabOrderService] Saved preferences: $_preferences');
      return true;
    } catch (e) {
      debugPrint('[TabOrderService] Error saving preferences: $e');
      return false;
    }
  }

  /// Update the tab order (preserves disabled tabs)
  Future<bool> updateOrder(List<int> newOrder) async {
    final newPreferences = TabOrderPreferences(
      categoryOrder: newOrder,
      disabledTabs: _preferences.disabledTabs,
    );
    return savePreferences(newPreferences);
  }

  /// Update both order and disabled tabs
  Future<bool> updateOrderAndDisabled(List<int> newOrder, Set<int> disabledTabs) async {
    final newPreferences = TabOrderPreferences(
      categoryOrder: newOrder,
      disabledTabs: disabledTabs,
    );
    return savePreferences(newPreferences);
  }

  /// Toggle a tab's enabled/disabled state
  Future<bool> toggleTab(int tabIndex, bool enabled) async {
    final newPreferences = _preferences.toggleTab(tabIndex, enabled);
    return savePreferences(newPreferences);
  }

  /// Reorder a tab from oldIndex to newIndex
  Future<bool> reorderTab(int oldIndex, int newIndex) async {
    final newPreferences = _preferences.reorder(oldIndex, newIndex);
    return savePreferences(newPreferences);
  }

  /// Reset to default order
  Future<bool> resetToDefault() async {
    return savePreferences(TabOrderPreferences.defaultOrder());
  }

  /// Get the category index at a given UI position
  int getCategoryAt(int position) {
    return _preferences.getCategoryAt(position);
  }

  /// Get the UI position for a given category index
  int getPositionOf(int categoryIndex) {
    return _preferences.getPositionOf(categoryIndex);
  }

  @override
  void dispose() {
    _orderController.close();
    super.dispose();
  }
}
