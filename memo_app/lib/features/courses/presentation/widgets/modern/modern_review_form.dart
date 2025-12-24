import 'package:flutter/material.dart';

/// Modern Review Form Widget
/// Allows users to submit a course review
class ModernReviewForm extends StatefulWidget {
  final Function(int rating, String reviewText) onSubmit;
  final bool isLoading;

  const ModernReviewForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ModernReviewForm> createState() => _ModernReviewFormState();
}

class _ModernReviewFormState extends State<ModernReviewForm> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _reviewController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار تقييم',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    widget.onSubmit(_selectedRating, _reviewController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rate_review_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'أضف تقييمك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Star Rating
          const Text(
            'تقييمك للدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          _buildStarSelector(),

          // Rating Description
          if (_selectedRating > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey(_selectedRating),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getRatingColor(_selectedRating).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRatingText(_selectedRating),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getRatingColor(_selectedRating),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Review Text
          const Text(
            'رأيك في الدورة (اختياري)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            focusNode: _focusNode,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'شاركنا رأيك في الدورة...',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey[400],
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFF59E0B),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRating > 0
                    ? const Color(0xFFF59E0B)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'إرسال التقييم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSelector() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          final isSelected = _selectedRating >= starValue;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRating = starValue;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 40,
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF10B981);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return 'ممتاز! 🌟';
      case 4:
        return 'جيد جداً 👍';
      case 3:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 1:
        return 'ضعيف';
      default:
        return '';
    }
  }
}

/// Review Form in Bottom Sheet
void showReviewFormBottomSheet({
  required BuildContext context,
  required Function(int rating, String reviewText) onSubmit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ModernReviewForm(
                    onSubmit: (rating, text) {
                      Navigator.pop(context);
                      onSubmit(rating, text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
