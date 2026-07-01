/// Deployed Cloud Function endpoint for the Socratic Hint Engine.
///
/// Update this after running `firebase deploy` from `functions/` (see
/// `functions/README.md`). Until it points at a real deployment, hint
/// requests fail fast and every game screen falls back to the module's
/// static hint text.
const String hintEndpointUrl =
    'https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/generateSocraticHint';
