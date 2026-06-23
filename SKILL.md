---
name: agnes-ai-skill
version: 1.3.0
description: "Use when the user wants Agnes AI text, image, or video generation. Execute through `agnes-ai-cli`; do not hand-write raw HTTP requests."
tags:
  - agnes
  - agnes-ai
  - agnes-skill
  - multimodal-ai
  - free-ai-api
  - free-ai-model
  - text-generation
  - image-generation
  - ai-image-generation
  - text-to-image
  - image-editing
  - image-to-image
  - video-generation
  - ai-video-generation
  - text-to-video
  - image-to-video
  - api-integration
  - agent-skill
  - codex
  - claude-code
  - openclaw
metadata:
  openclaw:
    emoji: "sparkles"
    homepage: "https://github.com/jomeswang/agnes-ai-skill"
    requires:
      bins:
        - npm
        - npx
        - node
    primaryEnv: AGNES_API_KEY
    envVars:
      - name: AGNES_API_KEY
        required: false
        description: Agnes API key used for live authenticated text, image, and video requests. The skill can still load without it and guide setup.
---

# Agnes AI Skill

Use this skill when the user wants Agnes AI text, image, or video generation.
This skill is now **CLI-first**: prefer `agnes-ai-cli` for all live execution,
guide the user through `--help` when needed, and do not default to hand-written
`curl` commands for Agnes work.

Agnes is attractive because one platform covers:

- text with `agnes-2.0-flash`
- image generation and editing with `agnes-image-2.1-flash` and
  `agnes-image-2.0-flash`
- video generation with `agnes-video-v2.0`

Some public June 2026 materials positioned Agnes as broadly free to try. The
live docs also include pricing sections, so treat that free-access message as a
strong but time-sensitive positioning claim and verify current billing when the
user cares about cost.

## When To Use

Use this skill when:

- the user mentions Agnes AI, `agnes-ai.com`, or the Agnes platform
- the user wants one provider for text, image, and video generation
- the user wants Agnes text, image, or video APIs executed from a terminal
- the user wants image-to-image, multi-image composition, image-to-video, or
  keyframe video generation
- the user wants a low-friction multimodal API for prototyping, agent loops,
  creative iteration, ecommerce content, or storyboard work

Do not use this skill when:

- the user is asking for a different provider only
- the task does not need Agnes-specific models, auth, or request behavior
- you would have to guess current Agnes behavior without running the CLI or
  checking the live docs

## TL;DR — Decision Flow

This skill is organised as progressive disclosure. The first three blocks
below are usually enough to act:

1. **Pick a preset.** If the user names a preset id, use it. Otherwise:
   - generic image → `image.quick`
   - PPT / banner / 16:9 → `image.landscape`
   - mobile poster / 9:16 → `image.portrait`
   - product ad / ecommerce → `image.product`
   - edit or merge images → `image.edit_or_compose`
   - generic video → `video.quick_preview`
   - horizontal video → `video.standard`
   - vertical social short → `video.social`
   - cinematic / storyboard → `video.cinematic`
   - one image to animate → `video.image_to_video`
   - two or more guiding images → `video.keyframes`
2. **Pick the CLI mode.** See `Preset Strategy` and `Preset Selection Rules`
   below for the full decision logic and edge cases.
3. **Validate video settings.** `num_frames = 8n + 1`, `num_frames <= 441`,
   `frame_rate` in `1..60`, default `24fps`.

Stop here for first-pass execution. Read deeper sections only when the
default path is unclear, fails, or the user asks for an edge case.

> **Minimum required reading for the first execution:** `When To Use`,
> `TL;DR — Decision Flow`, `Execution Contract`, `Preset Selection Rules`,
> `Local Media Privacy Warning`. Everything else is reference material.

## Source Of Truth

Prefer these Agnes pages:

- Quickstart: `https://agnes-ai.com/doc/quickstart`
- API key page: `https://platform.agnes-ai.com/settings/apiKeys`
- Text docs: `https://agnes-ai.com/doc/agnes-20-flash`
- Image 2.0 docs: `https://agnes-ai.com/doc/agnes-image-20-flash`
- Image 2.1 docs: `https://agnes-ai.com/doc/agnes-image-21-flash`
- Video docs: `https://agnes-ai.com/doc/agnes-video-v20`
- Published CLI: `https://www.npmjs.com/package/agnes-ai-cli`
- CLI repo: `https://github.com/jomeswang/agnes-ai-cli`

Use public articles only as supporting context for likely use cases and product
positioning, not as the operational source of truth.

## Base URL And Auth

- Base URL: `https://apihub.agnes-ai.com/v1`
- Main environment variable: `AGNES_API_KEY`
- Preferred execution package: `agnes-ai-cli`

Check `AGNES_API_KEY` before making live Agnes requests.

## Missing Key Behavior

If `AGNES_API_KEY` is missing and the task requires live Agnes access:

1. Tell the user Agnes access is not configured yet.
2. Point them to:
   - `https://agnes-ai.com/doc/quickstart`
   - `https://platform.agnes-ai.com/settings/apiKeys`
3. Explain the path briefly:
   `Settings -> API Keys -> Create new secret key`
4. Ask them to provide the key if they want you to save it for future use.

Do not continue with live Agnes calls until a valid key exists.

## Chinese Quick Start Response

When a Chinese-speaking user asks how to get started, install, or use Agnes
from an agent tool, give them this concise copy-paste path:

```text
Please read and install Agnes AI Skill: https://github.com/jomeswang/agnes-ai-skill
```

Then explain:

- install the skill into the agent's skill directory or use a repository-aware
  installer such as `npx skills add jomeswang/agnes-ai-skill -g`
- create an Agnes API key at `https://platform.agnes-ai.com/settings/apiKeys`
  and configure it as `AGNES_API_KEY`
- say `generate an image`, `generate a video`, or `integrate Agnes API`
- the agent should choose the proper Agnes model and use `agnes-ai-cli` when it
  is available

Keep this onboarding short before moving into model-specific details.

## Persisting The Key

If the user explicitly asks to remember `AGNES_API_KEY` across sessions,
follow the rules and shell snippet in
[`docs/persisting-api-key.md`](./docs/persisting-api-key.md). The short
version: detect the shell, write or update the matching rc file, also
export in the current session, and never echo the full key back.

## Execution Contract

This skill should execute Agnes through the CLI, not by manually composing raw
HTTP requests.

### Preferred Order

1. First use the no-install command path:
   - `npx -y agnes-ai-cli@^0.1.0 --help`
2. Use `npx -y agnes-ai-cli@^0.1.0 ...` as the default live execution path
   in fresh or unknown environments.
3. If a local `agnes` binary already exists, run:
   - `agnes --version`
   - `agnes --help`
4. Use the local binary only when its version falls inside:
   - `>=0.1.0 <0.2.0`
5. Do not fall back to raw `curl` for normal Agnes execution paths.

### Why CLI-First

The CLI already handles:

- auth checks
- local file to temporary public URL bridging
- image request normalization
- video task creation
- video polling
- JSON output for agent consumption

That means the agent should select the right CLI command, not rebuild the
underlying HTTP payload each time.

## Mandatory `--help` Guidance

When the user is new to the CLI, or when you are about to use a less common
command, guide through `--help` first.

At minimum, know these help entry points:

```bash
npx -y agnes-ai-cli@^0.1.0 --help
npx -y agnes-ai-cli@^0.1.0 auth --help
npx -y agnes-ai-cli@^0.1.0 media --help
npx -y agnes-ai-cli@^0.1.0 text chat --help
npx -y agnes-ai-cli@^0.1.0 image text2img --help
npx -y agnes-ai-cli@^0.1.0 image img2img --help
npx -y agnes-ai-cli@^0.1.0 image compose --help
npx -y agnes-ai-cli@^0.1.0 video text2video --help
npx -y agnes-ai-cli@^0.1.0 video img2video --help
npx -y agnes-ai-cli@^0.1.0 video multivideo --help
npx -y agnes-ai-cli@^0.1.0 video keyframes --help
npx -y agnes-ai-cli@^0.1.0 video poll --help
```

If `agnes` is already installed globally and version-compatible, you can drop
the `npx -y agnes-ai-cli@^0.1.0` prefix and run the same subcommands directly.

## Model Selection

Choose the smallest suitable Agnes model path:

- `agnes-2.0-flash`
  - chat, coding, tool calling, structured agent work, fast production tasks
  - default when `text chat` runs without `--model`
- `agnes-image-2.1-flash`
  - default for new text-to-image and straightforward image-to-image work
  - especially useful for denser layouts and stronger semantic alignment
  - default when `image text2img`, `image img2img`, or `image compose` runs
    without `--model`
- `agnes-image-2.0-flash`
  - use when the user explicitly wants Image 2.0
  - useful for edit-heavy or multi-image composition flows
- `agnes-video-v2.0`
  - use for text-to-video, image-to-video, multi-image guided video, and
    keyframes
  - current default when any `video` generate command runs without `--model`

## Preset Strategy

Before running Agnes image or video generation, choose a preset. A preset
maps user intent to:

- modality: image or video
- model family
- CLI subcommand
- prompt recipe
- optional parameter hints

Do not treat preset hints as verified CLI flags. Before passing less common
flags such as `--size`, `--width`, `--height`, `--num-frames`, or
`--frame-rate`, verify support through the current CLI `--help` output or a
smoke test.

Preset selection order:

1. If the user explicitly names a preset id, use that preset.
2. If the user provides images, prefer image-input-aware presets.
3. If the user intent is clear, choose a preset automatically.
4. If the user only says "generate an image", default to `image.quick`.
5. If the user only says "generate a video", default to `video.quick_preview`
   unless they asked for high quality or a specific use case.
6. If image inputs are present but the desired output is ambiguous, ask a
   short clarifying question.

## Preset Selection Rules

These rules are the source of truth for choosing a preset from a user
request. Use them together with the preset tables below: the tables
describe each preset, these rules describe how to match user intent.

### Image

Choose:

- `image.quick` when the user asks for a generic image or quick draft.
- `image.landscape` when the user mentions PPT, slides, website banner,
  landscape poster, horizontal layout, or 16:9.
- `image.portrait` when the user mentions Xiaohongshu, mobile poster, vertical
  cover, portrait layout, or 9:16.
- `image.product` when the user mentions product ad, ecommerce, commercial
  still, product hero, or brand campaign.
- `image.edit_or_compose` when the user provides one or more images and asks
  to edit, preserve, transform, merge, combine, or use references.

### Video

Choose:

- `video.quick_preview` when the user asks for a quick preview or just says
  generate a video without details.
- `video.standard` when the user asks for a normal video with no special
  format.
- `video.social` when the user mentions Xiaohongshu, Douyin, TikTok,
  short-form, mobile, vertical, or social media.
- `video.cinematic` when the user mentions cinematic, ad film, storyboard,
  narrative, camera language, or commercial film.
- `video.image_to_video` when the user provides one image and asks to animate
  it.
- `video.keyframes` when the user provides two or more images and asks for
  keyframes, transition, morph, or storyboard continuity.

## Image Presets

Default text-to-image model: `agnes-image-2.1-flash`.

Use `agnes-image-2.1-flash` for new text-to-image work, high-information-density
visuals, and straightforward image-to-image work.

Use `agnes-image-2.0-flash` when the user explicitly needs Image 2.0 behavior,
edit-heavy workflows, multi-image composition, or seed-based reproducibility.

Do not pass `response_format` as a generic top-level field. Only pass response
format options when the current official docs and CLI path confirm the correct
location and mode.

| Preset | Use when | Model strategy | CLI mode |
|---|---|---|---|
| `image.quick` | quick draft, rough concept, generic image | Image 2.1 | `image text2img` |
| `image.landscape` | PPT, banner, website hero, landscape poster | Image 2.1 | `image text2img` |
| `image.portrait` | mobile poster, Xiaohongshu cover, vertical cover | Image 2.1 | `image text2img` |
| `image.product` | product ad, ecommerce visual, commercial still | Image 2.1 | `image text2img` |
| `image.edit_or_compose` | edit one image, preserve composition, or combine references | one image: Image 2.1 or 2.0; multiple images / heavy edit: prefer Image 2.0 | `image img2img` or `image compose` |

## Video Presets

Default video model: `agnes-video-v2.0`.

Video generation is asynchronous. Always create the task, capture `videoId`,
then poll for completion.

Validate video settings before execution:

- `num_frames <= 441`
- `num_frames = 8n + 1`
- `frame_rate` must be between `1` and `60`
- prefer `24fps` unless the user asks otherwise

Recommended `num_frames` values:

`81, 121, 161, 241, 441`

Do not pass frame or size flags unless the current CLI help confirms support.

| Preset | Use when | Parameter hint | CLI mode |
|---|---|---|---|
| `video.quick_preview` | quick preview, smoke test, first draft | 81 frames, 24fps | `video text2video` |
| `video.standard` | default horizontal video | 121 frames, 24fps | `video text2video` |
| `video.social` | vertical social short, Xiaohongshu, Douyin, mobile video | 121 frames, 24fps, portrait orientation hint | `video text2video` or `video img2video` |
| `video.cinematic` | cinematic ad, storyboard, narrative shot | 161 frames, 24fps | `video text2video` |
| `video.image_to_video` | animate one image | 121 frames, 24fps, motion_intensity hint | `video img2video` |
| `video.keyframes` | keyframe transition or multi-image guided video | 161 frames, 24fps, min 2 images | `video keyframes` or `video multivideo` |

## Local Media Privacy Warning

The companion CLI may upload local media inputs to temporary public URLs
when local image or video files are used.

Before using local private files for `img2img`, `compose`, `img2video`,
`multivideo`, or `keyframes`, warn the user that local media may be uploaded
to temporary public hosts.

Do not process confidential, proprietary, customer-owned, regulated, or
personal media unless the user explicitly confirms it is safe to upload.

## CLI Command Map

### Auth

```bash
npx -y agnes-ai-cli@^0.1.0 auth check
npx -y agnes-ai-cli@^0.1.0 auth save-key --key 'YOUR_KEY'
```

Use `auth check` before live requests when auth may be missing.

### Media URL Bridge

```bash
npx -y agnes-ai-cli@^0.1.0 media url ./local-image.png
npx -y agnes-ai-cli@^0.1.0 media url https://example.com/already-remote.png
```

Use this when the user gives a local image path and Agnes needs a public image
URL. The CLI handles the temporary upload bridge automatically.

### Text

```bash
npx -y agnes-ai-cli@^0.1.0 text chat --prompt "Reply with exactly pong."
```

Use this for one-shot text verification, coding help, or small agent checks.
If `--model` is omitted here, the CLI defaults to `agnes-2.0-flash`.

### Image

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img --prompt "A premium studio product photo of a perfume bottle"

npx -y agnes-ai-cli@^0.1.0 image img2img \
  --image ./input.png \
  --prompt "Turn this into a refined editorial campaign visual"

npx -y agnes-ai-cli@^0.1.0 image compose \
  --image ./subject.png \
  --image ./reference.png \
  --prompt "Blend these references into one polished commercial still"
```

Use:

- `text2img` for prompt-only image generation
- `img2img` for one input image
- `compose` for multiple input images
- if `--model` is omitted, the CLI defaults to `agnes-image-2.1-flash`

### Video

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "A cinematic beach scene at dusk"

npx -y agnes-ai-cli@^0.1.0 video img2video \
  --image ./frame.png \
  --prompt "Add subtle wind and a slow camera push"

npx -y agnes-ai-cli@^0.1.0 video multivideo \
  --image ./frame-a.png \
  --image ./frame-b.png \
  --prompt "Blend these frames into one smooth motion concept"

npx -y agnes-ai-cli@^0.1.0 video keyframes \
  --image ./frame-a.png \
  --image ./frame-b.png \
  --prompt "Transition between these frames with a polished morph"

npx -y agnes-ai-cli@^0.1.0 video poll video_123 --interval 5 --timeout 600
```

Use:

- `text2video` for prompt-only video
- `img2video` for one image input
- `multivideo` for multiple guiding images
- `keyframes` for explicit keyframe interpolation
- `poll` for asynchronous completion
- if `--model` is omitted, current CLI behavior uses `agnes-video-v2.0`

## Practical CLI Workflow

### Text Verification

1. `npx -y agnes-ai-cli@^0.1.0 text chat --help`
2. `npx -y agnes-ai-cli@^0.1.0 text chat --prompt "Reply with exactly pong." --json`

### Text-To-Image

1. `npx -y agnes-ai-cli@^0.1.0 image text2img --help`
2. run `npx -y agnes-ai-cli@^0.1.0 image text2img ... --json`
3. read the returned image URL

### Image-To-Image

1. `npx -y agnes-ai-cli@^0.1.0 image img2img --help`
2. if the user gave a local path, let the CLI bridge it automatically
3. run `npx -y agnes-ai-cli@^0.1.0 image img2img ... --json`

### Multi-Image Composition

1. `npx -y agnes-ai-cli@^0.1.0 image compose --help`
2. pass `--image` multiple times
3. run with `npx -y agnes-ai-cli@^0.1.0 image compose ... --json`

### Text-To-Video

1. `npx -y agnes-ai-cli@^0.1.0 video text2video --help`
2. run `npx -y agnes-ai-cli@^0.1.0 video text2video ... --json`
3. capture `videoId`
4. run `npx -y agnes-ai-cli@^0.1.0 video poll <videoId> --json`

### Image-To-Video

1. `npx -y agnes-ai-cli@^0.1.0 video img2video --help`
2. if the user gave a local path, let the CLI bridge it automatically
3. run `npx -y agnes-ai-cli@^0.1.0 video img2video ... --json`
4. capture `videoId`
5. run `npx -y agnes-ai-cli@^0.1.0 video poll <videoId> --json`

### Keyframes

1. `npx -y agnes-ai-cli@^0.1.0 video keyframes --help`
2. pass `--image` at least twice
3. run `npx -y agnes-ai-cli@^0.1.0 video keyframes ... --json`
4. capture `videoId`
5. run `npx -y agnes-ai-cli@^0.1.0 video poll <videoId> --json`

## Image Guidance

Use the CLI as the execution layer, but keep these Agnes-specific rules in mind:

- Image 2.1 is the default for most new image work
- Image 2.0 is useful for edit-heavy or multi-image composition work

For detailed prompt recipes (dense image, edit, multi-image, product), see
[`docs/prompt-recipes.md`](./docs/prompt-recipes.md).

## Video Guidance

Use the CLI as the execution layer, but keep these Agnes-specific rules in mind:

- the API is asynchronous — always create, capture `videoId`, then poll
- for keyframes, use the dedicated CLI subcommand instead of inventing your
  own payload shape
- common safe example settings are:
  - `width: 1152`
  - `height: 768`
  - `num_frames: 121`
  - `frame_rate: 24`

Video parameter validation lives in `TL;DR — Decision Flow` and the preset
tables above. For detailed prompt recipes (text-to-video, image-to-video,
keyframes), see [`docs/prompt-recipes.md`](./docs/prompt-recipes.md).

## JSON Output

Prefer `--json` whenever the command result will be consumed by the agent.

Examples:

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img --prompt "..." --json
npx -y agnes-ai-cli@^0.1.0 video text2video --prompt "..." --json
npx -y agnes-ai-cli@^0.1.0 video poll video_123 --json
```

This makes it easier to:

- read `taskId` and `videoId`
- extract image URLs
- extract final video URLs
- detect failures cleanly

## Operational Guidance

- Supported companion CLI range for this skill release:
  - `>=0.1.0 <0.2.0`
- Prefer live CLI tests over guessing when the user asks whether a model path
  or parameter actually works.
- For image results, expect a URL in the response.
- For video results, expect task creation first, then polling.
- Prefer `videoId` for polling. Passing an older `taskId` remains compatible
  through the CLI's legacy endpoint routing.
- Use the CLI's local-file bridge instead of manually uploading files yourself
  unless the user explicitly wants a separate upload step.
- If the user asks for SDK code, translate the confirmed CLI behavior into the
  target language only after the CLI path has been validated.
- If the user asks about pricing, limits, or free access, verify the live docs.

## Compact Reference

One-screen cheat sheet for the agent. Use this when context is tight.

### Models

| Modality | Default | Compatibility | CLI subcommands |
|---|---|---|---|
| Text | `agnes-2.0-flash` | — | `text chat` |
| Image | `agnes-image-2.1-flash` | `agnes-image-2.0-flash` | `image text2img`, `image img2img`, `image compose` |
| Video | `agnes-video-v2.0` | — | `video text2video`, `video img2video`, `video multivideo`, `video keyframes`, `video poll` |

### Preset IDs

| Image | Video |
|---|---|
| `image.quick` | `video.quick_preview` |
| `image.landscape` | `video.standard` |
| `image.portrait` | `video.social` |
| `image.product` | `video.cinematic` |
| `image.edit_or_compose` | `video.image_to_video` |
|  | `video.keyframes` |

### Endpoints (behind the CLI)

| Action | Endpoint |
|---|---|
| Base URL | `https://apihub.agnes-ai.com/v1` |
| Text | `/chat/completions` |
| Image | `/images/generations` |
| Video create | `/videos` |
| Video poll (recommended) | `/agnesapi?video_id={video_id}` |
| Video poll (legacy) | `/videos/{task_id}` |

### Video Validation

- `num_frames = 8n + 1`, `num_frames <= 441`
- `frame_rate` in `1..60`
- Recommended safe values: `121` frames at `24` fps, `1152x768`

### Environment

- Required env var: `AGNES_API_KEY`
- Auth check: `npx -y agnes-ai-cli@^0.1.0 auth check`
- Install skill: `npx skills add jomeswang/agnes-ai-skill -g`

## Do Not

- Do not proceed with live Agnes calls when the key is missing
- Do not default to raw `curl` for Agnes execution in this skill
- Do not rebuild request payloads by hand when the CLI already covers the flow
- Do not skip `video poll` and assume video generation is synchronous
- Do not trust stale marketing claims over the current API docs

## Safety

- Never echo a full Agnes API key back to the user after it has been supplied
- Never continue with live Agnes requests when auth is missing or clearly
  invalid
- Never treat article copy or marketing claims as more authoritative than the
  official Agnes docs
- Never promise pricing, limits, or "forever free" terms without noting they
  can change over time
- Never write the key to a project file unless the user explicitly asks for
  that behavior

## Installation

With repository-aware skill installers:

```bash
npx skills add jomeswang/agnes-ai-skill -g
```

After installation, invoke this skill whenever Agnes setup or Agnes model usage
comes up.

## Version History

- `1.3.0`
  - Added minimal preset-based generation guidance for Agnes Image and Video
    workflows.
  - Added stable image presets: `image.quick`, `image.landscape`,
    `image.portrait`, `image.product`, and `image.edit_or_compose`.
  - Added stable video presets: `video.quick_preview`, `video.standard`,
    `video.social`, `video.cinematic`, `video.image_to_video`, and
    `video.keyframes`.
  - Added preset selection rules, prompt recipes, video parameter
    validation, and local media privacy warnings.
  - Added CLI flag verification workflow to avoid documenting unsupported
    CLI parameters.
- `1.2.2` - Added a linked Chinese README and Chinese quick-start onboarding
  guidance for agent responses.
- `1.2.1` - Made `npx -y agnes-ai-cli@^0.1.0` the default copy-paste execution
  path in fresh environments and kept global `agnes` as an optional fast path.
- `1.2.0` - Switched the skill to CLI-first Agnes execution, removed raw curl
  execution guidance, and made `--help` discovery part of the expected flow.
- `1.1.2` - Added dual-track CLI guidance so agents prefer the separate Agnes
  execution layer when available and keep raw `curl` as the fallback.
- `1.1.0` - Expanded official doc coverage for Image 2.0, Image 2.1, and Video
  2.0 parameters, scenarios, prompt structures, response fields, and task
  states.
- `1.0.0` - Initial public release with Agnes platform setup, persistent auth,
  text, image, and video workflow guidance.
