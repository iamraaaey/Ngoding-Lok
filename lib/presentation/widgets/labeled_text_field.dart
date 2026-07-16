import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';

/// Terminal-noir labeled input used by the auth and sign-up forms: a mono
/// uppercase label over a near-black field with a hairline border that warms
/// to ember on focus. Shows an inline validation message below the field
/// when [errorText] is non-null, tinting the border to match.
class LabeledTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? errorText;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.errorText,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? const Color(0xFFFF4D5E)
        : _focused
            ? LandingTokens.ember
            : LandingTokens.hairlineStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// ${widget.label.toUpperCase()}',
          style: LandingTokens.label(fontSize: 10, color: LandingTokens.textMuted),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: LandingTokens.motionFor(context, LandingTokens.motionFast),
          decoration: BoxDecoration(
            color: LandingTokens.voidBlack,
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscure,
            cursorColor: LandingTokens.ember,
            style: LandingTokens.mono(fontSize: 14, color: LandingTokens.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: LandingTokens.mono(fontSize: 14, color: LandingTokens.textFaint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: LandingTokens.mono(fontSize: 12, color: const Color(0xFFFF4D5E)),
          ),
        ],
      ],
    );
  }
}
