#!/usr/bin/env bash
# verify_presets.sh - End-to-end preset verification for agnes-ai-skill
#
# This script checks that the v1.3.0 preset guidance satisfies the acceptance
# criteria in `.plan/agnes_ai_skill_preset_execution_plan.md` sections 9.1
# (functional), 9.2 (engineering) and 9.3 (tests).
#
# It is the test harness for the preset work and runs without any API key or
# live network call. A separate `verify_cli_flags.sh` may consume real CLI
# help output when present.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Suppress per-check PASS output if --quiet is passed; only print
# failing checks and the summary. Useful when invoked from
# scripts/verify-skill.sh where per-check lines add noise.
QUIET=0
for arg in "$@"; do
    case "$arg" in
        --quiet) QUIET=1 ;;
    esac
done

if [[ "$QUIET" -eq 1 ]]; then
    pass() { :; }
fi

PASS_COUNT=0
FAIL_COUNT=0
FAILURES=()

# ---------- helpers ----------
pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    printf "  \033[32mPASS\033[0m %s\n" "$1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAILURES+=("$1")
    printf "  \033[31mFAIL\033[0m %s\n" "$1"
}

assert_file_exists() {
    local path="$1"
    local label="$2"
    if [[ -f "$REPO_ROOT/$path" ]]; then
        pass "$label ($path exists)"
    else
        fail "$label ($path missing)"
    fi
}

assert_file_contains() {
    local path="$1"
    local needle="$2"
    local label="$3"
    local full="$REPO_ROOT/$path"
    if [[ ! -f "$full" ]]; then
        fail "$label ($path missing)"
        return
    fi
    if grep -Fq -- "$needle" "$full"; then
        pass "$label"
    else
        fail "$label (missing text: $needle)"
    fi
}

assert_file_not_contains() {
    local path="$1"
    local needle="$2"
    local label="$3"
    local full="$REPO_ROOT/$path"
    if [[ ! -f "$full" ]]; then
        fail "$label ($path missing)"
        return
    fi
    if grep -Fq -- "$needle" "$full"; then
        fail "$label (found forbidden text: $needle)"
    else
        pass "$label"
    fi
}

section() {
    printf "\n== %s ==\n" "$1"
}

# ---------- Section 9.1: Functional ----------
section "9.1 Functional acceptance"

assert_file_exists "SKILL.md" "SKILL.md present"

for preset in image.quick image.landscape image.portrait image.product image.edit_or_compose; do
    assert_file_contains "SKILL.md" "$preset" "SKILL.md declares image preset $preset"
done

for preset in video.quick_preview video.standard video.social video.cinematic video.image_to_video video.keyframes; do
    assert_file_contains "SKILL.md" "$preset" "SKILL.md declares video preset $preset"
done

assert_file_contains "SKILL.md" "Preset Selection Rules" "SKILL.md has Preset Selection Rules section"
assert_file_contains "SKILL.md" "Local Media Privacy Warning" "SKILL.md has Local Media Privacy Warning"
assert_file_contains "SKILL.md" "video poll" "SKILL.md documents async video polling"
assert_file_contains "SKILL.md" "videoId" "SKILL.md references videoId for polling"

# response_format must NOT be promoted as a generic top-level field
# Heuristic: SKILL.md should warn about response_format misuse.
if grep -Fqi "response_format" "SKILL.md"; then
    pass "SKILL.md mentions response_format with caveats"
else
    fail "SKILL.md should at least mention response_format caveats"
fi
# Check SKILL.md does NOT positively recommend response_format as a
# top-level field. The warning text "Do not pass ... as a generic
# top-level field" is fine, but phrases like "response_format is a
# top-level field" or "pass --response_format" are not.
if grep -Eqi "(pass|--)response_format\b" "SKILL.md"; then
    fail "SKILL.md references response_format as a usable flag"
else
    pass "SKILL.md does not promote response_format as a usable flag"
fi
if grep -Eqi "response_format[^.]{0,80}\b(is|should|may|can)\b[^.]{0,40}\btop[- ]level" "SKILL.md"; then
    fail "SKILL.md promotes response_format as top-level"
else
    pass "SKILL.md does not promote response_format as top-level"
fi

# Image 2.0 preference for multi-image / heavy edit
assert_file_contains "SKILL.md" "Image 2.0" "SKILL.md references Image 2.0 strategy"
assert_file_contains "SKILL.md" "image-2.0-flash" "SKILL.md references agnes-image-2.0-flash"

# Video validation rules
assert_file_contains "SKILL.md" "8n + 1" "SKILL.md documents num_frames 8n+1 rule"
assert_file_contains "SKILL.md" "441" "SKILL.md documents num_frames max"
assert_file_contains "SKILL.md" "frame_rate" "SKILL.md documents frame_rate rule"

# Existing mandatory content preserved
assert_file_contains "SKILL.md" "AGNES_API_KEY" "SKILL.md keeps API key guidance"
assert_file_contains "SKILL.md" "CLI-first" "SKILL.md keeps CLI-first principle"
assert_file_contains "SKILL.md" "Installation" "SKILL.md keeps Installation section"

# Progressive disclosure ordering: TL;DR appears before Preset Tables;
# Preset Selection Rules appears before Preset Tables; Persisting Key
# pointer appears before Execution Contract.
assert_file_contains "SKILL.md" "TL;DR" "SKILL.md has TL;DR section"
tl_line=$(grep -n "^## TL;DR" SKILL.md | head -1 | cut -d: -f1)
sel_line=$(grep -n "^## Preset Selection Rules" SKILL.md | head -1 | cut -d: -f1)
img_line=$(grep -n "^## Image Presets" SKILL.md | head -1 | cut -d: -f1)
vid_line=$(grep -n "^## Video Presets" SKILL.md | head -1 | cut -d: -f1)
persist_line=$(grep -n "^## Persisting The Key" SKILL.md | head -1 | cut -d: -f1)
exec_line=$(grep -n "^## Execution Contract" SKILL.md | head -1 | cut -d: -f1)

if [[ -n "$tl_line" && -n "$sel_line" && -n "$img_line" ]]; then
    if (( tl_line < sel_line )) && (( sel_line < img_line )); then
        pass "Ordering: TL;DR ($tl_line) < Selection Rules ($sel_line) < Image Presets ($img_line)"
    else
        fail "Ordering violated: TL;DR=$tl_line Selection=$sel_line ImagePresets=$img_line"
    fi
fi

if [[ -n "$vid_line" && -n "$img_line" ]] && (( img_line < vid_line )); then
    pass "Ordering: Image Presets ($img_line) < Video Presets ($vid_line)"
fi

if [[ -n "$persist_line" && -n "$exec_line" ]] && (( persist_line < exec_line )); then
    pass "Ordering: Persisting Key pointer ($persist_line) < Execution Contract ($exec_line)"
fi

# Persisting Key section in SKILL.md must be short (pointer only)
if [[ -n "$persist_line" ]]; then
    next_section=$(awk -v start="$persist_line" 'NR>start && /^## / { print NR; exit }' SKILL.md)
    if [[ -z "$next_section" ]]; then
        next_section=$(wc -l < SKILL.md)
    fi
    persist_len=$((next_section - persist_line))
    if (( persist_len <= 10 )); then
        pass "Persisting Key section is a pointer (≤10 lines, actual $persist_len)"
    else
        fail "Persisting Key section too long (>$persist_len lines, should be ≤10)"
    fi
fi

# Persisting Key deep-dive must live in docs/persisting-api-key.md
assert_file_contains "docs/persisting-api-key.md" "AGNES_API_KEY_VALUE" "docs/persisting-api-key.md has shell snippet"

# Prompt recipes deep-dive must live in docs/prompt-recipes.md
if command grep -Fqi "text-to-video" docs/prompt-recipes.md; then
    pass "docs/prompt-recipes.md has text-to-video recipe"
else
    fail "docs/prompt-recipes.md missing text-to-video recipe"
fi
if command grep -Fqi "image-to-video" docs/prompt-recipes.md; then
    pass "docs/prompt-recipes.md has image-to-video recipe"
else
    fail "docs/prompt-recipes.md missing image-to-video recipe"
fi
if command grep -Fqi "keyframes" docs/prompt-recipes.md; then
    pass "docs/prompt-recipes.md has keyframes recipe"
else
    fail "docs/prompt-recipes.md missing keyframes recipe"
fi
if command grep -Fqi "dense image" docs/prompt-recipes.md; then
    pass "docs/prompt-recipes.md has dense image recipe"
else
    fail "docs/prompt-recipes.md missing dense image recipe"
fi

# ---------- Section 9.2: Engineering ----------
section "9.2 Engineering acceptance"

assert_file_exists "README.md" "README.md present"
assert_file_exists "README.zh-CN.md" "README.zh-CN.md present"
assert_file_exists "docs/version-policy.md" "docs/version-policy.md present"
assert_file_exists "docs/preset-design.md" "docs/preset-design.md present"
assert_file_exists "docs/cli-flag-verification.md" "docs/cli-flag-verification.md present"
assert_file_exists "docs/persisting-api-key.md" "docs/persisting-api-key.md present"
assert_file_exists "docs/prompt-recipes.md" "docs/prompt-recipes.md present"
assert_file_exists "examples/image-presets.md" "examples/image-presets.md present"
assert_file_exists "examples/video-presets.md" "examples/video-presets.md present"

assert_file_contains "docs/version-policy.md" "1.2.2" "version policy references current 1.2.2"
assert_file_contains "docs/version-policy.md" "1.3.0" "version policy mentions 1.3.0"

assert_file_contains "docs/preset-design.md" "image.quick" "preset design lists image.quick"
assert_file_contains "docs/preset-design.md" "video.keyframes" "preset design lists video.keyframes"

# All 11 preset IDs referenced in README
for preset in image.quick image.landscape image.portrait image.product image.edit_or_compose video.quick_preview video.standard video.social video.cinematic video.image_to_video video.keyframes; do
    assert_file_contains "README.md" "$preset" "README.md references $preset"
done

# All 11 preset IDs referenced in README.zh-CN.md
for preset in image.quick image.landscape image.portrait image.product image.edit_or_compose video.quick_preview video.standard video.social video.cinematic video.image_to_video video.keyframes; do
    assert_file_contains "README.zh-CN.md" "$preset" "README.zh-CN.md references $preset"
done

# Optional YAML maintenance sources
if [[ -f "$REPO_ROOT/configs/image-presets.yaml" ]]; then
    assert_file_contains "configs/image-presets.yaml" "SKILL.md" "image-presets.yaml names SKILL.md as source of truth"
fi
if [[ -f "$REPO_ROOT/configs/video-presets.yaml" ]]; then
    assert_file_contains "configs/video-presets.yaml" "SKILL.md" "video-presets.yaml names SKILL.md as source of truth"
fi

# Markdown reflow sanity: README.zh-CN.md should be multi-line
zh_line_count=$(wc -l < "$REPO_ROOT/README.zh-CN.md")
if [[ "$zh_line_count" -gt 100 ]]; then
    pass "README.zh-CN.md is line-reflowed (>$zh_line_count lines)"
else
    fail "README.zh-CN.md appears compressed (only $zh_line_count lines)"
fi

# ---------- Section 9.3: Tests ----------
section "9.3 Test acceptance"

# CLI flag verification matrix should not be entirely TBD
if [[ -f "$REPO_ROOT/docs/cli-flag-verification.md" ]]; then
    if grep -Fqi "tbd" "$REPO_ROOT/docs/cli-flag-verification.md"; then
        fail "docs/cli-flag-verification.md still contains TBD markers"
    else
        pass "docs/cli-flag-verification.md has no raw TBD markers"
    fi
fi

# Example files must not contain unverified flag docs (we use a deny list)
DENY_FLAGS=("--num-frames " "--frame-rate " " --width " " --height ")
for ex in examples/image-presets.md examples/video-presets.md; do
    full="$REPO_ROOT/$ex"
    if [[ ! -f "$full" ]]; then
        continue
    fi
    for flag in "${DENY_FLAGS[@]}"; do
        # The example may mention these flags only in a "do not pass" or
        # "requires verification" sentence, never in an executable command.
        # Heuristic: count executable lines containing the flag.
        bad=$(grep -E "^\s*(npx|agnes).*${flag}" "$full" || true)
        if [[ -n "$bad" ]]; then
            fail "$ex documents unverified flag in executable line: $flag"
        else
            pass "$ex does not promote $flag as executable"
        fi
    done
done

# Markdown link integrity (only when README mentions linkable files)
# (Light check - skip deep validation.)

# ---------- Summary ----------
section "Summary"

printf "Passed: %d\n" "$PASS_COUNT"
printf "Failed: %d\n" "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo
    echo "Failing checks:"
    for f in "${FAILURES[@]}"; do
        printf "  - %s\n" "$f"
    done
    exit 1
fi

echo
echo "All preset verification checks passed."
exit 0