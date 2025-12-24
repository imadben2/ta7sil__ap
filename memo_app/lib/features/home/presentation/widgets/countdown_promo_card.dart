import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/promo_entity.dart';

/// Countdown promo card widget - displays only days/hours/minutes/seconds
/// Clean design with just the countdown boxes
class CountdownPromoCard extends StatefulWidget {
  final PromoEntity promo;
  final VoidCallback? onTap;

  const CountdownPromoCard({
    super.key,
    required this.promo,
    this.onTap,
  });

  @override
  State<CountdownPromoCard> createState() => _CountdownPromoCardState();
}

class _CountdownPromoCardState extends State<CountdownPromoCard> {
  Timer? _timer;
  late int _days;
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    // Update every second for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    setState(() {
      _days = widget.promo.daysRemaining;
      _hours = widget.promo.hoursRemaining;
      _minutes = widget.promo.minutesRemaining;
      _seconds = widget.promo.secondsRemaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse gradient colors from promo entity
    final gradientColors = _parseGradientColors(widget.promo.gradientColors);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCountdownBox(_days.toString(), 'يوم'),
            _buildCountdownBox(_hours.toString().padLeft(2, '0'), 'ساعة'),
            _buildCountdownBox(_minutes.toString().padLeft(2, '0'), 'دقيقة'),
            _buildCountdownBox(_seconds.toString().padLeft(2, '0'), 'ثانية'),
          ],
        ),
      ),
    );
  }

  List<Color> _parseGradientColors(List<String>? colors) {
    if (colors == null || colors.isEmpty) {
      return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]; // Default blue
    }
    return colors.map((c) {
      final hex = c.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }).toList();
  }

  Widget _buildCountdownBox(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
