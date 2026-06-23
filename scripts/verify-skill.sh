#!/usr/bin/env bash
# verify-skill.sh - Validate a built .skill tarball.
#
# Checks:
#   - file is a gzipped tar
#   - root contains agnes-ai-skill/ directory
#   - SKILL.md exists with valid frontmatter (name, version, description)
#   - README.md, LICENSE exist
#   - docs/preset-design.md, docs/cli-flag-verification.md exist
#   - examples/image-presets.md, examples/video-presets.md exist
#   - tests/verify_presets.sh, tests/verify_e2e.sh exist and run
#   - version in BUILD_INFO.txt matches SKILL.md frontmatter
#
# Usage:
#   bash scripts/verify-skill.sh path/to/agnes-ai-skill-1.3.0.skill
#   bash scripts/verify-skill.sh              # uses latest dist/*.skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); }

# ----- Resolve artifact -----
if [[ $# -ge 1 ]]; then
    ARTIFACT="$1"
else
    ARTIFACT=$(ls -t "$REPO_ROOT"/dist/agnes-ai-skill-*.skill 2>/dev/null | head -1 || true)
    [[ -n "$ARTIFACT" ]] || { echo "ERROR: no artifact given and no dist/*.skill found" >&2; exit 2; }
fi

[[ -f "$ARTIFACT" ]] || { echo "ERROR: artifact not found: $ARTIFACT" >&2; exit 2; }

printf "Verifying: %s\n" "$ARTIFACT"
printf "Size:      %s\n\n" "$(du -h "$ARTIFACT" | awk '{print $1}')"

# ----- Staging for extraction -----
WORK="$(mktemp -d -t agnes-ai-skill-verify.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

# Detect gzip vs plain tar
file_type=$(file -b "$ARTIFACT" 2>/dev/null || true)
if echo "$file_type" | grep -q "gzip"; then
    tar -xzf "$ARTIFACT" -C "$WORK"
elif echo "$file_type" | grep -q "tar archive"; then
    tar -xf "$ARTIFACT" -C "$WORK"
else
    fail "artifact is not a tar or tar.gz: $file_type"
    exit 1
fi

ROOT_DIR="$WORK/agnes-ai-skill"
if [[ ! -d "$ROOT_DIR" ]]; then
    # Fallback: use the single top-level directory.
    first=$(ls "$WORK" | head -1)
    if [[ -d "$WORK/$first" ]]; then
        ROOT_DIR="$WORK/$first"
    else
        fail "no agnes-ai-skill/ root inside artifact"
        exit 1
    fi
fi
pass "root directory present: $ROOT_DIR"

# ----- Required files -----
for f in SKILL.md README.md README.zh-CN.md LICENSE; do
    if [[ -f "$ROOT_DIR/$f" ]]; then
        pass "required file: $f"
    else
        fail "missing required file: $f"
    fi
done

# ----- Required docs -----
for f in docs/preset-design.md docs/cli-flag-verification.md \
         docs/persisting-api-key.md docs/prompt-recipes.md \
         docs/version-policy.md; do
    if [[ -f "$ROOT_DIR/$f" ]]; then
        pass "required doc: $f"
    else
        fail "missing required doc: $f"
    fi
done

# ----- Required examples -----
for f in examples/image-presets.md examples/video-presets.md; do
    if [[ -f "$ROOT_DIR/$f" ]]; then
        pass "required example: $f"
    else
        fail "missing required example: $f"
    fi
done

# ----- Required configs -----
for f in configs/image-presets.yaml configs/video-presets.yaml; do
    if [[ -f "$ROOT_DIR/$f" ]]; then
        pass "required config: $f"
    else
        fail "missing required config: $f"
    fi
done

# ----- Required tests -----
for f in tests/verify_presets.sh tests/verify_e2e.sh; do
    if [[ -x "$ROOT_DIR/$f" ]]; then
        pass "required test (executable): $f"
    elif [[ -f "$ROOT_DIR/$f" ]]; then
        fail "test not executable: $f"
    else
        fail "missing required test: $f"
    fi
done

# ----- Frontmatter -----
fm=$(awk '/^---$/{c++; next} c==1' "$ROOT_DIR/SKILL.md")
for key in name version description; do
    if echo "$fm" | grep -q "^${key}:"; then
        pass "frontmatter has ${key}:"
    else
        fail "frontmatter missing ${key}:"
    fi
done

# Extract version
PKG_VERSION=$(echo "$fm" | awk '/^version:/{sub(/^version: */,""); sub(/["]/,""); print}')
pass "parsed version: $PKG_VERSION"

# ----- BUILD_INFO consistency -----
if [[ -f "$ROOT_DIR/BUILD_INFO.txt" ]]; then
    pass "BUILD_INFO.txt present"
    bi_version=$(awk '/^version:/{print $2}' "$ROOT_DIR/BUILD_INFO.txt")
    if [[ "$bi_version" == "$PKG_VERSION" ]]; then
        pass "BUILD_INFO version matches SKILL.md ($bi_version)"
    else
        fail "BUILD_INFO version ($bi_version) != SKILL.md version ($PKG_VERSION)"
    fi
else
    fail "BUILD_INFO.txt missing"
fi

# ----- Run packaged tests -----
printf "\nRunning packaged tests/verify_presets.sh ...\n"
if (cd "$ROOT_DIR" && bash tests/verify_presets.sh --quiet 2>&1 | tail -3); then
    pass "packaged verify_presets.sh passed"
else
    fail "packaged verify_presets.sh failed"
fi

printf "\nRunning packaged tests/verify_e2e.sh ...\n"
if (cd "$ROOT_DIR" && bash tests/verify_e2e.sh 2>&1 | tail -3); then
    pass "packaged verify_e2e.sh passed"
else
    fail "packaged verify_e2e.sh failed"
fi

# ----- Summary -----
printf "\n== Summary ==\n"
printf "Passed: %d\n" "$PASS"
printf "Failed: %d\n" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1