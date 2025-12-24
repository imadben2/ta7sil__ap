import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/badges/animated_status_badge.dart';
import '../../domain/entities/payment_receipt_entity.dart';
import '../bloc/subscription/subscription_bloc.dart';
import '../bloc/subscription/subscription_event.dart';
import '../bloc/subscription/subscription_state.dart';

/// Modern My Receipts Page - صفحة إيصالاتي
///
/// Features:
/// - Gradient hero header with stats
/// - Animated status badges
/// - Glassmorphic detail bottom sheet
/// - Modern filter chips with animations
/// - Pull to refresh
/// - RTL support with Cairo font
class MyReceiptsPage extends StatefulWidget {
  const MyReceiptsPage({super.key});

  @override
  State<MyReceiptsPage> createState() => _MyReceiptsPageState();
}

class _MyReceiptsPageState extends State<MyReceiptsPage>
    with SingleTickerProviderStateMixin {
  String? _selectedStatus;
  late AnimationController _filterAnimController;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _filterAnimController.dispose();
    super.dispose();
  }

  void _loadReceipts() {
    context.read<SubscriptionBloc>().add(
      LoadMyPaymentReceiptsEvent(status: _selectedStatus),
    );
  }

  void _onStatusFilterChanged(String? newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
    _loadReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar with Stats
          _buildSliverAppBar(),

          // Filter Chips
          SliverToBoxAdapter(child: _buildFilterChips()),

          // Receipts List
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionDataLoaded) {
                if (state.isLoadingReceipts) {
                  return const SliverFillRemaining(child: _LoadingState());
                }
                if (state.receiptsError != null) {
                  return SliverFillRemaining(
                    child: _ErrorState(
                      message: state.receiptsError!,
                      onRetry: _loadReceipts,
                    ),
                  );
                }
                return _buildReceiptsList(state.receipts);
              }
              return const SliverFillRemaining(child: _LoadingState());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF3B82F6),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              _buildDecorativeCircles(),

              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'إيصالات الدفع',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'تتبع حالة إيصالاتك',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      _buildStatsRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          right: 80,
          bottom: 60,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        int total = 0;
        int pending = 0;
        int approved = 0;
        int rejected = 0;

        if (state is SubscriptionDataLoaded) {
          total = state.receipts.length;
          pending = state.receipts.where((r) => r.status == 'pending').length;
          approved = state.receipts.where((r) => r.status == 'approved').length;
          rejected = state.receipts.where((r) => r.status == 'rejected').length;
        }

        return Row(
          children: [
            _buildStatCard(
              icon: Icons.receipt_long_rounded,
              value: '$total',
              label: 'الإجمالي',
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.schedule_rounded,
              value: '$pending',
              label: 'قيد المراجعة',
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.check_circle_rounded,
              value: '$approved',
              label: 'مقبولة',
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.cancel_rounded,
              value: '$rejected',
              label: 'مرفوضة',
              color: const Color(0xFFEF4444),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (color ?? Colors.white).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      _FilterOption(label: 'الكل', value: null, icon: Icons.receipt_long_rounded, color: const Color(0xFF3B82F6)),
      _FilterOption(label: 'قيد المراجعة', value: 'pending', icon: Icons.schedule_rounded, color: const Color(0xFFF59E0B)),
      _FilterOption(label: 'مقبولة', value: 'approved', icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)),
      _FilterOption(label: 'مرفوضة', value: 'rejected', icon: Icons.cancel_rounded, color: const Color(0xFFEF4444)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedStatus == filter.value;
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: () => _onStatusFilterChanged(filter.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [filter.color, filter.color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? filter.color.withOpacity(0.4)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 18,
                        color: isSelected ? Colors.white : filter.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReceiptsList(List<PaymentReceiptEntity> receipts) {
    if (receipts.isEmpty) {
      return SliverFillRemaining(
        child: _EmptyState(
          selectedStatus: _selectedStatus,
          onAction: () => context.pop(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildReceiptCard(receipts[index]),
          childCount: receipts.length,
        ),
      ),
    );
  }

  Widget _buildReceiptCard(PaymentReceiptEntity receipt) {
    final statusConfig = _getStatusConfig(receipt.status);

    return GestureDetector(
      onTap: () => _showReceiptDetails(receipt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              statusConfig.color,
                              statusConfig.color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: statusConfig.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(statusConfig.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.packageName ?? 'إيصال #${receipt.id}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(receipt.createdAt),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedStatusBadge(
                        status: _mapToAnimatedBadgeStatus(receipt.status),
                        customLabel: statusConfig.label,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF8FAFC),
                          const Color(0xFFF1F5F9).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${receipt.amountDzd} دج',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                receipt.paymentMethod == 'baridi_mob'
                                    ? Icons.phone_android_rounded
                                    : Icons.account_balance_rounded,
                                color: const Color(0xFF64748B),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              receipt.paymentMethod == 'baridi_mob' ? 'Baridi Mob' : 'CCP',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Rejection Reason
                  if (receipt.status == 'rejected' && receipt.adminNotes != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              receipt.adminNotes!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // View Details Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: statusConfig.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_back_ios_rounded, size: 14, color: statusConfig.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetails(PaymentReceiptEntity receipt) {
    final statusConfig = _getStatusConfig(receipt.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle Bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'تفاصيل الإيصال',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusConfig.color.withOpacity(0.1),
                                  statusConfig.color.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusConfig.color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: statusConfig.color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(statusConfig.icon, color: statusConfig.color, size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        statusConfig.label,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: statusConfig.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getStatusDescription(receipt.status),
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Receipt Details Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow(Icons.card_giftcard_rounded, 'الباقة', receipt.packageName ?? '-'),
                                _buildDivider(),
                                _buildDetailRow(Icons.payments_rounded, 'المبلغ', '${receipt.amountDzd} دج',
                                    valueColor: const Color(0xFF10B981), isLarge: true),
                                _buildDivider(),
                                _buildDetailRow(
                                  receipt.paymentMethod == 'baridi_mob'
                                      ? Icons.phone_android_rounded
                                      : Icons.account_balance_rounded,
                                  'طريقة الدفع',
                                  receipt.paymentMethod == 'baridi_mob' ? 'Baridi Mob' : 'CCP (البريد)',
                                ),
                                _buildDivider(),
                                _buildDetailRow(Icons.calendar_today_rounded, 'تاريخ الإرسال', _formatDate(receipt.createdAt)),
                                if (receipt.transactionReference != null) ...[
                                  _buildDivider(),
                                  _buildDetailRow(Icons.tag_rounded, 'رقم العملية', receipt.transactionReference!),
                                ],
                              ],
                            ),
                          ),

                          // Rejection Reason
                          if (receipt.status == 'rejected' && receipt.adminNotes != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFEF4444).withOpacity(0.1),
                                    const Color(0xFFEF4444).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'سبب الرفض',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    receipt.adminNotes!,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Action Button for Rejected
                          if (receipt.status == 'rejected') ...[
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'إرسال إيصال جديد',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Success Message for Approved
                          if (receipt.status == 'approved') ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.1),
                                    const Color(0xFF10B981).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'تم قبول إيصالك وتفعيل اشتراكك بنجاح!',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Pending Message
                          if (receipt.status == 'pending') ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFF59E0B).withOpacity(0.1),
                                    const Color(0xFFF59E0B).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.schedule_rounded, color: Color(0xFFF59E0B), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'إيصالك قيد المراجعة. سيتم إشعارك فور الموافقة.',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isLarge ? 18 : 14,
              fontWeight: isLarge ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig(
          color: const Color(0xFFF59E0B),
          label: 'قيد المراجعة',
          icon: Icons.schedule_rounded,
        );
      case 'approved':
        return _StatusConfig(
          color: const Color(0xFF10B981),
          label: 'مقبول',
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return _StatusConfig(
          color: const Color(0xFFEF4444),
          label: 'مرفوض',
          icon: Icons.cancel_rounded,
        );
      default:
        return _StatusConfig(
          color: const Color(0xFF64748B),
          label: 'غير معروف',
          icon: Icons.help_rounded,
        );
    }
  }

  BadgeStatus _mapToAnimatedBadgeStatus(String status) {
    switch (status) {
      case 'pending':
        return BadgeStatus.pending;
      case 'approved':
        return BadgeStatus.approved;
      case 'rejected':
        return BadgeStatus.rejected;
      default:
        return BadgeStatus.pending;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'يتم مراجعة إيصالك من قبل الإدارة';
      case 'approved':
        return 'تم قبول إيصالك وتفعيل اشتراكك';
      case 'rejected':
        return 'تم رفض إيصالك، يرجى مراجعة السبب';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Helper Classes
class _FilterOption {
  final String label;
  final String? value;
  final IconData icon;
  final Color color;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  const _StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}

// Extracted Widgets for cleaner code
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'جاري التحميل...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFEF4444).withOpacity(0.15),
                    const Color(0xFFEF4444).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 45,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? selectedStatus;
  final VoidCallback onAction;

  const _EmptyState({required this.selectedStatus, required this.onAction});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    switch (selectedStatus) {
      case 'pending':
        message = 'لا توجد إيصالات قيد المراجعة';
        icon = Icons.schedule_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case 'approved':
        message = 'لا توجد إيصالات مقبولة';
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF10B981);
        break;
      case 'rejected':
        message = 'لا توجد إيصالات مرفوضة';
        icon = Icons.cancel_rounded;
        color = const Color(0xFFEF4444);
        break;
      default:
        message = 'لم ترسل أي إيصال دفع بعد';
        icon = Icons.receipt_long_rounded;
        color = const Color(0xFF3B82F6);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 55, color: color),
            ),
            const SizedBox(height: 28),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بإرسال إيصال دفع للاشتراك في الدورات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedStatus == null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'إرسال إيصال جديد',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
