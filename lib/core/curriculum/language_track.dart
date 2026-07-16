/// Learning tracks available from the League Map and curriculum views.
enum LanguageTrack {
  python('Python Track', 'Python'),
  sql('SQL Track', 'SQL'),
  java('Java Track', 'Java'),
  cybersecurity('Cybersecurity Track', 'Cyber');

  final String label;

  /// Compact label for narrow controls such as the Code Golf tabs.
  final String shortLabel;

  const LanguageTrack(this.label, this.shortLabel);
}
