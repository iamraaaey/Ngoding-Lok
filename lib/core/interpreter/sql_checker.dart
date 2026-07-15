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
  String _normalize(String s) {
    var val = s.trim().toLowerCase();
    val = val.replaceAll('"', "'");
    val = val.replaceAllMapped(RegExp(r'\s*([=><!(),])\s*'), (Match m) => m[1]!);
    val = val.replaceAll(RegExp(r'\s+'), ' ');
    if (val.endsWith(';')) {
      val = val.substring(0, val.length - 1);
    }
    return val.trim();
  }

  SqlCheckResult check(String query, SqlTerminalConfig config) {
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) {
      return const SqlCheckResult(SqlCheckResultType.empty,
          detail: 'Query is empty.');
    }

    final missing = <String>[];
    for (final s in config.requiredSubstrings) {
      final normalizedReq = _normalize(s);
      if (normalizedReq == "role='admin'") {
        final hasRole = normalizedQuery.contains("role='admin'");
        final hasUser = normalizedQuery.contains("username='admin'");
        if (!hasRole && !hasUser) {
          missing.add(s);
        }
      } else {
        if (!normalizedQuery.contains(normalizedReq)) {
          missing.add(s);
        }
      }
    }

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
