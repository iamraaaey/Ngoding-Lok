import 'package:flutter/material.dart';
import 'landing_tokens.dart';

/// Brightness-resolved surface colors for the in-app "terminal noir" screens,
/// so the Settings dark/light switch keeps working. Dark is the canonical
/// look (near-black field, hairline borders); light swaps in paper surfaces
/// while keeping the same ember/green accents and structure.
class NoirSkin {
  final Color bg;
  final Color panel;
  final Color panelRaised;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color sub;
  final Color faint;

  const NoirSkin({
    required this.bg,
    required this.panel,
    required this.panelRaised,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.sub,
    required this.faint,
  });

  bool get isDark => bg == LandingTokens.voidBlack;

  static const dark = NoirSkin(
    bg: LandingTokens.voidBlack,
    panel: LandingTokens.carbon,
    panelRaised: LandingTokens.panelRaised,
    border: LandingTokens.hairline,
    borderStrong: LandingTokens.hairlineStrong,
    text: LandingTokens.textPrimary,
    sub: LandingTokens.textMuted,
    faint: LandingTokens.textFaint,
  );

  static const light = NoirSkin(
    bg: Color(0xFFF4F2EC),
    panel: Color(0xFFFFFFFF),
    panelRaised: Color(0xFFF0EEE7),
    border: Color(0x1A000000),
    borderStrong: Color(0x33000000),
    text: Color(0xFF16150F),
    sub: Color(0xFF6A6960),
    faint: Color(0xFF9A988D),
  );

  static NoirSkin of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// The standard hairline panel used across the in-app noir screens.
class NoirPanel extends StatelessWidget {
  final NoirSkin skin;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NoirPanel({
    super.key,
    required this.skin,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: skin.panel,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: skin.border),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: child,
    );
  }
}

/// Shared back-button + title header bar for the in-app noir screens.
class NoirHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final NoirSkin skin;
  final VoidCallback onBack;
  final Widget? trailing;

  const NoirHeader({
    super.key,
    required this.title,
    required this.skin,
    required this.onBack,
    this.eyebrow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: skin.borderStrong),
                ),
                child: Icon(Icons.arrow_back, color: skin.text, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(
                    '// ${eyebrow!.toUpperCase()}',
                    style: LandingTokens.label(
                      fontSize: 9,
                      color: LandingTokens.ember,
                    ),
                  ),
                if (eyebrow != null) const SizedBox(height: 2),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.display(fontSize: 20, color: skin.text),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
