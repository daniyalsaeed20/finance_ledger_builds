#!/usr/bin/env bash
set -euo pipefail

# One-command release automation for finance_ledger_builds.
#
# What it does:
# 1) Creates releases/<version>/ and copies notes + versioned apk locally.
# 2) Updates VERSION.json latest fields.
# 3) Updates README "Latest" download and latest notes sections.
# 4) Commits + pushes metadata changes.
# 5) Creates/updates GitHub Release and uploads:
#    - chillcheck_v<version>.apk
#    - chillcheck_latest.apk (uploaded from temp file, not stored in repo)
#
# Usage:
#   ./tool/publish_release.sh <version> <apk_path> [notes_path]
#
# Example:
#   ./tool/publish_release.sh 0.0.2+2 \
#     "/abs/path/to/app-release.apk" \
#     "/Users/me/Desktop/finance_ledger/finance_ledger/release_notes.md"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <version> <apk_path> [notes_path]"
  exit 1
fi

VERSION="$1"                  # e.g. 0.0.1+1
APK_SOURCE="$2"               # e.g. /.../build/app/outputs/flutter-apk/app-release.apk
NOTES_SOURCE="${3:-../finance_ledger/release_notes.md}"

REPO="daniyalsaeed20/finance_ledger_builds"
REPO_URL="https://github.com/${REPO}"
TAG="v${VERSION}"
TAG_ENCODED="${TAG//+/%2B}"
TODAY="$(date +%F)"
REL_DIR="releases/${VERSION}"
REL_NOTES_DEST="${REL_DIR}/release-notes.md"
APK_VERSIONED_NAME="chillcheck_v${VERSION}.apk"
APK_VERSIONED_LOCAL="${REL_DIR}/${APK_VERSIONED_NAME}"
TMP_DIR="$(mktemp -d -t chillcheck_release.XXXXXX)"
TMP_LATEST_APK="${TMP_DIR}/chillcheck_latest.apk"
LATEST_APK_URL="${REPO_URL}/releases/latest/download/chillcheck_latest.apk"
VERSION_APK_URL="${REPO_URL}/releases/download/${TAG_ENCODED}/${APK_VERSIONED_NAME}"
TAG_URL="${REPO_URL}/releases/tag/${TAG_ENCODED}"

for bin in python3 git gh; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Error: required command not found: $bin"
    exit 1
  fi
done

if [[ ! -f "${APK_SOURCE}" ]]; then
  echo "Error: APK not found: ${APK_SOURCE}"
  exit 1
fi

if [[ ! -f "${NOTES_SOURCE}" ]]; then
  echo "Error: release notes file not found: ${NOTES_SOURCE}"
  exit 1
fi

mkdir -p "${REL_DIR}"
cp "${NOTES_SOURCE}" "${REL_NOTES_DEST}"
cp "${APK_SOURCE}" "${APK_VERSIONED_LOCAL}"
cp "${APK_SOURCE}" "${TMP_LATEST_APK}"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

RELEASE_VERSION="${VERSION}" \
RELEASE_DATE="${TODAY}" \
RELEASE_TAG="${TAG}" \
RELEASE_TAG_URL="${TAG_URL}" \
RELEASE_LATEST_APK_URL="${LATEST_APK_URL}" \
RELEASE_VERSION_APK_URL="${VERSION_APK_URL}" \
RELEASE_NOTES_PATH="${REL_NOTES_DEST}" \
python3 - <<'PY'
import json
import os
import pathlib
import re

version = os.environ["RELEASE_VERSION"]
today = os.environ["RELEASE_DATE"]
tag = os.environ["RELEASE_TAG"]
tag_url = os.environ["RELEASE_TAG_URL"]
latest_apk_url = os.environ["RELEASE_LATEST_APK_URL"]
version_apk_url = os.environ["RELEASE_VERSION_APK_URL"]
notes_path = os.environ["RELEASE_NOTES_PATH"]
readme = pathlib.Path("README.md")
version_file = pathlib.Path("VERSION.json")

# Update VERSION.json
data = json.loads(version_file.read_text())
data["latest_version"] = version
data["latest_release_date"] = today
data["latest_apk"] = latest_apk_url
data["latest_release_notes"] = notes_path
version_file.write_text(json.dumps(data, indent=2) + "\n")

content = readme.read_text()

download_block = f"""- **Latest:** `{tag}`
- **Current stable release page:** `{tag_url}`

[![Download Latest APK ({tag})](https://img.shields.io/badge/Download%20Latest-{tag.replace('+', '%2B')}-2ea44f?style=for-the-badge&logo=android)]({latest_apk_url})

[![Download {tag} APK](https://img.shields.io/badge/Download-{tag.replace('+', '%2B')}-blue?style=for-the-badge&logo=android)]({version_apk_url})

Direct links:
- Latest channel: `{latest_apk_url}`
- Version `{tag}`: `{version_apk_url}`"""

latest_notes_block = f"""### {version}
- Latest public release for ChillCheck.
- Download and install from the button/link section above.
- Detailed notes: `{notes_path}`"""

content = re.sub(
    r"<!-- RELEASE_DOWNLOAD_BLOCK_START -->.*?<!-- RELEASE_DOWNLOAD_BLOCK_END -->",
    "<!-- RELEASE_DOWNLOAD_BLOCK_START -->\\n" + download_block + "\\n<!-- RELEASE_DOWNLOAD_BLOCK_END -->",
    content,
    flags=re.S,
)

content = re.sub(
    r"<!-- RELEASE_NOTES_LATEST_START -->.*?<!-- RELEASE_NOTES_LATEST_END -->",
    "<!-- RELEASE_NOTES_LATEST_START -->\\n" + latest_notes_block + "\\n<!-- RELEASE_NOTES_LATEST_END -->",
    content,
    flags=re.S,
)

content = re.sub(
    r"Full notes: `releases/[^`]+/release-notes\.md`",
    f"Full notes: `{notes_path}`",
    content,
)

readme.write_text(content)
PY

git add README.md VERSION.json "${REL_NOTES_DEST}"

if ! git diff --cached --quiet; then
  git commit -m "Release metadata and notes for ${TAG}"
  git push origin main
else
  echo "No metadata changes to commit."
fi

if gh release view "${TAG}" --repo "${REPO}" >/dev/null 2>&1; then
  gh release edit "${TAG}" \
    --repo "${REPO}" \
    --title "ChillCheck ${TAG}" \
    --notes-file "${REL_NOTES_DEST}"
  gh release upload "${TAG}" \
    --repo "${REPO}" \
    "${APK_VERSIONED_LOCAL}" \
    "${TMP_LATEST_APK}" \
    --clobber
else
  gh release create "${TAG}" \
    --repo "${REPO}" \
    --title "ChillCheck ${TAG}" \
    --notes-file "${REL_NOTES_DEST}" \
    "${APK_VERSIONED_LOCAL}" \
    "${TMP_LATEST_APK}"
fi

echo "Release automation completed for ${TAG}."
echo "Latest APK URL: ${LATEST_APK_URL}"
echo "Version APK URL: ${VERSION_APK_URL}"
