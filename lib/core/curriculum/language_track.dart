/// Programming-language tracks the League Map can filter by. Only [python]
/// has playable content in this prototype; [java] is a preview of planned
/// content and renders as locked "coming soon" levels, which also usefully
/// demonstrates the map's locked-level treatment.
enum LanguageTrack {
  python('Python Track'),
  java('Java Track');

  final String label;
  const LanguageTrack(this.label);
}
