# Version Policy

This document records the version strategy for the `agnes-ai-skill`
repository and explains why the internal `SKILL.md` version can move ahead of
the latest GitHub release.

## Current State

- Internal `SKILL.md` version: `1.2.2`
- Latest GitHub release: may lag behind the internal version because the
  release is published only after the acceptance checklist in
  `.plan/agnes_ai_skill_preset_execution_plan.md` section 9 is fully
  satisfied.

## Versioning Rules

1. Patch versions (e.g. `1.2.x`) cover documentation-only changes that do not
   alter the agent-facing contract documented in `SKILL.md`.
2. Minor versions (e.g. `1.3.0`) cover new agent guidance, new presets, or
   new CLI workflows that change the recommended execution pattern.
3. Major versions (e.g. `2.0.0`) are reserved for breaking changes to the
   `SKILL.md` frontmatter contract or to the CLI-first execution contract.
4. The internal `SKILL.md` frontmatter `version` is bumped in the same
   commit that introduces the change. The release tag follows later.
5. Every release must:
   - update the `SKILL.md` `Version History` section
   - keep the GitHub release notes in sync with the new behavior
   - satisfy the acceptance checklist in section 9 of the execution plan

## Pending Release: `v1.3.0`

The planned `v1.3.0` introduces the minimal preset-based generation guidance.
It will be published only after:

- `SKILL.md` inlines the minimal preset strategy, image presets, video
  presets, selection rules, privacy warnings, response format rules, and
  video validation rules
- `README.md` and `README.zh-CN.md` document the preset surface
- `docs/cli-flag-verification.md` records the actual CLI help output
- no unverified CLI flag appears in any executable example
- the no-live verification script `tests/verify_presets.sh` exits 0

If any preset is discovered to be unsafe after release, follow the rollback
strategy in section 10 of the execution plan and publish a patch release.

## Companion CLI Versioning

The supported companion CLI range for this skill release series is
`>=0.1.0 <0.2.0`. Any CLI breaking change requires a new minor version of
`agnes-ai-skill` so the supported range can be updated together.