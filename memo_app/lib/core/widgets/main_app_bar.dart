import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_design_tokens.dart';
import 'category_chips.dart';

/// Custom app bar with profile, title, help button, and category chips
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CategoryItem> categories;
  final int selectedCategoryIndex;
  final Function(int) onCategorySelected;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onHelpTap;
  final int streakCount;
  final String? userName;
  final String? userAvatar;
  final int unreadNotificationCount;

  const MainAppBar({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    this.onProfileTap,
    this.onNotificationTap,
    this.onHelpTap,
    this.streakCount = 0,
    this.userName,
    this.userAvatar,
    this.unreadNotificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with profile, title, and streak
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.screenPaddingHorizontal,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // Profile avatar (right side in RTL)
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.primaryGradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: userAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                userAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                              ),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Greeting and app name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName != null ? 'مرحباً، $userName' : 'مرحباً بك',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Text(
                          'تحصيل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Help button - دليل المستخدم
                  GestureDetector(
                    onTap: onHelpTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'دليل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Notification button
                  IconButton(
                    onPressed: onNotificationTap,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textSecondary,
                          size: 26,
                        ),
                        if (unreadNotificationCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.fireRed,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unreadNotificationCount > 99
                                      ? '99+'
                                      : '$unreadNotificationCount',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Category chips
            CategoryChips(
              categories: categories,
              selectedIndex: selectedCategoryIndex,
              onSelected: onCategorySelected,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'م',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
