# CLI Flag Verification Matrix

This file records which preset-related flags are supported by the current
companion CLI. Run the help commands below after every companion CLI bump
and update the matrix before promoting any flag into an executable example.

## CLI Version Tested

```bash
npx -y agnes-ai-cli@^0.1.0 --version
```

Captured during preset verification on 2026-06-23: **0.1.0**

## Help Commands

```bash
npx -y agnes-ai-cli@^0.1.0 --help
npx -y agnes-ai-cli@^0.1.0 image text2img --help
npx -y agnes-ai-cli@^0.1.0 image img2img --help
npx -y agnes-ai-cli@^0.1.0 image compose --help
npx -y agnes-ai-cli@^0.1.0 video text2video --help
npx -y agnes-ai-cli@^0.1.0 video img2video --help
npx -y agnes-ai-cli@^0.1.0 video multivideo --help
npx -y agnes-ai-cli@^0.1.0 video keyframes --help
npx -y agnes-ai-cli@^0.1.0 video poll --help
```

## Status Vocabulary

- `verified` — confirmed by CLI help output, CLI source, or smoke test.
- `unsupported` — confirmed by CLI help output that the flag does not exist.
- `not_applicable` — the flag is meaningless for this subcommand.
- `pending` — not yet verified; do not promote into executable examples.

## Matrix (verified on 2026-06-23 against CLI 0.1.0)

| Flag | image text2img | image img2img | image compose | video text2video | video img2video | video multivideo | video keyframes | Status |
|---|---|---|---|---|---|---|---|---|
| `--prompt` | verified | verified | verified | verified | verified | verified | verified | verified |
| `--model` | verified | verified | verified | not_applicable | not_applicable | not_applicable | not_applicable | verified |
| `--size` | verified | verified | verified | N/A | N/A | N/A | N/A | verified |
| `--width` | N/A | N/A | N/A | verified | verified | verified | verified | verified |
| `--height` | N/A | N/A | N/A | verified | verified | verified | verified | verified |
| `--num-frames` | N/A | N/A | N/A | verified | verified | verified | verified | verified |
| `--frame-rate` | N/A | N/A | N/A | verified | verified | verified | verified | verified |
| `--seed` | verified | verified | verified | verified | verified | verified | verified | verified |
| `--negative-prompt` | N/A | N/A | N/A | verified | verified | verified | verified | verified |
| `--image` | N/A | verified | verified (repeatable) | N/A | verified | verified (repeatable) | verified (repeatable) | verified |
| `--ttl` | N/A | verified | verified | N/A | verified | verified | verified | verified |
| `--json` | verified | verified | verified | verified | verified | verified | verified | verified |
| `--interval` | N/A | N/A | N/A | N/A | N/A | N/A | N/A | poll-only (verified) |
| `--timeout` | N/A | N/A | N/A | N/A | N/A | N/A | N/A | poll-only (verified) |

`video poll` exposes `--interval`, `--timeout`, and `--json` and is the
recommended asynchronous completion path. It is intentionally separated from
the generation commands above.

## What Is Safe To Use

- All `--prompt` and `--json` flags are safe across the documented
  subcommands.
- `--model`, `--size`, `--seed` are safe on the image commands.
- `--width`, `--height`, `--num-frames`, `--frame-rate`, `--seed`,
  `--negative-prompt` are safe on the video generation commands.
- `--image` is safe on every image and video command that takes an input.
- `--ttl` controls the temporary public URL TTL for bridged local media and
  defaults to `1h`.

## What Still Requires Care

- Specific values like `--width 1152` or `--num-frames 121` are still
  hints. The CLI will accept them, but the model side may impose its own
  constraints. Always keep the video validation rules in `SKILL.md`
  (`8n + 1`, `num_frames <= 441`, `frame_rate 1-60`) and treat dimensions
  as presets rather than hard rules.
- `response_format` is intentionally not exposed by the CLI as a flat flag.
  Agents should follow the warning in `SKILL.md` and not pass
  `response_format` directly.

## Live Smoke Test Levels

Live tests are graded so the no-live tier always runs.

### no-live (always safe)

```bash
markdownlint README.md README.zh-CN.md SKILL.md docs/*.md examples/*.md
bash tests/verify_presets.sh
```

### auth-only

```bash
npx -y agnes-ai-cli@^0.1.0 auth check
```

### image-live (run only when an API key is configured)

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img \
  --prompt "A simple clean product photo of a white ceramic cup on a wooden table." \
  --size 1024x768 \
  --json
```

### video-live (run only when quota and time allow)

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "A calm cinematic shot of ocean waves at sunset, slow camera push." \
  --width 1152 \
  --height 768 \
  --num-frames 121 \
  --frame-rate 24 \
  --json
```

If a `videoId` is returned:

```bash
npx -y agnes-ai-cli@^0.1.0 video poll "$VIDEO_ID" --json
```

## Verification Procedure

1. Run the no-live tier.
2. Run auth-only if `AGNES_API_KEY` is set.
3. Decide whether to run image-live and video-live based on quota and
   time.
4. Re-run the help commands above and confirm that no flag moved from
   `verified` to `unsupported`.
5. If a flag becomes `unsupported`, downgrade its row in this file and
   remove the flag from any executable example in `SKILL.md` or
   `examples/*.md`.