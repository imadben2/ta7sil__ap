import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern code input field with separate boxes
///
/// Features:
/// - Separate boxes for each character
/// - Auto-focus next box on input
/// - Shake animation on error
/// - Paste support
/// - RTL support
/// - Customizable length and styling
class CodeInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool showError;
  final bool autoFocus;
  final bool enabled;
  final Color? activeColor;
  final Color? errorColor;
  final Color? inactiveColor;
  final double boxSize;
  final double spacing;
  final TextInputType keyboardType;
  final bool obscureText;

  const CodeInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.controller,
    this.showError = false,
    this.autoFocus = true,
    this.enabled = true,
    this.activeColor,
    this.errorColor,
    this.inactiveColor,
    this.boxSize = 50,
    this.spacing = 8,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  State<CodeInputField> createState() => CodeInputFieldState();
}

class CodeInputFieldState extends State<CodeInputField>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Sync with external controller if provided
    widget.controller?.addListener(_syncFromController);

    if (widget.autoFocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _syncFromController() {
    // Not needed for now - external controller is for reading value
  }

  void _syncToController() {
    widget.controller?.text = _code;
  }

  @override
  void didUpdateWidget(CodeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shake();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncFromController);
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Trigger shake animation (call from parent using GlobalKey)
  void shake() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  String get _code {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _syncToController();
    widget.onChanged?.call(_code);

    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  void _handlePaste(String value) {
    final chars = value.toUpperCase().split('').take(widget.length).toList();

    for (int i = 0; i < chars.length && i < widget.length; i++) {
      _controllers[i].text = chars[i];
    }

    final lastIndex = chars.length.clamp(0, widget.length - 1);
    _focusNodes[lastIndex].requestFocus();

    _syncToController();
    widget.onChanged?.call(_code);

    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  void _shake() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  /// Clear all input boxes
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? const Color(0xFF2196F3);
    final errorColor = widget.errorColor ?? const Color(0xFFEF4444);
    final inactiveColor = widget.inactiveColor ?? const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value * 10 *
            ((_shakeController.value * 10).toInt().isEven ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr, // Always LTR for code input
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final hasValue = _controllers[index].text.isNotEmpty;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.boxSize,
                height: widget.boxSize,
                decoration: BoxDecoration(
                  color: widget.showError
                      ? errorColor.withOpacity(0.1)
                      : (isFocused || hasValue)
                          ? activeColor.withOpacity(0.1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.showError
                        ? errorColor
                        : isFocused
                            ? activeColor
                            : hasValue
                                ? activeColor.withOpacity(0.5)
                                : inactiveColor,
                    width: isFocused ? 2 : 1.5,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: (widget.showError ? errorColor : activeColor)
                                .withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => _onKeyPressed(index, event),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        enabled: widget.enabled,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          UpperCaseTextFormatter(),
                        ],
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.showError
                              ? errorColor
                              : widget.enabled
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
            );
          }),
        ),
      ),
    );
  }
}

/// Formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
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
