#!/usr/bin/env bash
# build-skill.sh - Package this repository into a publishable .skill tarball.
#
# Output: dist/agnes-ai-skill-<version>.skill
#
# The .skill file is a gzipped tar archive whose root contains SKILL.md,
# docs/, examples/, configs/, scripts/, tests/, README files, and
# LICENSE. It is installable by:
#   - manual extraction into a skills directory (e.g. ~/.codex/skills/)
#   - npx skills install ./dist/agnes-ai-skill-<version>.skill (when supported)
#   - GitHub release asset downloads
#
# Usage:
#   bash scripts/build-skill.sh           # build into dist/
#   bash scripts/build-skill.sh --keep    # keep staging directory after build
#   bash scripts/build-skill.sh --quiet   # only print final artifact path

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

KEEP_STAGING=0
QUIET=0
LIGHT=0
for arg in "$@"; do
    case "$arg" in
        --keep)  KEEP_STAGING=1 ;;
        --quiet) QUIET=1 ;;
        --light) LIGHT=1 ;;
        -h|--help)
            sed -n '2,16p' "$0"
            exit 0
            ;;
        *)
            echo "Unknown arg: $arg" >&2
            exit 2
            ;;
    esac
done

log() {
    [[ "$QUIET" -eq 1 ]] || printf '%s\n' "$*"
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

# ----- 1. Extract version from SKILL.md frontmatter -----
[[ -f SKILL.md ]] || fail "SKILL.md not found in $REPO_ROOT"
VERSION=$(awk '/^---$/{c++; next} c==1 && /^version:/{sub(/^version: */,""); sub(/["]/,""); print; exit}' SKILL.md)
[[ -n "$VERSION" ]] || fail "Could not parse version from SKILL.md frontmatter"
log "Detected SKILL.md version: $VERSION"

# ----- 2. Set up staging directory -----
DIST_DIR="$REPO_ROOT/dist"
STAGING="$(mktemp -d -t agnes-ai-skill-build.XXXXXX)"
trap 'rm -rf "$STAGING"' EXIT
SKILL_STAGE="$STAGING/agnes-ai-skill"

mkdir -p "$DIST_DIR" "$SKILL_STAGE"

# ----- 3. Copy required files -----
# Always: SKILL.md, README, LICENSE
# Folders: docs/, examples/, configs/, scripts/, tests/
# Skip:    .git, .plan/, dist/, node_modules/, *.skill, .github/ (optional)

copy_path() {
    local src="$1"
    if [[ ! -e "$REPO_ROOT/$src" ]]; then
        log "  skip (missing): $src"
        return
    fi
    cp -R "$REPO_ROOT/$src" "$SKILL_STAGE/"
    log "  include: $src"
}

log "Staging skill contents:"
copy_path "SKILL.md"
copy_path "README.md"
copy_path "README.zh-CN.md"
copy_path "LICENSE"
copy_path "docs"
copy_path "examples"
copy_path "configs"
copy_path "scripts"
copy_path "tests"
copy_path "agents"

# Assets are heavy showcase material. --light excludes video files
# but keeps images / preview thumbs / app screenshots.
if [[ "$LIGHT" -eq 1 ]]; then
    log "  --light: skipping assets/videos (heavy showcase only)"
    [[ -d "$REPO_ROOT/assets" ]] && {
        mkdir -p "$SKILL_STAGE/assets"
        find "$REPO_ROOT/assets" -mindepth 1 -maxdepth 1 \
            ! -name 'videos' -exec cp -R {} "$SKILL_STAGE/assets/" \;
        log "  include: assets (excluding videos/)"
    }
else
    copy_path "assets"
fi

# Drop test scripts from runtime payload? No — tests are useful for
# downstream skills to verify their install.
# Trim .plan if it slipped in (it is intentionally untracked, but be safe).
[[ -d "$SKILL_STAGE/.plan" ]] && rm -rf "$SKILL_STAGE/.plan"

# ----- 4. Inject build manifest -----
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_HOST=$(hostname 2>/dev/null || echo unknown)
GIT_COMMIT=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)
GIT_BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)

cat > "$SKILL_STAGE/BUILD_INFO.txt" <<EOF
name: agnes-ai-skill
version: $VERSION
build_date: $BUILD_DATE
build_host: $BUILD_HOST
git_commit: $GIT_COMMIT
git_branch: $GIT_BRANCH
format: skill-tarball-v1
EOF
log "Wrote BUILD_INFO.txt"

# ----- 5. Build tarball -----
OUT_NAME="agnes-ai-skill-$VERSION.skill"
OUT_PATH="$DIST_DIR/$OUT_NAME"

# Use plain tar so the .skill extension makes the file self-describing.
tar -C "$STAGING" -czf "$OUT_PATH" agnes-ai-skill

if [[ "$KEEP_STAGING" -eq 1 ]]; then
    log "Staging kept at: $SKILL_STAGE"
    trap - EXIT
fi

# ----- 6. Report -----
SIZE_BYTES=$(stat -c '%s' "$OUT_PATH" 2>/dev/null || stat -f '%z' "$OUT_PATH")
SIZE_HUMAN=$(numfmt --to=iec --suffix=B "$SIZE_BYTES" 2>/dev/null || echo "${SIZE_BYTES}B")

log ""
log "Built: $OUT_PATH"
log "Size:  $SIZE_HUMAN"
log "SHA256: $(sha256sum "$OUT_PATH" | awk '{print $1}')"

echo "$OUT_PATH"