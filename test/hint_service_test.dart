import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ngecode_juh/core/session/hint_service.dart';

void main() {
  group('HintService.fetchSocraticHint', () {
    test('parses a successful response into a SocraticHint', () async {
      late Map<String, dynamic> requestBody;
      final client = MockClient((request) async {
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'hintTitle': 'Look closer',
            'hintMessage': 'What happens to your counter each loop?',
          }),
          200,
        );
      });
      final service = HintService(client: client);

      final result = await service.fetchSocraticHint(
        moduleType: 'logic_grid',
        moduleId: 'm1',
        moduleTitle: 'Module 1: Sequential Steps',
        levelObjective: 'Reach the flag.',
        moduleContext: 'Grid size: 5x5. Start: (0, 0). Target: (3, 3).',
        currentCode: 'move.right();',
      );

      expect(result, isNotNull);
      expect(result!.hintTitle, 'Look closer');
      expect(result.hintMessage, 'What happens to your counter each loop?');
      expect(requestBody['moduleId'], 'm1');
      expect(requestBody['moduleTitle'], 'Module 1: Sequential Steps');
      expect(requestBody['moduleContext'], contains('Grid size: 5x5'));
    });

    test('returns null on a non-200 response', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final service = HintService(client: client);

      final result = await service.fetchSocraticHint(
        moduleType: 'logic_grid',
        levelObjective: 'Reach the flag.',
        currentCode: 'move.right();',
      );

      expect(result, isNull);
    });

    test('returns null on a malformed body', () async {
      final client = MockClient(
        (request) async => http.Response('not json', 200),
      );
      final service = HintService(client: client);

      final result = await service.fetchSocraticHint(
        moduleType: 'logic_grid',
        levelObjective: 'Reach the flag.',
        currentCode: 'move.right();',
      );

      expect(result, isNull);
    });

    test('returns null when the request throws', () async {
      final client = MockClient(
        (request) async => throw Exception('network down'),
      );
      final service = HintService(client: client);

      final result = await service.fetchSocraticHint(
        moduleType: 'logic_grid',
        levelObjective: 'Reach the flag.',
        currentCode: 'move.right();',
      );

      expect(result, isNull);
    });
  });
}
