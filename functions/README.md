# NgeCode Juh! Functions — Socratic Hint Engine

A single Firebase Cloud Function, `generateSocraticHint`, that wraps the
Claude API to generate an indirect, non-answer-revealing hint from a
student's in-progress code and a level's objective.

## One-time setup

A `firebase.json` already exists at the repo root pointing at this `functions/`
directory, so you only need to link it to a Firebase project — no need to run
`firebase init`.

```bash
cd functions
npm install

firebase login
firebase use --add   # pick or create a Firebase project; this writes .firebaserc
```

## Configure the Anthropic API key (never commit it)

```bash
firebase functions:secrets:set ANTHROPIC_API_KEY
# paste your key when prompted
```

## Local testing (emulator)

```bash
npm run serve
# POST http://127.0.0.1:5001/<project-id>/us-central1/generateSocraticHint
```

Example request body:

```json
{
  "moduleType": "logic_grid",
  "levelObjective": "Move the player from (0,0) to (3,3).",
  "currentCode": "move.right();\nmove.right();\n"
}
```

## Deploy

```bash
npm run deploy
# or: firebase deploy --only functions:generateSocraticHint
```

Firebase prints the deployed HTTPS URL, e.g.:

```
https://us-central1-<project-id>.cloudfunctions.net/generateSocraticHint
```

Copy that URL into `lib/core/config/backend_config.dart` on the Flutter side
(`hintEndpointUrl`) so the app calls your deployed function.

## Response contract

`POST` with `{ moduleType, levelObjective, currentCode }` →
`200 { hintTitle, hintMessage }` on success, non-2xx on any failure. The
Flutter client (`HintService`) treats any non-2xx or malformed response as a
soft failure and falls back to the module's static hint text — so a
misconfigured or undeployed function degrades gracefully instead of breaking
the app.
