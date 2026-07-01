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

  const SqlTerminalConfig({
    required this.table,
    required this.schema,
    required this.instruction,
    required this.requiredSubstrings,
  });
}

class RocketFlightConfig extends ModuleConfig {
  final int targetAltitude;

  const RocketFlightConfig({required this.targetAltitude});
}
