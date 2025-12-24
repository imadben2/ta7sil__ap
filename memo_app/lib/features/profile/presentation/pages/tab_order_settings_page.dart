import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/models/tab_order_preferences.dart';
import '../../../../core/services/tab_order_service.dart';
import '../../../../core/widgets/category_chips.dart';
import '../../../../injection_container.dart';
import '../widgets/profile_page_header.dart';

/// Settings page for customizing category tab order
///
/// Allows users to drag and reorder the category tabs
/// and toggle visibility of tabs in the menu bar.
/// Home (index 0) and Courses (index 5) cannot be disabled.
class TabOrderSettingsPage extends StatefulWidget {
  const TabOrderSettingsPage({super.key});

  @override
  State<TabOrderSettingsPage> createState() => _TabOrderSettingsPageState();
}

class _TabOrderSettingsPageState extends State<TabOrderSettingsPage> {
  late List<int> _currentOrder;
  late List<int> _originalOrder;
  late Set<int> _disabledTabs;
  late Set<int> _originalDisabledTabs;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tabOrderService = sl<TabOrderService>();
    _currentOrder = List<int>.from(tabOrderService.categoryOrder);
    _originalOrder = List<int>.from(_currentOrder);
    _disabledTabs = Set<int>.from(tabOrderService.disabledTabs);
    _originalDisabledTabs = Set<int>.from(_disabledTabs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
      _updateHasChanges();
    });
  }

  void _onToggleEnabled(int categoryIndex, bool enabled) {
    // Don't allow toggling Home (0) or Courses (5)
    if (!TabOrderPreferences.nonDisableableTabs.contains(categoryIndex)) {
      setState(() {
        if (enabled) {
          _disabledTabs.remove(categoryIndex);
        } else {
          _disabledTabs.add(categoryIndex);
        }
        _updateHasChanges();
      });
    }
  }

  void _updateHasChanges() {
    final orderChanged = !_listEquals(_currentOrder, _originalOrder);
    final disabledChanged = !_setEquals(_disabledTabs, _originalDisabledTabs);
    _hasChanges = orderChanged || disabledChanged;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _saveOrder() async {
    if (!_hasChanges) return;

    setState(() => _isSaving = true);

    final tabOrderService = sl<TabOrderService>();
    final success = await tabOrderService.updateOrderAndDisabled(
      _currentOrder,
      _disabledTabs,
    );

    setState(() => _isSaving = false);

    if (success) {
      _originalOrder = List<int>.from(_currentOrder);
      _originalDisabledTabs = Set<int>.from(_disabledTabs);
      _hasChanges = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم حفظ ترتيب التبويبات بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'فشل في حفظ الترتيب',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'استعادة الترتيب الافتراضي',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل تريد استعادة ترتيب التبويبات إلى الوضع الافتراضي؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'استعادة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _currentOrder = [0, 1, 2, 3, 4, 5];
        _disabledTabs = {}; // Reset all tabs to enabled
        _updateHasChanges();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.slateBackground,
        body: Column(
          children: [
            // الهيدر الموحد
            ProfilePageHeader(
              title: 'ترتيب التبويبات',
              subtitle: 'تخصيص ترتيب القوائم',
              icon: Icons.reorder_rounded,
              onBack: () {
                if (_hasChanges) {
                  _showUnsavedChangesDialog();
                } else {
                  context.pop();
                }
              },
              onAction: _hasChanges && !_isSaving ? _saveOrder : null,
              actionIcon: Icons.check_rounded,
            ),
            // المحتوى
            Expanded(
              child: Column(
          children: [
            // Instructions
            Container(
              margin: EdgeInsets.all(AppDesignTokens.screenPaddingHorizontal),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'اسحب التبويبات لإعادة ترتيبها حسب تفضيلك',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.screenPaddingHorizontal,
                  vertical: 8,
                ),
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final elevation = Tween<double>(begin: 0, end: 8)
                          .animate(animation)
                          .value;
                      return Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                onReorder: _onReorder,
                itemCount: _currentOrder.length,
                itemBuilder: (context, index) {
                  final categoryIndex = _currentOrder[index];
                  final category = AppCategories.getCategoryAt(categoryIndex);

                  return _buildReorderableItem(
                    key: ValueKey(categoryIndex),
                    index: index,
                    category: category,
                    categoryIndex: categoryIndex,
                  );
                },
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.all(AppDesignTokens.screenPaddingHorizontal),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetToDefault,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'استعادة الافتراضي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _hasChanges && !_isSaving ? _saveOrder : null,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text(
                          'حفظ الترتيب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableItem({
    required Key key,
    required int index,
    required CategoryItem category,
    required int categoryIndex,
  }) {
    final isEnabled = !_disabledTabs.contains(categoryIndex);
    final canDisable = !TabOrderPreferences.nonDisableableTabs.contains(categoryIndex);

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? AppColors.primaryGradient
                  : [Colors.grey[400]!, Colors.grey[500]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category.icon ?? Icons.category,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isEnabled ? AppColors.textPrimary : Colors.grey[500],
          ),
        ),
        subtitle: Text(
          'الموضع: ${index + 1}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox for enabling/disabling (only for non-Home and non-Courses)
            if (canDisable)
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isEnabled,
                  onChanged: (value) {
                    _onToggleEnabled(categoryIndex, value ?? true);
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // Drag handle
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تغييرات غير محفوظة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'لديك تغييرات غير محفوظة. هل تريد حفظها قبل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text(
              'تجاهل',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveOrder();
              if (mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
