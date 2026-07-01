# Final Year Project Proposal

## Project Title
**NgeCode Juh!: An AI-Assisted Gamified Platform for Teaching Foundational Programming Concepts**

| | |
|---|---|
| **Prepared By** | Raynold Anak Kabai (Senior-Level Standing) |
| **Institution** | UNIMAS — Universiti Malaysia Sarawak |
| **Program** | Bachelor of Software Engineering (Hons) |

---

## 1. Background of Project

Learning to program is one of the most difficult transitions in a computer
science education. Beginners must simultaneously master syntax, logical
sequencing, and abstract problem-solving — often through static exercises
(textbook questions, isolated compiler output) that provide little
motivation and delayed, low-quality feedback. Research in computing
education consistently reports high dropout and failure rates in
introductory programming courses, frequently attributed to low engagement
and a lack of timely, appropriately-scaffolded feedback when a student gets
stuck.

Two trends motivate this project. First, **gamification** — applying game
mechanics such as levels, scoring, streaks, and leaderboards to
non-game contexts — has been shown to improve engagement and persistence in
educational settings when the underlying learning tasks remain sound.
Second, the recent maturity of **large language models (LLMs)** makes it
practical, for the first time, to generate contextual, code-aware guidance
in real time, rather than relying on a fixed bank of pre-written hints.

This project, *NgeCode Juh!*, combines both trends: a cross-platform Flutter
application that teaches programming fundamentals (sequential logic, SQL
querying, and ordered/state-dependent command execution) through three
distinct interactive puzzle modules, wrapped in a game-like progression
system (XP, a leaderboard, and module completion tracking), and augmented
with an LLM-backed **Socratic Hint Engine** that analyzes a student's actual
in-progress code and responds with an indirect, non-answer-revealing hint
rather than a canned tip or the solution itself.

A working prototype already exists at the time of writing this proposal: a
Flutter client implementing three playable modules on top of a shared,
pure-function interpreter architecture (a custom lexer/parser pipeline per
module), a mock authentication/dashboard/leaderboard layer, and a deployed
Firebase Cloud Function that calls the Claude API to generate hints. This
proposal seeks approval to develop this prototype into a complete Final
Year Project, with the existing implementation serving as the foundation
for further development, evaluation, and refinement under supervision.

---

## 2. Problem Statement

1. **Conventional programming exercises are unengaging.** Most introductory
   programming platforms present problems as plain text with a code editor
   and a pass/fail test runner, offering no narrative or progression
   structure to sustain motivation over a multi-week course.

2. **Feedback on stuck students is either absent or too revealing.**
   When a beginner cannot proceed, existing tools typically offer nothing
   (a blank error message) or a hint bank that, when exhausted, reveals the
   full solution — short-circuiting the learning process. Neither extreme
   supports the kind of guided discovery ("Socratic") feedback that
   pedagogical research favors.

3. **Hints are not tailored to what the student actually wrote.** A static
   hint written in advance cannot reference the student's specific
   mistake (e.g., an off-by-one error, an incorrect loop condition, or a
   missing `WHERE` clause) — it can only restate the general objective,
   which the student has usually already read.

4. **Single-paradigm platforms limit transferable practice.** Many
   beginner tools teach one syntax (e.g., block-based movement commands)
   and do not expose learners to the variety of logical structures
   (sequential commands, declarative querying, ordered/stateful
   procedures) they will encounter across a CS curriculum.

**Core research/engineering question:** *Can a lightweight, gamified,
multi-paradigm coding platform, augmented with an LLM-generated,
code-aware Socratic hint system, measurably improve learner engagement and
problem-solving persistence compared to a static-hint baseline, while
remaining deployable as a lightweight cross-platform client with a minimal
backend footprint?*

---

## 3. Objectives

### General Objective
To design, implement, and evaluate a gamified, cross-platform programming
education application that provides real-time, AI-generated, non-revealing
guidance tailored to a learner's actual code.

### Specific Objectives
1. To design and implement a reusable, testable interpreter architecture
   (lexer → parser → execution-step pipeline) capable of supporting
   multiple distinct programming paradigms within one application.
2. To implement at least three playable learning modules built on that
   architecture: sequential grid-based logic, SQL querying, and an
   ordered/stateful command sequence (rocket launch procedure).
3. To design and implement a gamification layer (XP scoring, a
   leaderboard, module completion tracking, and a hint-unlock flow) that
   incentivizes engagement without undermining the learning objective.
4. To design and implement an LLM-backed Socratic Hint Engine — a
   minimal backend service that sends a student's live code and the level
   objective to an LLM under a constrained "tutor" prompt, and returns a
   short, indirect hint via a structured (schema-validated) response.
5. To evaluate the hint engine's effectiveness and safety (i.e., that it
   does not leak solutions) against a static-hint baseline, using a
   combination of automated schema/behavioral tests and a small user
   study or expert review.

---

## 4. Scope

### In Scope
- A Flutter client application (Android/Windows/Web build targets) with:
  - Three interactive game modules covering three distinct
    "mini-languages" (grid movement, SQL, launch-sequence commands).
  - A simulated authentication/dashboard/leaderboard layer sufficient to
    demonstrate the full gamification loop end-to-end.
  - A per-module timer, XP scoring formula, and completion tracking.
- A minimal serverless backend (a single Firebase Cloud Function) that:
  - Accepts a student's current code, the level objective, and module
    type.
  - Calls a third-party LLM (Claude) with a constrained system prompt
    and a JSON-schema-validated structured output, returning a single
    short hint.
  - Fails safely: if the backend or LLM call is unavailable, the client
    falls back to a static, pre-written hint with no loss of
    functionality.
- Automated unit/widget tests covering the interpreter pipeline, the
  gamification/session logic, and the hint-service client (including its
  failure/fallback paths).

### Out of Scope (for this FYP)
- Real user accounts, persistent server-side storage, or a production
  authentication provider (the current auth/leaderboard layer is
  intentionally simulated/local, as this project's focus is the learning
  and hint-generation mechanics, not account infrastructure).
- The two additional AI modules from the broader long-term product vision
  — **Dynamic Difficulty Adjustment / procedural level generation** and
  an **automated code-quality reviewer** — are explicitly deferred as
  future work beyond this project's timeline, and are noted only to
  frame the hint engine within a larger roadmap.
- Real monetization (rewarded/interstitial ads are simulated placeholders
  to demonstrate the intended UX flow, not integrated with an ad SDK).
- Formal, large-scale classroom deployment; evaluation will be limited to
  a small-scale usability/expert evaluation appropriate to an FYP
  timeline.

---

## 5. Methodology

### 5.1 Development Approach
An **iterative, incremental development methodology** will be used,
consistent with the project's current trajectory: each module (interpreter
core → single game module → gamification shell → AI hint integration) was
and will continue to be built as a vertically-complete, independently
testable increment, with automated tests written alongside each increment
rather than deferred to the end.

### 5.2 System Architecture
- **Client**: Flutter/Dart, chosen for a single codebase across mobile,
  desktop, and web targets. The client follows a layered architecture:
  - `core/interpreter/` — pure-function lexers and parsers per module
    (no UI or timing dependencies), enabling isolated unit testing.
  - `core/state/`, `core/curriculum/`, `core/session/` — immutable state
    models (`copyWith` pattern) and session/leaderboard/XP logic.
  - `presentation/screens/` and `presentation/widgets/` — StatefulWidget
    screens that own timing/async orchestration, composed from
    stateless, purely-rendering widgets.
- **Backend**: a single Node.js/TypeScript Firebase Cloud Function
  (`generateSocraticHint`) — chosen for minimal operational overhead
  (no server to provision or maintain) and to keep the LLM API key out
  of the distributed client. It calls the Claude API using
  schema-constrained structured output to guarantee a well-formed
  response.
- **LLM integration**: a fixed system prompt constrains the model to a
  strict tutoring persona (identify the primary flaw; respond with one
  short, indirect, Socratic-style hint; never reveal the corrected code).

### 5.3 Tools and Technologies
| Layer | Technology |
|---|---|
| Client | Flutter, Dart |
| Backend | Firebase Cloud Functions, Node.js, TypeScript |
| AI | Anthropic Claude API (structured/JSON-schema output) |
| Testing | `flutter_test` (unit + widget tests), mocked HTTP for backend-dependent client code |
| Version control | Git |

### 5.4 Testing and Evaluation Plan
- **Unit testing** of every interpreter (lexer/parser) against
  hand-crafted valid, invalid, and edge-case scripts.
- **Widget testing** of the primary navigation flow (login → dashboard →
  module → win condition).
- **Service-level testing** of the hint client using a mocked HTTP layer
  to verify correct parsing and, critically, correct *fallback* behavior
  when the backend is unreachable or returns malformed data.
- **Qualitative evaluation** of hint quality: a sample set of deliberately
  broken student-style scripts will be run through the deployed hint
  engine, and the resulting hints will be reviewed against a rubric
  (Does it identify the correct flaw? Does it avoid revealing the
  answer? Is it appropriately brief?).
- **(Time permitting) small usability study**: a handful of novice
  programmers attempt the three modules, with informal feedback
  collected on engagement and the perceived usefulness of the AI hints
  versus a static-hint control condition.

---

## 6. Expected Outcome

1. A working, cross-platform prototype application (NgeCode Juh!) with three
   distinct, fully playable programming-education modules and an
   integrated gamification layer (XP, leaderboard, timed challenges).
2. A deployed, functioning LLM-backed Socratic Hint Engine, demonstrably
   safer and more contextually relevant than a static hint bank, with a
   documented, tested graceful-degradation path when the AI backend is
   unavailable.
3. A documented, reusable software architecture (pure-function
   interpreter pipeline; immutable state; stateless render widgets) that
   could be extended with additional modules or paradigms beyond the
   three delivered in this project.
4. An automated test suite demonstrating correctness of the core
   interpreter logic, session/XP logic, and hint-service fallback
   behavior.
5. A written evaluation of the hint engine's quality and safety
   characteristics, and a documented roadmap identifying the two deferred
   AI features (dynamic difficulty adjustment and automated code-quality
   review) as candidate directions for future work.
6. A final report and (if required by the program) a live demonstration
   suitable for FYP examination, covering problem motivation, design
   decisions, implementation, and evaluation results.
