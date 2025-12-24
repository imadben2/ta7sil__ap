import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../bloc/subscription/subscription_bloc.dart';
import '../bloc/subscription/subscription_event.dart';
import '../bloc/subscription/subscription_state.dart';
import '../widgets/subscription_package_card.dart';
import '../widgets/subscription_code_dialog.dart';
import '../widgets/receipt_status_card.dart';

/// Modern Subscriptions Page - صفحة الاشتراكات
class SubscriptionsPage extends StatefulWidget {
  final bool showAppBar;

  const SubscriptionsPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<SubscriptionBloc>().add(const LoadAllSubscriptionDataEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Modern App Bar
            _buildModernAppBar(),

            // Modern Tab Bar
            _buildModernTabBar(),

            // Tab Content
            Expanded(
              child: BlocListener<SubscriptionBloc, SubscriptionState>(
                listener: (context, state) {
                  if (state is SubscriptionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else if (state is CodeRedeemed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.emerald500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    _loadData();
                  } else if (state is PaymentReceiptSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.emerald500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPackagesTab(),
                    _buildMySubscriptionsTab(),
                    _buildMyReceiptsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button - only show when page has its own app bar (not in bottom nav)
          if (widget.showAppBar)
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.slate900,
                ),
              ),
            )
          else
            const SizedBox(width: 44), // Placeholder to maintain layout

          // Title
          const Text(
            'الاشتراكات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),

          // Code Entry Button
          GestureDetector(
            onTap: _showSubscriptionCodeDialog,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.blueVioletGradient,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue500.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.slate600,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.blueVioletGradient,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue500.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard_rounded, size: 16),
                SizedBox(width: 4),
                Text('الباقات'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.subscriptions_rounded, size: 16),
                SizedBox(width: 4),
                Text('اشتراكاتي'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 16),
                SizedBox(width: 4),
                Text('إيصالاتي'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionDataLoaded) {
          if (state.isLoadingPackages) {
            return _buildLoadingState();
          }
          if (state.packagesError != null) {
            return _buildModernErrorState(state.packagesError!);
          }
          return _buildPackagesList(state.packages);
        } else if (state is SubscriptionLoading) {
          return _buildLoadingState();
        } else if (state is SubscriptionError) {
          return _buildModernErrorState(state.message);
        }
        // Initial state - show empty state with action
        return _buildModernEmptyState(
          icon: Icons.card_giftcard_outlined,
          title: 'لا توجد باقات اشتراك متاحة حالياً',
          subtitle: 'اسحب للأسفل لتحديث البيانات',
        );
      },
    );
  }

  Widget _buildPackagesList(List<SubscriptionPackageEntity> packages) {
    if (packages.isEmpty) {
      return _buildModernEmptyState(
        icon: Icons.card_giftcard_outlined,
        title: 'لا توجد باقات اشتراك متاحة حالياً',
        subtitle: 'سيتم إضافة باقات جديدة قريباً',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(
          const LoadSubscriptionPackagesEvent(),
        );
      },
      color: AppColors.blue500,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          try {
            return _buildModernPackageCard(package);
          } catch (e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'خطأ في تحميل الباقة: ${package.nameAr}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.red500,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildModernPackageCard(SubscriptionPackageEntity package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package Name
            Text(
              package.nameAr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),

            // Description
            if (package.descriptionAr != null && package.descriptionAr!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                package.descriptionAr!,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.slate600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Price and Duration
            Row(
              children: [
                Text(
                  '${package.priceDzd} دج',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.slate500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${package.durationDays} يوم',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Subscribe Button - Full width
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSubscribe(package),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'اشترك الآن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySubscriptionsTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionDataLoaded) {
          if (state.isLoadingSubscriptions) {
            return _buildLoadingState();
          }
          if (state.subscriptionsError != null) {
            return _buildModernErrorState(state.subscriptionsError!);
          }
          return _buildMySubscriptionsList(state.subscriptions);
        } else if (state is SubscriptionLoading) {
          return _buildLoadingState();
        } else if (state is SubscriptionError) {
          return _buildModernErrorState(state.message);
        }
        // Initial state
        return _buildModernEmptyState(
          icon: Icons.subscriptions_outlined,
          title: 'ليس لديك أي اشتراكات حالياً',
          subtitle: 'اشترك في إحدى الباقات للوصول إلى المحتوى',
        );
      },
    );
  }

  Widget _buildMySubscriptionsList(List<UserSubscriptionEntity> subscriptions) {
    if (subscriptions.isEmpty) {
      return _buildModernEmptyState(
        icon: Icons.subscriptions_outlined,
        title: 'ليس لديك أي اشتراكات حالياً',
        subtitle: 'اشترك في إحدى الباقات للوصول إلى المحتوى',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(const LoadMySubscriptionsEvent());
      },
      color: AppColors.blue500,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return _buildModernSubscriptionCard(subscription);
        },
      ),
    );
  }

  Widget _buildModernSubscriptionCard(UserSubscriptionEntity subscription) {
    final isExpiringSoon = subscription.remainingDays <= 7 && subscription.remainingDays > 0;
    final statusColor = subscription.isActive
        ? (subscription.isExpired
            ? AppColors.red500
            : (isExpiringSoon ? AppColors.amber500 : AppColors.emerald500))
        : AppColors.slate500;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.subscriptions_rounded,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subscription.packageNameAr ?? 'اشتراك',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.statusText,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Course Name
          if (subscription.courseNameAr != null)
            Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: AppColors.slate500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscription.courseNameAr!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // Dates
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.slate500),
              const SizedBox(width: 8),
              Text(
                'من: ${_formatDate(subscription.startedAt)}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.slate600,
                ),
              ),
              if (subscription.expiresAt != null) ...[
                const SizedBox(width: 16),
                Text(
                  'إلى: ${_formatDate(subscription.expiresAt!)}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ],
          ),

          // Progress Bar
          if (subscription.isActive && !subscription.isExpired) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription.expiresAt != null
                      ? 'متبقي ${subscription.remainingDays} يوم'
                      : 'اشتراك غير محدود',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: subscription.expiresAt != null
                    ? subscription.remainingDays / 365
                    : 1,
                minHeight: 8,
                backgroundColor: statusColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],

          // Warning for expiring soon
          if (isExpiringSoon && subscription.isActive) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.amber500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.amber500.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.amber500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اشتراكك على وشك الانتهاء. قم بتجديده الآن!',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.amber500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyReceiptsTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionDataLoaded) {
          if (state.isLoadingReceipts) {
            return _buildLoadingState();
          }
          if (state.receiptsError != null) {
            return _buildModernErrorState(state.receiptsError!);
          }
          return _buildMyReceiptsList(state.receipts);
        } else if (state is SubscriptionLoading) {
          return _buildLoadingState();
        } else if (state is SubscriptionError) {
          return _buildModernErrorState(state.message);
        }
        // Initial state
        return _buildModernEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'لم ترسل أي إيصال دفع بعد',
          subtitle: 'اختر باقة واشترك لإرسال إيصال الدفع',
          actionLabel: 'تصفح الباقات',
          onAction: () => _tabController.animateTo(0),
        );
      },
    );
  }

  Widget _buildMyReceiptsList(List receipts) {
    if (receipts.isEmpty) {
      return _buildModernEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لم ترسل أي إيصال دفع بعد',
        subtitle: 'اختر باقة واشترك لإرسال إيصال الدفع',
        actionLabel: 'تصفح الباقات',
        onAction: () => _tabController.animateTo(0),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(
          const LoadMyPaymentReceiptsEvent(),
        );
      },
      color: AppColors.blue500,
      child: Column(
        children: [
          // Receipt count header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: AppColors.blue500),
                    const SizedBox(width: 10),
                    Text(
                      'إجمالي الإيصالات: ${receipts.length}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/my-receipts'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blue500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_back_ios_rounded, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Receipts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: receipts.length > 5 ? 5 : receipts.length,
              itemBuilder: (context, index) {
                return ReceiptStatusCard(
                  receipt: receipts[index],
                  onTap: () => context.push('/my-receipts'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.blue500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue500),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري التحميل...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.slate500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 50, color: AppColors.slate500),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.red500.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.red500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscribe(SubscriptionPackageEntity package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModernSubscribeSheet(package),
    );
  }

  Widget _buildModernSubscribeSheet(SubscriptionPackageEntity package) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.blueVioletGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'اختر طريقة الاشتراك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.slate600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Package Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${package.durationDays} يوم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${package.priceDzd} دج',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Options
          _buildPaymentOption(
            icon: Icons.phone_android_rounded,
            title: 'Baridi Mob',
            subtitle: 'الدفع الإلكتروني',
            color: AppColors.emerald500,
            onTap: () {
              Navigator.pop(context);
              _navigateToPaymentReceipt(package, 'baridi_mob');
            },
          ),

          const SizedBox(height: 12),

          _buildPaymentOption(
            icon: Icons.account_balance_rounded,
            title: 'CCP (البريد)',
            subtitle: 'التحويل البريدي',
            color: AppColors.blue500,
            onTap: () {
              Navigator.pop(context);
              _navigateToPaymentReceipt(package, 'ccp');
            },
          ),

          const SizedBox(height: 12),

          _buildPaymentOption(
            icon: Icons.qr_code_rounded,
            title: 'لدي كود اشتراك',
            subtitle: 'إدخال كود الاشتراك',
            color: AppColors.violet500,
            onTap: () {
              Navigator.pop(context);
              _showSubscriptionCodeDialog();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.slate500),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionCodeDialog() {
    SubscriptionCodeDialog.show(context);
  }

  void _navigateToPaymentReceipt(
    SubscriptionPackageEntity package,
    String paymentMethod,
  ) {
    context.push(
      '/payment-receipt',
      extra: {
        'package': package,
        'courseId': null,
        'paymentMethod': paymentMethod,
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
