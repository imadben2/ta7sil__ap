import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern animated code input with premium styling
///
/// Features:
/// - Gradient border animations on focus
/// - Smooth transitions between states
/// - Premium shadow effects
/// - Shake animation on error
/// - Auto-advance to next field
/// - Paste support
class ModernCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool enabled;
  final bool autoFocus;

  const ModernCodeInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.controller,
    this.enabled = true,
    this.autoFocus = true,
  });

  @override
  State<ModernCodeInput> createState() => ModernCodeInputState();
}

class ModernCodeInputState extends State<ModernCodeInput>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<AnimationController> _scaleControllers;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );

    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        setState(() {
          _focusedIndex = node.hasFocus ? index : _focusedIndex;
        });
        if (node.hasFocus) {
          _scaleControllers[index].forward();
        } else {
          _scaleControllers[index].reverse();
        }
      });
      return node;
    });

    _scaleControllers = List.generate(
      widget.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      ),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    if (widget.autoFocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void shake() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    widget.controller?.text = '';
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    widget.controller?.text = _code;
    widget.onChanged?.call(_code);

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  void _handlePaste(String value) {
    final chars = value.toUpperCase().split('').take(widget.length).toList();

    for (int i = 0; i < chars.length && i < widget.length; i++) {
      _controllers[i].text = chars[i];
    }

    final lastIndex = (chars.length - 1).clamp(0, widget.length - 1);
    _focusNodes[lastIndex].requestFocus();

    widget.controller?.text = _code;
    widget.onChanged?.call(_code);

    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        widget.controller?.text = _code;
        widget.onChanged?.call(_code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value * 12 *
            ((_shakeController.value * 10).toInt().isEven ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive box size based on available width
            final availableWidth = constraints.maxWidth;
            final horizontalMargin = 4.0 * 2; // margin on each side
            final totalMargins = horizontalMargin * widget.length;
            final boxWidth = ((availableWidth - totalMargins) / widget.length).clamp(36.0, 52.0);
            final boxHeight = (boxWidth * 1.18).clamp(44.0, 60.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (index) {
                return _buildCodeBox(index, boxWidth, boxHeight);
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index, double boxWidth, double boxHeight) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    final fontSize = (boxWidth * 0.45).clamp(16.0, 22.0);

    return AnimatedBuilder(
      animation: _scaleControllers[index],
      builder: (context, child) {
        final scale = 1.0 + (_scaleControllers[index].value * 0.05);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: boxWidth,
          height: boxHeight,
          decoration: BoxDecoration(
            gradient: isFocused
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ]
                : hasValue
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
          ),
          child: Container(
            margin: isFocused ? const EdgeInsets.all(2) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isFocused
                  ? Colors.white
                  : hasValue
                      ? const Color(0xFFF8F5FF)
                      : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(isFocused ? 10 : 12),
              border: isFocused
                  ? null
                  : Border.all(
                      color: hasValue
                          ? const Color(0xFF8B5CF6).withOpacity(0.3)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
            ),
            child: Material(
              color: Colors.transparent,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _onKeyPressed(index, event),
                child: Center(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      _UpperCaseTextFormatter(),
                    ],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: hasValue
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
