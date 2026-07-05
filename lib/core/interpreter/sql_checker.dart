import '../curriculum/module_config.dart';

enum SqlCheckResultType { success, missingClause, empty }

class SqlCheckResult {
  final SqlCheckResultType type;
  final List<String> serverLog;
  final String? detail;

  const SqlCheckResult(this.type, {this.serverLog = const [], this.detail});
}

/// Pure function over a query string and its module config. Mirrors the
/// prototype's `targetLogic`: no real SQL parsing, just a normalized
/// substring check against [SqlTerminalConfig.requiredSubstrings]. Never
/// throws.
class SqlChecker {
  SqlCheckResult check(String query, SqlTerminalConfig config) {
    final normalized =
        query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.isEmpty) {
      return const SqlCheckResult(SqlCheckResultType.empty,
          detail: 'Query is empty.');
    }

    final missing = config.requiredSubstrings
        .where((s) => !normalized.contains(s.toLowerCase()))
        .toList();

    if (missing.isNotEmpty) {
      return SqlCheckResult(
        SqlCheckResultType.missingClause,
        detail: 'Missing required clause(s): ${missing.join(", ")}',
      );
    }

    return SqlCheckResult(
      SqlCheckResultType.success,
      serverLog: config.successLog.isNotEmpty
          ? config.successLog
          : const [
              'Connecting to db://prod-cluster-01...',
              'Query accepted. Scanning table...',
              '[1 ROW RETURNED] id: 42, role: \'admin\', password: \'FLAG{sqli_master_99}\'',
              'Access Granted. Module Complete!',
            ],
    );
  }
}
