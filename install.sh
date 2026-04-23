#!/usr/bin/env bash
# Installs skills into ~/.claude/skills/ and ~/.codex/skills/
# Usage: curl -fsSL https://raw.githubusercontent.com/WinnerWang971119/my_skills/main/install.sh | bash
# Override repo via env: REPO=user/repo BRANCH=main bash install.sh

set -euo pipefail

REPO="${REPO:-WinnerWang971119/my_skills}"
BRANCH="${BRANCH:-main}"
CLAUDE_DIR="${HOME}/.claude/skills"
CODEX_DIR="${HOME}/.codex/skills"

echo "==> Installing skills from ${REPO}@${BRANCH}"
echo "    Claude Code -> ${CLAUDE_DIR}"
echo "    Codex       -> ${CODEX_DIR}"

mkdir -p "${CLAUDE_DIR}" "${CODEX_DIR}"

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "==> Downloading tarball..."
curl -fsSL "https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}" \
  | tar -xz -C "${TMP}"

REPO_NAME="${REPO##*/}"
SRC="${TMP}/${REPO_NAME}-${BRANCH//\//-}"
[ -d "${SRC}" ] || SRC="$(find "${TMP}" -maxdepth 1 -mindepth 1 -type d | sort | head -n 1)"

count=0
for dir in "${SRC}"/*/; do
  [ -d "${dir}" ] || continue
  name="$(basename "${dir}")"
  case "${name}" in
    .*|node_modules) continue ;;
  esac
  [ -f "${dir}SKILL.md" ] || continue

  echo "  - ${name}"
  rm -rf "${CLAUDE_DIR}/${name}" "${CODEX_DIR}/${name}"
  cp -R "${dir}" "${CLAUDE_DIR}/${name}"
  cp -R "${dir}" "${CODEX_DIR}/${name}"
  count=$((count + 1))
done

echo "==> Installed ${count} skill(s)."
