/// Deployed Cloud Function endpoint for the Socratic Hint Engine.
///
/// The default points at this repository's Firebase project. A fork can use
/// `--dart-define=HINT_ENDPOINT_URL=...` without editing source code.
const String hintEndpointUrl = String.fromEnvironment(
  'HINT_ENDPOINT_URL',
  defaultValue:
      'https://us-central1-ngoding-lok.cloudfunctions.net/generateSocraticHint',
);
