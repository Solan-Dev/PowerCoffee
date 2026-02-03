# PowerCoffee Agile Plan: Guided Tasting Notes Experience

## Purpose
Define an epic and backlog that guides users through taking coffee tasting notes in the canvas app. This document is for review before any build changes.

## Theming reference
- See [docs/THEMING.md](docs/THEMING.md) for the #ff6f00 accessibility-first theme.

## Agile approach
- **Cadence:** Short iterations, each ending with a working slice in the app.
- **Definition of Done:** User can complete the story path in the app, data saved to Dataverse, and theme (#ff6f00) applied to new UI.
- **Artifacts:** Epics → Features → User stories → Tasks. Prioritized order below.

## New Epic 6: Guided tasting journey
**Goal:** Help users capture memorable, structured tasting notes with playful, creative prompts.

### Feature 6.1: Guided tasting flow
**User story:** As a taster, I want a step-by-step flow so I can capture aroma, flavor, and finish without forgetting details.
- Task: Add a guided flow screen sequence (Aroma → Flavor → Finish → Overall)
- Task: Save intermediate inputs to variables and commit on final step

**User story:** As a taster, I want a quick-start mode so I can log a note in under 60 seconds.
- Task: Add “Quick Note” entry with minimal fields

### Feature 6.2: Sensory prompts
**User story (unusual):** As a taster, I want a “memory hook” prompt (song, place, color) so the note feels more vivid later.
- Task: Add optional prompt cards (Song, Place, Color)

**User story (unusual):** As a taster, I want a “mood compass” (Calm/Energized/Focused/Cozy) so I can track how the coffee made me feel.
- Task: Add mood picker to the guided flow

**User story:** As a taster, I want curated flavor wheels so I can choose common notes quickly.
- Task: Add multi-select chips for common descriptors

### Feature 6.3: Discovery and reflection
**User story:** As a taster, I want a “compare last 3” view so I can see what changed between brews.
- Task: Add a comparison gallery

**User story (unusual):** As a taster, I want a “surprise me” prompt so I can discover a new descriptor when I’m stuck.
- Task: Add random suggestion button

### Feature 6.4: Quality and consistency
**User story:** As a taster, I want defaults (brew method, roast level) so I can log faster.
- Task: Use defaults for current user

## Proposed order (for oversight)
1) **Guided tasting flow skeleton** (Feature 6.1) — screens + navigation + save
2) **Quick-start mode** (Feature 6.1) — minimal form
3) **Sensory prompts** (Feature 6.2) — memory hook + mood compass
4) **Flavor wheels** (Feature 6.2) — descriptor chips
5) **Compare last 3** (Feature 6.3)
6) **Surprise me prompt** (Feature 6.3)
7) **Defaults & polish** (Feature 6.4)

## Notes
- This plan focuses on the canvas app only.
- No changes are made until you approve this order.
