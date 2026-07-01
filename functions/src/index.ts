import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod/v4";

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

const HintResponseSchema = z.object({
  hintTitle: z.string(),
  hintMessage: z.string(),
});

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

export const generateSocraticHint = onRequest(
  { secrets: [anthropicApiKey], cors: true, region: "us-central1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const body = req.body as HintRequestBody;
    const moduleType = body.moduleType ?? "";
    const levelObjective = body.levelObjective ?? "";
    const currentCode = body.currentCode ?? "";

    if (!levelObjective) {
      res.status(400).json({ error: "levelObjective is required" });
      return;
    }

    try {
      const client = new Anthropic({ apiKey: anthropicApiKey.value() });

      const dslNotes =
        MODULE_DSL_NOTES[moduleType] ?? "No additional syntax notes.";

      const response = await client.messages.parse({
        model: "claude-haiku-4-5",
        max_tokens: 512,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: "user",
            content:
              `Level objective: ${levelObjective}\n\n` +
              `Language notes: ${dslNotes}\n\n` +
              `Student's current code:\n${currentCode || "(empty)"}`,
          },
        ],
        output_config: {
          format: zodOutputFormat(HintResponseSchema),
        },
      });

      const parsed = response.parsed_output;
      if (!parsed) {
        res.status(502).json({ error: "Model did not return a valid hint" });
        return;
      }

      res.status(200).json(parsed);
    } catch (err) {
      console.error("generateSocraticHint failed", err);
      res.status(502).json({ error: "Hint generation failed" });
    }
  }
);
