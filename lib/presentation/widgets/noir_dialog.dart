import 'package:flutter/material.dart';

import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';
import 'landing/landing_surface.dart';

/// Opens a modal in the terminal noir style with a fade + subtle scale
/// entrance. Honors the platform reduced-motion setting (renders instantly).
Future<T?> showNoirDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final reduced = LandingTokens.reducedMotion(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0xCC000000),
    transitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 240),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, animation, _, child) {
      if (reduced) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: Transform.scale(
          scale: 0.96 + 0.04 * curved.value,
          child: child,
        ),
      );
    },
  );
}

/// The shared chrome for every noir modal: a carbon panel with a hairline
/// border, an iridescent accent strip along the top, a mono eyebrow, a heavy
/// display title, an optional metadata line, a scrollable body, and a row of
/// actions pinned to the bottom.
class NoirDialogShell extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? meta;
  final Widget child;
  final List<Widget> actions;
  final double maxWidth;
  final double maxHeight;

  const NoirDialogShell({
    super.key,
    required this.title,
    required this.child,
    this.eyebrow,
    this.meta,
    this.actions = const <Widget>[],
    this.maxWidth = 480,
    this.maxHeight = 620,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: LandingTokens.carbon,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(color: LandingTokens.hairlineStrong),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 3,
                child: AnimatedIridescence(borderRadius: BorderRadius.zero),
              ),
              // Flexible so the content area (and its scroll view) receives a
              // bounded height from the dialog's maxHeight rather than the
              // unbounded main-axis constraint an inflexible child would get.
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (eyebrow != null) ...[
                        Text(
                          '// ${eyebrow!.toUpperCase()}',
                          style: LandingTokens.label(
                            color: LandingTokens.ember,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(title, style: LandingTokens.display(fontSize: 24)),
                      if (meta != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          meta!.toUpperCase(),
                          style: LandingTokens.label(
                            fontSize: 9.5,
                            color: LandingTokens.textFaint,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Flexible(child: child),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (var i = 0; i < actions.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              actions[i],
                            ],
                          ],
                        ),
                      ],
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
}

/// Convenience CLOSE action used by most read-only noir dialogs.
class NoirCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NoirCloseButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: 'Close',
      compact: true,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Shows a terminal-styled snackbar: near-black surface, hairline border,
/// mono "> message" copy, and a square ember status tick.
void showNoirSnack(BuildContext context, String message, {bool success = true}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LandingTokens.carbon,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: LandingTokens.mediumRadius,
        side: const BorderSide(color: LandingTokens.hairlineStrong),
      ),
      content: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            color: success ? LandingTokens.signal : LandingTokens.ember,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '> $message',
              style: LandingTokens.mono(
                fontSize: 13,
                color: LandingTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
