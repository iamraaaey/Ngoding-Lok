/// Central registry for Figma/Canva exports used by the marketing landing page.
///
/// These are intentionally path constants only: this project ships no copied
/// reference artwork or binary placeholders. When final assets are exported,
/// place them under `assets/landing/`, add that directory to `pubspec.yaml`,
/// and swap the files without changing widget code.
abstract final class LandingAssets {
  LandingAssets._();

  static const String directory = 'assets/landing';

  /// Original composited scene: grid puzzle, code snippets, rocket, and AI
  /// hint bubble. Prefer the composable Flutter illustration until this exists.
  static const String heroCodingAdventure =
      '$directory/hero-coding-adventure.png';

  /// Optional transparent grain layer for the cinematic page background.
  static const String grainTexture = '$directory/grain-overlay.png';

  /// Optional decorative star/particle layer; use with low opacity only.
  static const String ambientParticles = '$directory/ambient-particles.png';

  /// Optional isolated visual exports for responsive hero variants.
  static const String puzzleGrid = '$directory/puzzle-grid.png';
  static const String missionRocket = '$directory/mission-rocket.png';
  static const String aiHintOrb = '$directory/ai-hint-orb.png';

  /// Placeholder logo exports for future social-proof partners. Do not imply
  /// endorsements until real, approved logo artwork is supplied.
  static const String socialProofLogoOne =
      '$directory/social-proof-logo-01.png';
  static const String socialProofLogoTwo =
      '$directory/social-proof-logo-02.png';
  static const String socialProofLogoThree =
      '$directory/social-proof-logo-03.png';
  static const String socialProofLogoFour =
      '$directory/social-proof-logo-04.png';

  /// Clearly replaceable student/testimonial portrait placeholders.
  static const String testimonialAvatarOne =
      '$directory/testimonial-avatar-01.png';
  static const String testimonialAvatarTwo =
      '$directory/testimonial-avatar-02.png';
  static const String testimonialAvatarThree =
      '$directory/testimonial-avatar-03.png';

  /// A convenience list for preloading assets once the files are supplied.
  static const List<String> all = <String>[
    heroCodingAdventure,
    grainTexture,
    ambientParticles,
    puzzleGrid,
    missionRocket,
    aiHintOrb,
    socialProofLogoOne,
    socialProofLogoTwo,
    socialProofLogoThree,
    socialProofLogoFour,
    testimonialAvatarOne,
    testimonialAvatarTwo,
    testimonialAvatarThree,
  ];
}
