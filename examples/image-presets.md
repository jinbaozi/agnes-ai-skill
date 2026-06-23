# Image Preset Examples

This file shows what an agent should do for each image preset. Every example
keeps the executable command minimal until the CLI flag verification matrix
in `docs/cli-flag-verification.md` confirms that the optional flags actually
exist.

## image.product

User:

```text
用 Agnes 生成一张高端香水产品广告图。
```

Agent selects:

```yaml
preset: image.product
model: agnes-image-2.1-flash
mode: image text2img
```

Prompt recipe:

```text
Premium studio product advertisement for a translucent perfume bottle on a
travertine pedestal, warm champagne-gold studio lighting, refined reflections,
quiet luxury brand mood, clean commercial composition.
```

CLI before optional flag verification:

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img \
  --prompt "Premium studio product advertisement for a translucent perfume bottle on a travertine pedestal, warm champagne-gold studio lighting, refined reflections, quiet luxury brand mood, clean commercial composition." \
  --json
```

Note:

Do not add `--size` until `image text2img --help` confirms support.

## image.landscape

User:

```text
帮我做一张 PPT 横版配图。
```

Agent selects:

```yaml
preset: image.landscape
model: agnes-image-2.1-flash
mode: image text2img
orientation_hint: landscape
```

Prompt recipe:

```text
Wide 16:9 landscape illustration for a slide, calm blue gradient sky, soft
sunlight, distant mountain silhouette, minimal foreground subject, clean
negative space for headline copy.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img \
  --prompt "Wide 16:9 landscape illustration for a slide, calm blue gradient sky, soft sunlight, distant mountain silhouette, minimal foreground subject, clean negative space for headline copy." \
  --json
```

## image.portrait

User:

```text
生成一张小红书竖版封面。
```

Agent selects:

```yaml
preset: image.portrait
model: agnes-image-2.1-flash
mode: image text2img
orientation_hint: portrait
```

Prompt recipe:

```text
Vertical 9:16 mobile cover, soft pastel background, bold typographic
headline area, warm product still life in the lower third, gentle studio
light, bright editorial mood.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img \
  --prompt "Vertical 9:16 mobile cover, soft pastel background, bold typographic headline area, warm product still life in the lower third, gentle studio light, bright editorial mood." \
  --json
```

## image.quick

User:

```text
生成一张图看看效果。
```

Agent selects:

```yaml
preset: image.quick
model: agnes-image-2.1-flash
mode: image text2img
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 image text2img \
  --prompt "A quick concept image: a clean ceramic mug on a wooden desk near a window with morning light." \
  --json
```

## image.edit_or_compose

User:

```text
把这张图的主体换成户外场景，但保留构图。
```

Agent selects:

```yaml
preset: image.edit_or_compose
model: agnes-image-2.1-flash   # or agnes-image-2.0-flash for heavier edits
mode: image img2img            # or image compose if multiple inputs
```

Prompt recipe:

```text
Keep the original subject placement and composition. Replace the background
with a soft outdoor park scene in golden hour. Preserve lighting direction
and overall framing.
```

CLI:

```bash
npx -y agnes-ai-cli@^0.1.0 image img2img \
  --image ./input.png \
  --prompt "Keep the original subject placement and composition. Replace the background with a soft outdoor park scene in golden hour. Preserve lighting direction and overall framing." \
  --json
```

Note:

For multi-image composition, switch the CLI mode to `image compose` and
pass multiple `--image` arguments. Verify support before passing extra
options.

## Local Media Privacy Reminder

Any local image passed to `image img2img` or `image compose` is bridged to
a temporary public URL by the companion CLI. Warn the user before processing
private or customer-owned media.