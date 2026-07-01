import 'curriculum_module.dart';
import 'module_config.dart';
import 'module_type.dart';

/// The fixed set of playable modules, mirroring the `CURRICULUM` array in
/// the original prototype. Static/const — no persistence, matching the
/// in-memory-only mock constraint of this port.
class Curriculum {
  static const List<CurriculumModule> modules = [
    CurriculumModule(
      id: 'm1',
      type: ModuleType.logicGrid,
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
      title: 'Module 3: Aerospace Logic',
      description:
          'Use codeblocks to initiate preflight systems and achieve escape velocity.',
      xpReward: 400,
      hint:
          'Always run sys.preflight() BEFORE engine.start(). Then set throttle(100) to gain altitude!',
      config: RocketFlightConfig(targetAltitude: 100),
      initialCode: '// Construct your launch sequence here\n\n',
    ),
  ];

  static CurriculumModule byId(String id) =>
      modules.firstWhere((m) => m.id == id);
}
