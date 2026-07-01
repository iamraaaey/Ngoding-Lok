import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';

class SocraticHint {
  final String hintTitle;
  final String hintMessage;

  const SocraticHint({required this.hintTitle, required this.hintMessage});
}

/// Client for the `generateSocraticHint` Cloud Function. Never throws:
/// any network error, non-2xx response, or malformed body resolves to
/// `null` so callers can fall back to a module's static hint text rather
/// than surface a broken hint flow when the backend is unreachable or
/// unconfigured.
class HintService {
  final http.Client _client;

  HintService({http.Client? client}) : _client = client ?? http.Client();

  Future<SocraticHint?> fetchSocraticHint({
    required String moduleType,
    required String levelObjective,
    required String currentCode,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(hintEndpointUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'moduleType': moduleType,
              'levelObjective': levelObjective,
              'currentCode': currentCode,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final title = decoded['hintTitle'];
      final message = decoded['hintMessage'];
      if (title is! String || message is! String) return null;

      return SocraticHint(hintTitle: title, hintMessage: message);
    } catch (_) {
      return null;
    }
  }
}
