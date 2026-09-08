#!/usr/bin/env bash
set -euo pipefail

# One-command release automation for finance_ledger_builds.
#
# What it does:
# 1) Creates releases/<version>/ and copies notes + versioned apk locally.
# 2) Updates VERSION.json latest fields and rolls previous latest into previous_versions.
# 3) Updates README Latest download block, Previous Builds block, and latest notes.
# 4) Commits + pushes metadata changes.
# 5) Creates/updates GitHub Release and uploads:
#    - chillcheck_v<version>.apk
#    - chillcheck_latest.apk (uploaded from temp file, not stored in repo)
#
# Optional 4th arg:
#   compatible_previous_version  (e.g. 0.0.2+3)
#   If omitted, previous latest is treated as the compatible previous build.
#
# Usage:
#   ./tool/publish_release.sh <version> <apk_path> [notes_path]
#
# Example:
#   ./tool/publish_release.sh 0.0.2+2 \
#     "/abs/path/to/app-release.apk" \
#     "/Users/me/Desktop/finance_ledger/finance_ledger/release_notes.md"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <version> <apk_path> [notes_path] [compatible_previous_version]"
  exit 1
fi

VERSION="$1"                  # e.g. 0.0.1+1
APK_SOURCE="$2"               # e.g. /.../build/app/outputs/flutter-apk/app-release.apk
NOTES_SOURCE="${3:-../finance_ledger/release_notes.md}"
COMPATIBLE_PREVIOUS="${4:-}"

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
RELEASE_REPO_URL="${REPO_URL}" \
RELEASE_COMPATIBLE_PREVIOUS="${COMPATIBLE_PREVIOUS}" \
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
repo_url = os.environ["RELEASE_REPO_URL"]
compatible_previous = os.environ.get("RELEASE_COMPATIBLE_PREVIOUS", "").strip()
readme = pathlib.Path("README.md")
version_file = pathlib.Path("VERSION.json")


def encoded_tag(v: str) -> str:
    return f"v{v}".replace("+", "%2B")


def version_apk_url_for(v: str) -> str:
    return f"{repo_url}/releases/download/{encoded_tag(v)}/chillcheck_v{v}.apk"


def release_page_for(v: str) -> str:
    return f"{repo_url}/releases/tag/{encoded_tag(v)}"


def notes_path_for(v: str) -> str:
    return f"releases/{v}/release-notes.md"


# Update VERSION.json while preserving previous builds history.
data = json.loads(version_file.read_text())
previous_versions = list(data.get("previous_versions") or [])
old_latest = data.get("latest_version")

if old_latest and old_latest != version:
    old_entry = {
        "version": old_latest,
        "release_date": data.get("latest_release_date", today),
        "apk": version_apk_url_for(old_latest),
        "release_page": release_page_for(old_latest),
        "release_notes": notes_path_for(old_latest),
        "compatible_with_latest": False,
    }
    previous_versions = [e for e in previous_versions if e.get("version") != old_latest]
    previous_versions.insert(0, old_entry)

# Ensure current version is not listed under previous builds.
previous_versions = [e for e in previous_versions if e.get("version") != version]

if not compatible_previous and previous_versions:
    compatible_previous = previous_versions[0]["version"]

for entry in previous_versions:
    entry["compatible_with_latest"] = entry.get("version") == compatible_previous

data["latest_version"] = version
data["latest_release_date"] = today
data["latest_apk"] = latest_apk_url
data["latest_release_notes"] = notes_path
data["compatible_previous_version"] = compatible_previous or None
data["previous_versions"] = previous_versions
version_file.write_text(json.dumps(data, indent=2) + "\n")

content = readme.read_text()

compat_line = ""
if compatible_previous:
    compat_line = f"\n- **Compatibility:** `{tag}` is compatible with `v{compatible_previous}`"

download_block = f"""- **Latest:** `{tag}`
- **Current stable release page:** `{tag_url}`{compat_line}

[![Download Latest APK ({tag})](https://img.shields.io/badge/Download%20Latest-{tag.replace('+', '%2B')}-2ea44f?style=for-the-badge&logo=android)]({latest_apk_url})

[![Download {tag} APK](https://img.shields.io/badge/Download-{tag.replace('+', '%2B')}-blue?style=for-the-badge&logo=android)]({version_apk_url})

Direct links:
- Latest channel: `{latest_apk_url}`
- Version `{tag}`: `{version_apk_url}`"""

latest_notes_block = f"""### {version}
- Latest public release for ChillCheck.
- Download and install from the button/link section above.
- Detailed notes: `{notes_path}`"""

# Build Previous Builds section from VERSION.json history.
compatible_entry = next(
    (e for e in previous_versions if e.get("version") == compatible_previous),
    None,
)
older_entries = [
    e for e in previous_versions if e.get("version") != compatible_previous
]

previous_parts = []
if compatible_entry:
    cv = compatible_entry["version"]
    previous_parts.append(
        f"""### Compatible previous: `v{cv}`

- **Status:** Compatible with latest (`{tag}`)
- **Release page:** `{compatible_entry.get("release_page", release_page_for(cv))}`
- **Release notes:** `{compatible_entry.get("release_notes", notes_path_for(cv))}`

[![Download v{cv} APK](https://img.shields.io/badge/Download-v{cv.replace('+', '%2B')}-informational?style=for-the-badge&logo=android)]({compatible_entry.get("apk", version_apk_url_for(cv))})

Direct link:
- Version `v{cv}`: `{compatible_entry.get("apk", version_apk_url_for(cv))}`"""
    )

if older_entries:
    older_lines = []
    for entry in older_entries:
        ov = entry["version"]
        older_lines.append(
            f"- `v{ov}` — [download]({entry.get('apk', version_apk_url_for(ov))}) · [notes]({entry.get('release_notes', notes_path_for(ov))})"
        )
    previous_parts.append("### Older releases\n\n" + "\n".join(older_lines))

if not previous_parts:
    previous_parts.append("_No previous builds published yet._")

previous_builds_block = "\n\n".join(previous_parts)

previous_notes_lines = []
if compatible_previous:
    previous_notes_lines.append(
        f"- Compatible previous (`{compatible_previous}`): `{notes_path_for(compatible_previous)}`"
    )
previous_notes_lines.append("- Older notes remain under each version folder in `releases/`")
previous_notes_block = "\n".join(previous_notes_lines)

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
    r"<!-- PREVIOUS_BUILDS_START -->.*?<!-- PREVIOUS_BUILDS_END -->",
    "<!-- PREVIOUS_BUILDS_START -->\\n" + previous_builds_block + "\\n<!-- PREVIOUS_BUILDS_END -->",
    content,
    flags=re.S,
)

if "<!-- PREVIOUS_NOTES_START -->" in content:
    content = re.sub(
        r"<!-- PREVIOUS_NOTES_START -->.*?<!-- PREVIOUS_NOTES_END -->",
        "<!-- PREVIOUS_NOTES_START -->\\n" + previous_notes_block + "\\n<!-- PREVIOUS_NOTES_END -->",
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
