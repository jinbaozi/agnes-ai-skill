# Preset Design

## Goal

Add minimal preset-based generation guidance to `agnes-ai-skill` so coding
agents can pick the smallest reliable preset instead of improvising a CLI
invocation.

## Runtime Source of Truth

`SKILL.md` is the runtime source of truth. YAML config files, if added later,
are maintainability helpers only. Agents reading this skill should not depend
on the YAML files being available.

## Preset Scope

Image presets:

- `image.quick`
- `image.landscape`
- `image.portrait`
- `image.product`
- `image.edit_or_compose`

Video presets:

- `video.quick_preview`
- `video.standard`
- `video.social`
- `video.cinematic`
- `video.image_to_video`
- `video.keyframes`

The first version of this skill ships exactly 11 presets. Adding more
presets must be deliberate: every preset must map cleanly to a documented
use case, a model family, a CLI mode, and a prompt recipe.

## Selection Order

1. Explicit preset id from the user wins.
2. Image inputs bias toward `image.edit_or_compose` or `video.image_to_video`.
3. Use case keywords bias toward the matching preset
   (see `SKILL.md` -> `Preset Selection Rules`).
4. Otherwise default to the smallest preset that satisfies the request
   (`image.quick` or `video.quick_preview`).

## Verification Policy

No CLI flag should be documented as executable until confirmed by CLI help,
CLI source, or live smoke test. The verification matrix lives in
`docs/cli-flag-verification.md`.

## Response Format Policy

`response_format` is not a generic top-level field. Only pass response format
options when the current official docs and CLI path confirm the correct
location and mode. Image 2.1 and Image 2.0 historically expose
`extra_body.response_format` rather than a flat `response_format` argument.

## Local Media Privacy Policy

Local media may be uploaded to temporary public URLs by the companion CLI.
Agents must warn the user before processing confidential, proprietary,
customer-owned, regulated, or personal local media files. The full warning
text lives in `SKILL.md` -> `Local Media Privacy Warning`.

## Rollback Strategy

If a preset is reported as unsafe, follow the plan in section 10 of
`.plan/agnes_ai_skill_preset_execution_plan.md`:

1. Keep the docs and examples for traceability.
2. Roll back the preset rules inside `SKILL.md`.
3. Keep the privacy warning because it is a safety enhancement.
4. Publish a patch release note explaining the rollback.