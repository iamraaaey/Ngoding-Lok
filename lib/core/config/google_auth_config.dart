/// OAuth 2.0 **Web application** client ID for Google Sign-In.
///
/// A client ID is a public identifier — it ships in the served JavaScript of
/// any web app that uses it — so committing it here is safe. The matching
/// client *secret* is not used by this client-side flow and must never be
/// added to this repository.
///
/// For sign-in to work, the origin serving the app must be listed under
/// "Authorized JavaScript origins" for this client ID in the Google Cloud
/// console (APIs & Services → Credentials). For local development add
/// `http://localhost:5000` and run on a fixed port:
///
///   flutter run -d chrome --web-port=5000
const String googleWebClientId =
    '836022818923-rbm8l7qbo63ikhu298qkfu9mt05f2ea2.apps.googleusercontent.com';
