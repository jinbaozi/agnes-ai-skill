# Video Preset Examples

This file shows what an agent should do for each video preset. Every example
keeps the executable command minimal until the CLI flag verification matrix
in `docs/cli-flag-verification.md` confirms that the optional flags actually
exist.

## video.quick_preview

User:

```text
用 Agnes 生成一个海边黄昏的快速预览视频。
```

Agent selects:

```yaml
preset: video.quick_preview
model: agnes-video-v2.0
mode: video text2video
parameter_hint:
  num_frames: 81
  frame_rate: 24
```

Prompt recipe:

```text
A calm cinematic beach scene at dusk, gentle waves, soft golden light, slow
camera push, peaceful atmosphere.
```

CLI before optional flag verification:

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "A calm cinematic beach scene at dusk, gentle waves, soft golden light, slow camera push, peaceful atmosphere." \
  --json
```

After task creation, capture `videoId` and poll:

```bash
npx -y agnes-ai-cli@^0.1.0 video poll "$VIDEO_ID" --json
```

Note:

Do not add `--num-frames` or `--frame-rate` until the current CLI help
confirms support.

## video.standard

User:

```text
生成一个标准横版视频。
```

Agent selects:

```yaml
preset: video.standard
model: agnes-video-v2.0
mode: video text2video
parameter_hint:
  num_frames: 121
  frame_rate: 24
```

Prompt recipe:

```text
A serene mountain valley at sunrise, low fog, slow aerial dolly, ambient
natural sound implied by the visuals, soft cinematic grading.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "A serene mountain valley at sunrise, low fog, slow aerial dolly, ambient natural sound implied by the visuals, soft cinematic grading." \
  --json
```

## video.social

User:

```text
帮我做一个抖音竖版短视频。
```

Agent selects:

```yaml
preset: video.social
model: agnes-video-v2.0
mode: video text2video
orientation_hint: portrait
parameter_hint:
  num_frames: 121
  frame_rate: 24
```

Prompt recipe:

```text
Vertical 9:16 social short, vibrant street food close-up, bold title
overlay, upbeat tempo, mobile-first framing, attention-grabbing first
frame.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "Vertical 9:16 social short, vibrant street food close-up, bold title overlay, upbeat tempo, mobile-first framing, attention-grabbing first frame." \
  --json
```

## video.cinematic

User:

```text
生成一个电影感广告片。
```

Agent selects:

```yaml
preset: video.cinematic
model: agnes-video-v2.0
mode: video text2video
parameter_hint:
  num_frames: 161
  frame_rate: 24
```

Prompt recipe:

```text
A 10-second cinematic luxury fragrance ad: macro droplets on glass,
orbiting camera move, dim warm key light, restrained color grade, premium
brand pacing, final hero reveal.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 video text2video \
  --prompt "A 10-second cinematic luxury fragrance ad: macro droplets on glass, orbiting camera move, dim warm key light, restrained color grade, premium brand pacing, final hero reveal." \
  --json
```

## video.image_to_video

User:

```text
把这张图动起来。
```

Agent selects:

```yaml
preset: video.image_to_video
model: agnes-video-v2.0
mode: video img2video
parameter_hint:
  num_frames: 121
  frame_rate: 24
  motion_intensity: subtle
```

Prompt recipe:

```text
Animate the still product image with a subtle slow parallax: keep the
bottle sharp and still, let the background glow shift gently, add a soft
camera dolly.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 video img2video \
  --image ./frame.png \
  --prompt "Animate the still product image with a subtle slow parallax: keep the bottle sharp and still, let the background glow shift gently, add a soft camera dolly." \
  --json
```

## video.keyframes

User:

```text
用这两张图做转场。
```

Agent selects:

```yaml
preset: video.keyframes
model: agnes-video-v2.0
mode: video keyframes
parameter_hint:
  num_frames: 161
  frame_rate: 24
```

Prompt recipe:

```text
Smooth morph between the two keyframes: keep the central figure stable,
blend background palette from cool dusk to warm dawn, end on a polished
hero pose.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 video keyframes \
  --image ./frame-a.png \
  --image ./frame-b.png \
  --prompt "Smooth morph between the two keyframes: keep the central figure stable, blend background palette from cool dusk to warm dawn, end on a polished hero pose." \
  --json
```

## Local Media Privacy Reminder

Any local image passed to `video img2video`, `video multivideo`, or
`video keyframes` is bridged to a temporary public URL by the companion CLI.
Warn the user before processing private or customer-owned media.