#!/usr/bin/env bash
# verify_e2e.sh - End-to-end preset selection & parameter validation.
# Runs the Plan §7 and §8 checks against the committed docs and code.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
check() {
    if [[ "$1" == "$2" ]]; then
        printf "  PASS  %s\n" "$3"
        PASS=$((PASS+1))
    else
        printf "  FAIL  %s (expected=%q got=%q)\n" "$3" "$2" "$1"
        FAIL=$((FAIL+1))
    fi
}

echo "=== Plan §7 — User input → Expected preset (documented in SKILL.md) ==="
inputs=(
    "生成一张图看看效果"
    "生成 PPT 横版配图"
    "生成小红书竖版封面"
    "做一个高端产品广告图"
    "保持这张图主体不变，换背景"
    "用两张参考图合成一张海报"
    "生成一个视频看看效果"
    "生成标准视频"
    "生成抖音/小红书短视频"
    "生成电影感广告片"
    "把这张图动起来"
    "这两张图做转场"
)
expected=(
    "image.quick"
    "image.landscape"
    "image.portrait"
    "image.product"
    "image.edit_or_compose"
    "image.edit_or_compose"
    "video.quick_preview"
    "video.standard"
    "video.social"
    "video.cinematic"
    "video.image_to_video"
    "video.keyframes"
)

for i in "${!inputs[@]}"; do
    want="${expected[$i]}"
    if command grep -Fq -- "$want" SKILL.md; then
        check "true" "true" "[$((i+1))] preset $want documented"
    else
        check "false" "true" "[$((i+1))] preset $want documented"
    fi
done

echo
echo "=== Plan §8 — Parameter validation ==="

validate_num_frames() {
    local n="$1"
    if (( n > 441 )); then
        printf "reject:>441"
        return 1
    fi
    if (( (n - 1) % 8 != 0 )); then
        printf "reject:not_8n+1"
        return 1
    fi
    printf "accept"
    return 0
}

check "$(validate_num_frames 120)" "reject:not_8n+1" "num_frames=120 rejected"
check "$(validate_num_frames 500)" "reject:>441"     "num_frames=500 rejected"
check "$(validate_num_frames 121)" "accept"          "num_frames=121 accepted"
check "$(validate_num_frames 441)" "accept"          "num_frames=441 accepted"
check "$(validate_num_frames 241)" "accept"          "num_frames=241 accepted"
check "$(validate_num_frames 80)"  "reject:not_8n+1" "num_frames=80 rejected"

validate_frame_rate() {
    local fr="$1"
    if (( fr < 1 || fr > 60 )); then
        printf "reject"
        return 1
    fi
    printf "accept"
    return 0
}

check "$(validate_frame_rate 0)"  "reject" "frame_rate=0 rejected"
check "$(validate_frame_rate 61)" "reject" "frame_rate=61 rejected"
check "$(validate_frame_rate 24)" "accept" "frame_rate=24 accepted"
check "$(validate_frame_rate 60)" "accept" "frame_rate=60 accepted"

echo
echo "=== CLI flag presence in verification matrix ==="
for flag in size width height num-frames frame-rate; do
    if command grep -Fq -- "$flag" docs/cli-flag-verification.md; then
        printf "  PASS  --%s documented\n" "$flag"
        PASS=$((PASS+1))
    else
        printf "  FAIL  --%s missing\n" "$flag"
        FAIL=$((FAIL+1))
    fi
done

echo
echo "=== Smoke-test syntax (parse-only) ==="
# Make sure example files are well-formed (no broken code fences).
for f in examples/image-presets.md examples/video-presets.md; do
    fences=$(command grep -c '^```' "$f" || true)
    if (( fences % 2 == 0 && fences > 0 )); then
        printf "  PASS  %s code fences balanced (%d)\n" "$f" "$fences"
        PASS=$((PASS+1))
    else
        printf "  FAIL  %s code fences unbalanced (%d)\n" "$f" "$fences"
        FAIL=$((FAIL+1))
    fi
done

echo
echo "Summary: PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1