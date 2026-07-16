import 'curriculum_module.dart';
import 'language_track.dart';
import 'module_config.dart';
import 'module_type.dart';

/// The fixed set of playable modules, mirroring the `CURRICULUM` array in
/// the original prototype. Static/const — no persistence, matching the
/// in-memory-only mock constraint of this port.
class Curriculum {
  static const List<CurriculumModule> modules = [
    CurriculumModule(
      id: 'cyber-warmup',
      type: ModuleType.cybersecurityRoom,
      track: LanguageTrack.cybersecurity,
      title: 'Cyber Lab: Warmup Web Server',
      description:
          'Explore a safe simulated server and capture your first flag.',
      xpReward: 350,
      hint: 'Use the simulated terminal to explore target.thm.',
      config: CyberSecurityConfig(
        roomAsset: 'assets/rooms/warmup_web_server.json',
      ),
      initialCode: '',
    ),
    CurriculumModule(
      id: 'cyber-default-credentials',
      type: ModuleType.cybersecurityRoom,
      track: LanguageTrack.cybersecurity,
      title: 'Cyber Lab: Training Portal Login',
      description: 'Explore a fake browser login and a safe SQL input lesson.',
      xpReward: 375,
      hint: 'Use the browser mockup and its simulated Inspect panel.',
      config: CyberSecurityConfig(
        roomAsset: 'assets/rooms/browser_sql_login.json',
      ),
      initialCode: '',
    ),
    CurriculumModule(
      id: 'cyber-pick-right-exploit',
      type: ModuleType.cybersecurityRoom,
      track: LanguageTrack.cybersecurity,
      title: 'Cyber Lab: Pick the Right Exploit',
      description: 'Read scan evidence and match the correct safe technique.',
      xpReward: 400,
      hint: 'Compare the service banner with the candidate techniques.',
      config: CyberSecurityConfig(
        roomAsset: 'assets/rooms/brute_force_simulator.json',
      ),
      initialCode: '',
    ),
    CurriculumModule(
      id: 'cyber-soc-defense',
      type: ModuleType.cybersecurityRoom,
      track: LanguageTrack.cybersecurity,
      title: 'Cyber Lab: SOC Dashboard Defense',
      description: 'React to scripted network traffic and block real threats.',
      xpReward: 425,
      hint: 'Use the traffic legend and block the three red entries.',
      config: CyberSecurityConfig(
        roomAsset: 'assets/rooms/caesar_cipher_puzzle.json',
      ),
      initialCode: '',
    ),
    CurriculumModule(
      id: 'cyber-red-blue-capstone',
      type: ModuleType.cybersecurityRoom,
      track: LanguageTrack.cybersecurity,
      title: 'Cyber Lab: Red Team vs Blue Team',
      description: 'Explore a toy weakness, patch it, and re-test the system.',
      xpReward: 450,
      hint: 'Follow the attacker phase, then complete the defender phase.',
      config: CyberSecurityConfig(
        roomAsset: 'assets/rooms/hidden_file_hunt.json',
      ),
      initialCode: '',
    ),
    CurriculumModule(
      id: 'm1',
      type: ModuleType.logicGrid,
      track: LanguageTrack.python,
      title: 'Module 1: Sequential Steps',
      description: 'Learn basic movement commands to navigate the grid.',
      xpReward: 100,
      hint:
          'Count the grid squares carefully. You need exactly 3 right moves and 3 down moves.',
      config: LogicGridConfig(targetX: 3, targetY: 3, gridSize: 5),
      initialCode: 'move.right();\nmove.right();\n',
    ),
    CurriculumModule(
      id: 'm2',
      type: ModuleType.sqlTerminal,
      track: LanguageTrack.python,
      title: 'Module 2: Intro to SQL',
      description: 'Query a database to extract sensitive information.',
      xpReward: 250,
      hint:
          "The database uses 'admin' as the role. Ensure your WHERE clause targets role='admin'.",
      config: SqlTerminalConfig(
        table: 'users',
        schema: ['id (int)', 'username (str)', 'role (str)', 'password (str)'],
        instruction: "Find the password for the 'admin' user.",
        requiredSubstrings: ['select', 'from users', 'where', "role='admin'"],
      ),
      initialCode: "SELECT * \nFROM users \nWHERE role = 'user';",
    ),
    CurriculumModule(
      id: 'm3',
      type: ModuleType.rocketFlight,
      track: LanguageTrack.python,
      title: 'Module 3: Aerospace Logic',
      description:
          'Use codeblocks to initiate preflight systems and achieve escape velocity.',
      xpReward: 400,
      hint:
          'Always run sys.preflight() BEFORE engine.start(). Then set throttle(100) to gain altitude!',
      config: RocketFlightConfig(targetAltitude: 100),
      initialCode: '// Construct your launch sequence here\n\n',
    ),
    CurriculumModule(
      id: 'm4',
      type: ModuleType.logicGrid,
      track: LanguageTrack.python,
      title: 'Module 4: Backtrack Basics',
      description:
          'You start at the bottom-right corner. Retrace your steps with move.left() and move.up().',
      xpReward: 150,
      hint:
          'The flag is at the top-left. You need exactly 4 move.left() and 4 move.up() calls — in any order.',
      config: LogicGridConfig(
        playerX: 4,
        playerY: 4,
        targetX: 0,
        targetY: 0,
        gridSize: 5,
      ),
      initialCode:
          '// New commands unlocked: move.left() and move.up()\nmove.left();\n',
    ),
    CurriculumModule(
      id: 'm5',
      type: ModuleType.logicGrid,
      track: LanguageTrack.python,
      title: 'Module 5: The Long Trek',
      description:
          'A bigger 7x7 frontier. Plan a longer route across the wilderness to the far corner.',
      xpReward: 200,
      hint:
          'The target sits at (6,6): six squares right and six squares down. Miscounting even one step strands you.',
      config: LogicGridConfig(targetX: 6, targetY: 6, gridSize: 7),
      initialCode: 'move.right();\nmove.right();\nmove.right();\n',
    ),
    CurriculumModule(
      id: 'm6',
      type: ModuleType.sqlTerminal,
      track: LanguageTrack.python,
      title: 'Module 6: Filtering 101',
      description:
          'Query the student records to list everyone with a perfect grade.',
      xpReward: 300,
      hint:
          "SELECT the name column FROM students, and filter with WHERE grade='A' — written exactly like that, no spaces around the = sign.",
      config: SqlTerminalConfig(
        table: 'students',
        schema: ['id (int)', 'name (str)', 'score (int)', 'grade (str)'],
        instruction: "List the names of all students whose grade is 'A'.",
        requiredSubstrings: ['select', 'name', 'from students', "grade='a'"],
        successLog: [
          'Connecting to db://campus-records...',
          'Query accepted. Scanning 1,204 student rows...',
          "[3 ROWS RETURNED] 'Aina', 'Jonathan', 'Mei Ling' — grade: 'A'",
          'Dean\'s list compiled. Module Complete!',
        ],
      ),
      initialCode: 'SELECT * \nFROM students;',
    ),
    CurriculumModule(
      id: 'm7',
      type: ModuleType.rocketFlight,
      track: LanguageTrack.python,
      title: 'Module 7: High Orbit',
      description:
          'Mission control needs a satellite parked at 250km. Sequence the launch and keep climbing.',
      xpReward: 350,
      hint:
          'Same drill: sys.preflight(), engine.start(), then stack throttle() calls. Each throttle(N) climbs N/5 km — reach 250.',
      config: RocketFlightConfig(targetAltitude: 250),
      initialCode: '// Park the satellite at 250km\nsys.preflight();\n',
    ),
    CurriculumModule(
      id: 'm8',
      type: ModuleType.logicGrid,
      track: LanguageTrack.python,
      title: 'Module 8: Center Escape',
      description:
          'Dropped in the middle of a 6x6 grid, the extraction point is at the top-right. Mix your directions.',
      xpReward: 400,
      hint:
          'From (2,2), the flag at (5,0) needs 3 move.right() and 2 move.up() — up means y gets SMALLER.',
      config: LogicGridConfig(
        playerX: 2,
        playerY: 2,
        targetX: 5,
        targetY: 0,
        gridSize: 6,
      ),
      initialCode: '// You start mid-grid at (2,2)\n\n',
    ),
    CurriculumModule(
      id: 'm9',
      type: ModuleType.sqlTerminal,
      track: LanguageTrack.python,
      title: 'Module 9: Sorting Secrets',
      description:
          'The tournament board is a mess. Order the score table from best to worst.',
      xpReward: 450,
      hint:
          'SELECT everything FROM scores, then add ORDER BY points DESC to rank from highest to lowest.',
      config: SqlTerminalConfig(
        table: 'scores',
        schema: ['player (str)', 'points (int)', 'season (int)'],
        instruction: 'Return all rows sorted by points from highest to lowest.',
        requiredSubstrings: ['select', 'from scores', 'order by', 'desc'],
        successLog: [
          'Connecting to db://tournament-board...',
          'Query accepted. Sorting 88 rows...',
          "[TOP ROW] player: 'Alice_Hacker', points: 4500",
          'Leaderboard rebuilt. Module Complete!',
        ],
      ),
      initialCode: 'SELECT * \nFROM scores;',
    ),
    CurriculumModule(
      id: 'm10',
      type: ModuleType.rocketFlight,
      track: LanguageTrack.python,
      title: 'Module 10: Gravity Well',
      description:
          'A heavy payload and a hungry planet: fight your way out to 400km before fuel discipline slips.',
      xpReward: 500,
      hint:
          'The sequence never changes — preflight, start, throttle. Bigger throttle values climb faster, but every line costs score.',
      config: RocketFlightConfig(targetAltitude: 400),
      initialCode: '// Escape the gravity well: 400km\n\n',
    ),
    CurriculumModule(
      id: 'm11',
      type: ModuleType.logicGrid,
      track: LanguageTrack.python,
      title: 'Module 11: The Grand Maze',
      description:
          'An 8x8 monster grid. Start at the top-right, finish at the bottom-left. No wrong turns.',
      xpReward: 550,
      hint:
          'From (7,0) to (0,7): seven move.left() and seven move.down(). Fourteen perfect steps.',
      config: LogicGridConfig(
        playerX: 7,
        playerY: 0,
        targetX: 0,
        targetY: 7,
        gridSize: 8,
      ),
      initialCode: '// The final navigation exam\n\n',
    ),
    CurriculumModule(
      id: 'm12',
      type: ModuleType.sqlTerminal,
      track: LanguageTrack.python,
      title: 'Module 12: Counting Heads',
      description:
          'Ops needs a headcount. Aggregate the player table instead of eyeballing it.',
      xpReward: 600,
      hint:
          'Use the COUNT( function: SELECT COUNT(*) FROM players gives one number instead of every row.',
      config: SqlTerminalConfig(
        table: 'players',
        schema: ['id (int)', 'username (str)', 'online (bool)'],
        instruction: 'Count how many players are registered on the platform.',
        requiredSubstrings: ['select', 'count(', 'from players'],
        successLog: [
          'Connecting to db://player-registry...',
          'Query accepted. Aggregating...',
          '[1 ROW RETURNED] count: 5,283',
          'Headcount delivered. Module Complete!',
        ],
      ),
      initialCode: 'SELECT username \nFROM players;',
    ),
    CurriculumModule(
      id: 'm13',
      type: ModuleType.rocketFlight,
      track: LanguageTrack.python,
      title: 'Module 13: Escape Velocity',
      description:
          'The graduation flight: leave the planet for good. 600km, one flawless launch sequence.',
      xpReward: 700,
      hint:
          'Everything you know in one script: sys.preflight(), engine.start(), then enough throttle() to bank 600km of altitude.',
      config: RocketFlightConfig(targetAltitude: 600),
      initialCode: '// Final mission: 600km\n\n',
    ),
    // Java track modules
    CurriculumModule(
      id: 'j1',
      type: ModuleType.logicGrid,
      track: LanguageTrack.java,
      title: 'Java Level 1: Variables & Method Calls',
      description:
          'Navigate the grid using precise Java-like sequential method calls.',
      xpReward: 100,
      hint:
          'Remember that Java uses semicolons. Direct the robot with 3 right moves and 3 down moves.',
      config: LogicGridConfig(targetX: 3, targetY: 3, gridSize: 5),
      initialCode: 'move.right();\nmove.right();\n',
    ),
    CurriculumModule(
      id: 'j2',
      type: ModuleType.sqlTerminal,
      track: LanguageTrack.java,
      title: 'Java Level 2: Control Flow Filtering',
      description:
          'Filter records from database tables based on structured conditions.',
      xpReward: 250,
      hint:
          "Make sure you filter where grade is 'A'. Written exactly as: grade='A'",
      config: SqlTerminalConfig(
        table: 'students',
        schema: ['id (int)', 'name (str)', 'grade (str)'],
        instruction: "List the names of all students whose grade is 'A'.",
        requiredSubstrings: ['select', 'name', 'from students', "grade='a'"],
        successLog: [
          'Database search complete.',
          '[3 ROWS RETURNED] grade: \'A\'',
        ],
      ),
      initialCode: 'SELECT * FROM students;',
    ),
    CurriculumModule(
      id: 'j3',
      type: ModuleType.rocketFlight,
      track: LanguageTrack.java,
      title: 'Java Level 3: Space Object Control',
      description:
          'Initiate systems and launch the spacecraft to 150km using object properties.',
      xpReward: 400,
      hint:
          'First call sys.preflight(); and engine.start();, then add throttle(150); to reach altitude.',
      config: RocketFlightConfig(targetAltitude: 150),
      initialCode: 'sys.preflight();\nengine.start();\n',
    ),
  ];

  static CurriculumModule byId(String id) =>
      modules.firstWhere((m) => m.id == id);
}
