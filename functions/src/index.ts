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
  cybersecurity_room:
    "This is an educational, simulated cybersecurity room. The student may " +
    "inspect fictional evidence, choose safe defensive actions, or answer " +
    "scenario questions. Keep the advice defensive, high-level, and specific " +
    "to the safe simulation; never provide real-world exploitation steps, " +
    "malicious payloads, or credential-harvesting guidance.",
  arduino_simulator:
    "The student works in an embedded Wokwi ESP32 simulation. Guide them to " +
    "inspect the sketch, run the simulation, and use the serial monitor. Do " +
    "not invent a complete sketch or reveal a finished implementation.",
};

const SYSTEM_PROMPT = `You are a strict, encouraging computer science tutor \
inside a coding game. A student is stuck on a level. You will be given the \
level's objective, their current work (which can be code, answers, or a \
description of their actions), and notes on the kind of module they're using.

Your job: identify the single most important flaw preventing their current work from \
meeting the objective, and respond with ONE short, indirect hint — phrased \
as a guiding question or observation, never as a direct instruction.

Rules:
- NEVER reveal the corrected code or the exact fix.
- NEVER simply restate the objective back to them.
- Keep the hint to 1-2 sentences.
- If the current work is empty or clearly hasn't been started, nudge them toward \
the first concept they need, without giving the answer.`;

interface HintRequestBody {
  moduleType?: string;
  moduleId?: string;
  moduleTitle?: string;
  moduleContext?: string;
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
    const moduleId = typeof body.moduleId === "string" ? body.moduleId.trim() : "";
    const moduleTitle = typeof body.moduleTitle === "string"
      ? body.moduleTitle.trim()
      : "";
    const moduleContext = typeof body.moduleContext === "string"
      ? body.moduleContext.trim()
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
    if (
      moduleId.length > 200 ||
      moduleTitle.length > 500 ||
      moduleContext.length > 8000 ||
      levelObjective.length > 2000 ||
      currentCode.length > 12000
    ) {
      res.status(413).json({ error: "Hint input is too large" });
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });

      const dslNotes =
        MODULE_DSL_NOTES[moduleType] ?? "No additional syntax notes.";

      const prompt = `Module: ${moduleTitle || moduleId || moduleType || "Unknown module"}\n\nLevel objective: ${levelObjective}\n\nModule context: ${moduleContext || "No additional context."}\n\nLanguage notes: ${dslNotes}\n\nStudent's current work:\n${currentCode || "(not started)"}`;

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
