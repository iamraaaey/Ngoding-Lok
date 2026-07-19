import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { GoogleGenAI, Type, Schema } from "@google/genai";

const geminiApiKey = defineSecret("GEMINI_API_KEY");
initializeApp();

const MODULE_DSL_NOTES: Record<string, string> = {
  logic_grid:
    "The student writes movement commands on a grid, one per line: " +
    "move.right(); move.left(); move.up(); move.down();",
  sql_terminal:
    "The student writes a single SQL query against a `users` table to " +
    "satisfy the stated objective.",
  rocket_flight:
    "The student writes a launch sequence, one command per line: " +
    "sys.preflight(); engine.start(); throttle(N); — engine.start() " +
    "before sys.preflight() destroys the rocket, and throttle() before " +
    "engine.start() is a no-op.",
};

const SYSTEM_PROMPT = `You are a strict, encouraging computer science tutor \
inside a coding game. A student is stuck on a level. You will be given the \
level's objective, the student's current (broken or incomplete) code, and \
notes on the mini-language they're writing in.

Your job: identify the single most important flaw preventing their code from \
meeting the objective, and respond with ONE short, indirect hint — phrased \
as a guiding question or observation, never as a direct instruction.

Rules:
- NEVER reveal the corrected code or the exact fix.
- NEVER simply restate the objective back to them.
- Keep the hint to 1-2 sentences.
- If the code is empty or clearly hasn't been started, nudge them toward \
the first concept they need, without giving the answer.`;

interface HintRequestBody {
  moduleType?: string;
  levelObjective?: string;
  currentCode?: string;
}

const responseSchema: Schema = {
  type: Type.OBJECT,
  properties: {
    hintTitle: { type: Type.STRING },
    hintMessage: { type: Type.STRING },
  },
  required: ["hintTitle", "hintMessage"],
};

export const generateSocraticHint = onRequest(
  { secrets: [geminiApiKey], cors: true, region: "us-central1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const authorization = req.get("authorization") ?? "";
    if (!authorization.startsWith("Bearer ")) {
      res.status(401).json({ error: "Firebase authentication is required" });
      return;
    }

    try {
      await getAuth().verifyIdToken(authorization.substring("Bearer ".length));
    } catch (_) {
      res.status(401).json({ error: "Invalid Firebase authentication token" });
      return;
    }

    const body = (req.body ?? {}) as HintRequestBody;
    const moduleType = typeof body.moduleType === "string"
      ? body.moduleType.trim()
      : "";
    const levelObjective = typeof body.levelObjective === "string"
      ? body.levelObjective.trim()
      : "";
    const currentCode = typeof body.currentCode === "string"
      ? body.currentCode.trim()
      : "";

    if (!levelObjective) {
      res.status(400).json({ error: "levelObjective is required" });
      return;
    }
    if (levelObjective.length > 2000 || currentCode.length > 12000) {
      res.status(413).json({ error: "Hint input is too large" });
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });

      const dslNotes =
        MODULE_DSL_NOTES[moduleType] ?? "No additional syntax notes.";

      const prompt = `Level objective: ${levelObjective}\n\nLanguage notes: ${dslNotes}\n\nStudent's current code:\n${currentCode || "(empty)"}`;

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: prompt,
        config: {
          systemInstruction: SYSTEM_PROMPT,
          responseMimeType: "application/json",
          responseSchema: responseSchema,
          temperature: 0.7,
        }
      });

      const responseText = response.text;
      if (!responseText) {
        res.status(502).json({ error: "Model did not return a valid hint" });
        return;
      }

      const parsed = JSON.parse(responseText);

      res.status(200).json(parsed);
    } catch (err) {
      console.error("generateSocraticHint failed", err);
      res.status(502).json({ error: "Hint generation failed" });
    }
  }
);
