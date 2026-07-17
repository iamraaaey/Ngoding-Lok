import 'curriculum_module.dart';

class SqlCase {
  final String number, title, brief;
  final List<String> objectives;
  final List<SqlCaseTable> tables;
  final String? solution;
  final int? xp;

  const SqlCase(
    this.number,
    this.title,
    this.brief,
    this.objectives, {
    this.tables = const [],
    this.solution,
    this.xp,
  });
}

class SqlCaseTable {
  final String name;
  final List<String> columns;

  const SqlCaseTable(this.name, this.columns);
}

class SqlCaseCatalog {
  static const _defaultCase = SqlCase(
    'CASE',
    'Untitled Investigation',
    'Review the evidence and use SQL to uncover the truth.',
    [
      'Inspect the table schema.',
      'Run a query that answers the case question.',
    ],
  );

  static const Map<String, SqlCase> cases = {
    'm2': SqlCase(
      '001',
      'The Vanishing Briefcase',
      'A valuable briefcase has disappeared from the Blue Note Lounge. A witness saw a man in a trench coat fleeing the scene. Investigate the crime scene, suspects, and interview transcripts to reveal the culprit.',
      [
        'Retrieve the crime-scene details and gather the key clue.',
        'Identify the suspect matching the witness description.',
        'Verify the suspect using the interview transcript.',
      ],
      tables: [
        SqlCaseTable('crime_scene', [
          'id (INTEGER)',
          'date (INTEGER)',
          'type (TEXT)',
          'description (TEXT)',
          'location (TEXT)',
        ]),
        SqlCaseTable('suspects', [
          'id (INTEGER)',
          'name (TEXT)',
          'attire (TEXT)',
          'scar (TEXT)',
        ]),
        SqlCaseTable('interviews', [
          'id (INTEGER)',
          'suspect_id (INTEGER)',
          'transcript (TEXT)',
        ]),
      ],
      solution: 'Vincent Malone',
      xp: 50,
    ),
    'm6': SqlCase(
      '002',
      'The Stolen Sound',
      'A prized vinyl record vanished from West Hollywood Records during a busy evening. The theft occurred on July 15, 1983. Track down the thief and bring them to justice.',
      [
        'Find the crime-scene report using the date and location.',
        'Retrieve the linked witness records and their clues.',
        'Use the clues to identify the suspect and confirm the confession.',
      ],
    ),
    'm9': SqlCase(
      '003',
      'The Miami Marina Murder',
      'A body was found near the docks of Coral Bay Marina in the early hours of August 14, 1986. Use joins, wildcard searches, and logical deduction to find the murderer.',
      [
        'Locate the crime scene at Coral Bay Marina.',
        'Join the evidence and suspect records.',
        'Submit the murderer supported by the evidence.',
      ],
    ),
    'm12': SqlCase(
      '004',
      'The Missing Headcount',
      'A late-night breach left the player registry in disarray. Operations needs a reliable headcount before the city wakes up.',
      [
        'Inspect the player registry schema.',
        'Aggregate the records into one verified count.',
        'Report the number of registered players.',
      ],
    ),
    'j2': SqlCase(
      '005',
      'The Campus Leak',
      'A confidential student record was circulated before exam results were released. Filter the campus records to identify the students involved.',
      [
        'Filter the student records by the required grade.',
        'Return only the names needed by the dean.',
        'Confirm the result without exposing unrelated records.',
      ],
    ),
    'sql-case-006': SqlCase(
      '006',
      'The Counterfeit Ledger',
      'A forged payment appeared in the detective agency ledger. Sort the transactions and isolate the suspicious entry.',
      [
        'Retrieve the ledger entries.',
        'Order the transactions by amount.',
        'Identify the outlier transaction.',
      ],
    ),
    'sql-case-007': SqlCase(
      '007',
      'The Night-Shift Alibi',
      'Three employees claim they were on duty when the evidence disappeared. Match the shift records to the witness statement.',
      [
        'Filter the night-shift records.',
        'Join employees to their assignments.',
        'Return the matching alibi.',
      ],
    ),
    'sql-case-008': SqlCase(
      '008',
      'The Redacted Contact',
      'A redacted contact list contains the final lead in the case. Search carefully: the answer is hidden among partial names and aliases.',
      [
        'Search the contact table with a wildcard.',
        'Return the matching alias.',
        'Use the result as your final lead.',
      ],
    ),
  };

  static SqlCase forModule(CurriculumModule module) =>
      cases[module.id] ?? _defaultCase;
}
