# Prompt Recipes

This file collects the deep-dive prompt recipes for Agnes image and video
generation. The minimal rules live in `SKILL.md` -> `Preset Strategy`;
consult this file when an agent needs detailed prompt guidance or wants
to compose longer prompts.

## Image Prompts

### Dense Image Recipe

For high-information-density images, be explicit about:

- primary subject
- background environment
- important secondary details
- style and lighting
- composition constraints

### Edit Prompt Recipe

For edits, explicitly separate:

- what should change
- what must stay fixed

This separation lets Image 2.1 (or Image 2.0 for heavier edits) preserve
the parts the user wants untouched.

### Multi-Image Composition Recipe

For `image compose`, the prompt should describe:

- how the input images relate
- which subject or style to draw from each
- the final unified composition goal

### Product Recipe

For product ads and ecommerce, cover:

- product subject and material
- background and pedestal
- lighting direction and quality
- camera angle and lens feel
- commercial composition style

## Video Prompts

### Text-To-Video Recipe

For `video text2video`, describe:

- subject
- action
- environment
- camera movement
- lighting
- style

### Image-To-Video Recipe

For `video img2video`, describe:

- what should move
- what should stay stable
- how subtle or dramatic the motion should be
- camera movement (subtle dolly, parallax, push-in)

### Keyframes And Multi-Image Video Recipe

For `video keyframes` and `video multivideo`, describe:

- how the inputs relate
- what continuity should remain stable
- what transition feeling is desired
- which stable elements anchor the morph

## CLI Hints

- Prefer the dedicated `video keyframes` subcommand over inventing your
  own payload shape.
- Use `video poll <videoId>` after any asynchronous video creation.
- For local input files, the CLI handles the temporary public URL bridge
  automatically. See `SKILL.md` -> `Local Media Privacy Warning`.