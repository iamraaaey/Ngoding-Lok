// Manual debug script, run with `dart run test_socratic_hint.dart`;
// console output is the whole point here.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify the Socratic Hint endpoint works end-to-end.
/// This makes a direct HTTP call to the Firebase Cloud Function.
Future<void> main() async {
  print('🧪 Testing Socratic Hints Feature...\n');

  const String functionUrl =
      'https://us-central1-ngoding-lok.cloudfunctions.net/generateSocraticHint';

  // Example hint request
  final request = {
    'moduleType': 'logic_grid',
    'levelObjective': 'Move the player to the flag at position (3, 3).',
    'currentCode': 'move.right();\nmove.right();',
  };

  print('📤 Sending request to: $functionUrl');
  print('Request body:');
  print(jsonEncode(request));
  print('\n---\n');

  try {
    // Note: This will fail with 401 because we don't have a Firebase auth token.
    // But it shows the endpoint is working.
    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    ).timeout(const Duration(seconds: 10));

    print('📥 Response status: ${response.statusCode}');
    print('Response body:');
    print(response.body);
    print('\n---\n');

    if (response.statusCode == 200) {
      final hint = jsonDecode(response.body);
      print('✅ SUCCESS! Hint from Claude Haiku:');
      print('   Title: ${hint['hintTitle']}');
      print('   Message: ${hint['hintMessage']}');
    } else if (response.statusCode == 401) {
      print('⚠️  Got 401 Unauthorized (expected - no Firebase token).');
      print('This means the Cloud Function IS deployed and responding.');
      print('In the app, Firebase auth will provide the token automatically.');
    } else {
      print('❌ Unexpected response: ${response.statusCode}');
      print('Check that the Cloud Function is deployed.');
    }
  } catch (e) {
    print('❌ Error: $e');
    print('Make sure:');
    print('  1. Internet connection is working');
    print('  2. Cloud Function was deployed: firebase deploy --only functions');
    print('  3. API key was saved in Firebase Secret Manager');
  }
}
