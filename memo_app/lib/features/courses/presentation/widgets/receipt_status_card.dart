import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_receipt_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Modern receipt status card with gradient border and animations
///
/// Features:
/// - Left border gradient based on status
/// - Animated status badge
/// - Modern shadow and border radius (20px)
/// - Image thumbnail with gradient overlay
/// - Expandable admin notes section
/// - RTL support with Cairo font
class ReceiptStatusCard extends StatefulWidget {
  final PaymentReceiptEntity receipt;
  final VoidCallback? onTap;

  const ReceiptStatusCard({
    super.key,
    required this.receipt,
    this.onTap,
  });

  @override
  State<ReceiptStatusCard> createState() => _ReceiptStatusCardState();
}

class _ReceiptStatusCardState extends State<ReceiptStatusCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get isPending => widget.receipt.status.toLowerCase() == 'pending';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (isPending) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  StatusConfig get _statusConfig {
    switch (widget.receipt.status.toLowerCase()) {
      case 'approved':
        return StatusConfig(
          label: 'مقبول',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
        );
      case 'rejected':
        return StatusConfig(
          label: 'مرفوض',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFEF4444),
          gradientColors: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        );
      case 'pending':
      default:
        return StatusConfig(
          label: 'قيد المراجعة',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF59E0B),
          gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient left border
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: config.gradientColors,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Status Badge
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: config.color.withOpacity( 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: config.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.receipt.courseName ??
                                      widget.receipt.packageName ??
                                      'إيصال دفع',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildAnimatedStatusBadge(config),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Receipt Image Thumbnail
                    if (widget.receipt.receiptImageUrl != null)
                      _buildImageThumbnail(config),

                    if (widget.receipt.receiptImageUrl != null)
                      const SizedBox(height: 16),

                    // Amount and Date Row
                    _buildInfoRow(config),

                    // Payment Method
                    if (widget.receipt.paymentMethod != null) ...[
                      const SizedBox(height: 10),
                      _buildPaymentMethod(),
                    ],

                    // Transaction Reference
                    if (widget.receipt.transactionReference != null) ...[
                      const SizedBox(height: 10),
                      _buildTransactionRef(),
                    ],

                    // Admin Notes (Expandable)
                    if (widget.receipt.adminNotes != null &&
                        widget.receipt.adminNotes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildAdminNotesSection(config),
                    ],

                    // Rejection Reason
                    if (widget.receipt.status == 'rejected' &&
                        widget.receipt.rejectionReason != null &&
                        widget.receipt.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildRejectionReason(),
                    ],

                    // Reviewed Info
                    if (widget.receipt.reviewedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildReviewedInfo(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatusBadge(StatusConfig config) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withOpacity( 0.3),
        ),
        boxShadow: isPending
            ? [
                BoxShadow(
                  color: config.color.withOpacity( 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );

    if (isPending) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildImageThumbnail(StatusConfig config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.receipt.receiptImageUrl!,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 8),
                  Text(
                    'تعذر تحميل الصورة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity( 0.3),
                  ],
                ),
              ),
            ),
          ),
          // View icon
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.zoom_in_rounded,
                size: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(StatusConfig config) {
    return Row(
      children: [
        // Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity( 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.payments_rounded,
                size: 16,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.receipt.amountDzd} دج',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              _formatDate(widget.receipt.submittedAt),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity( 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 14,
            color: Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatPaymentMethod(widget.receipt.paymentMethod!),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRef() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity( 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.tag_rounded,
            size: 14,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'رقم العملية: ${widget.receipt.transactionReference}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNotesSection(StatusConfig config) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: config.color.withOpacity( 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: config.color.withOpacity( 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity( 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 16,
                    color: config.color,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ملاحظات الإدارة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: config.color,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: config.color,
                  size: 20,
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.receipt.adminNotes!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReason() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity( 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity( 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity( 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سبب الرفض',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.receipt.rejectionReason!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewedInfo() {
    return Row(
      children: [
        Icon(
          Icons.verified_rounded,
          size: 14,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 6),
        Text(
          'تمت المراجعة: ${_formatDate(widget.receipt.reviewedAt!)}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'أمس ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'baridi_mob':
        return 'Baridi Mob';
      case 'ccp':
        return 'CCP (البريد)';
      case 'bank_transfer':
        return 'تحويل بنكي';
      default:
        return method;
    }
  }
}

/// Configuration for each status type
class StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}
