/// Per-module-type configuration. Sealed so each game screen's `switch` on
/// `module.config` is exhaustive and type-safe, instead of pulling typed
/// fields out of a loosely-typed `Map<String, dynamic>`.
sealed class ModuleConfig {
  const ModuleConfig();
}

class LogicGridConfig extends ModuleConfig {
  final int playerX;
  final int playerY;
  final int targetX;
  final int targetY;
  final int gridSize;

  const LogicGridConfig({
    this.playerX = 0,
    this.playerY = 0,
    required this.targetX,
    required this.targetY,
    this.gridSize = 5,
  });
}

/// The TSX prototype's `targetLogic` is a JS closure over the query text.
/// Dart config classes hold plain data instead, and [SqlChecker] (in
/// `core/interpreter/sql_checker.dart`) is the pure function that turns
/// [requiredSubstrings] + a query string into a verdict.
class SqlTerminalConfig extends ModuleConfig {
  final String table;
  final List<String> schema;
  final String instruction;
  final List<String> requiredSubstrings;

  /// Story-appropriate server output printed on success. When empty,
  /// [SqlChecker] falls back to the original Module 2 "admin password"
  /// transcript so the first SQL level keeps its exact original behavior.
  final List<String> successLog;

  const SqlTerminalConfig({
    required this.table,
    required this.schema,
    required this.instruction,
    required this.requiredSubstrings,
    this.successLog = const [],
  });
}

class RocketFlightConfig extends ModuleConfig {
  final int targetAltitude;

  const RocketFlightConfig({required this.targetAltitude});
}

/// Points at a JSON-only cybersecurity room. Keeping authored tasks and
/// terminal transcripts in an asset lets content writers add rooms without
/// modifying the game engine.
class CyberSecurityConfig extends ModuleConfig {
  final String roomAsset;
  const CyberSecurityConfig({required this.roomAsset});
}

/// Configuration for a Wokwi-hosted, hands-on hardware lesson. The simulator
/// contains the code editor, circuit canvas, and run controls in one place.
class ArduinoSimulatorConfig extends ModuleConfig {
  final String projectUrl;
  final String instruction;

  const ArduinoSimulatorConfig({
    required this.projectUrl,
    required this.instruction,
  });
}
