#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OVERRIDE_FILE="modules/overrides/claude-code/default.nix"
LOCKFILE="modules/overrides/claude-code/package-lock.json"

VERSION=$(npm view @anthropic-ai/claude-code version)
echo "Updating claude-code to version ${VERSION}..."

echo "1. Generating package-lock.json..."
TMPDIR=$(mktemp -d)
(
	cd "${TMPDIR}"
	npm pack "@anthropic-ai/claude-code@${VERSION}" --quiet 2>/dev/null
	tar xzf *.tgz
	cd package
	npm install --package-lock-only --ignore-scripts 2>/dev/null
	cp package-lock.json "${REPO_ROOT}/${LOCKFILE}"
)
rm -rf "${TMPDIR}"

echo "2. Updating src hash..."
SRC_HASH=$(nix hash convert --to sri --hash-algo sha256 \
	"$(nix-prefetch-url --unpack --type sha256 \
		"https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${VERSION}.tgz" 2>/dev/null)")

echo "3. Updating version and hashes in ${OVERRIDE_FILE}..."
sed -i '' "s|overrideVersion = \"[^\"]*\"|overrideVersion = \"${VERSION}\"|" "${OVERRIDE_FILE}"
sed -i '' "/src = fetchzip/,/};/{s|hash = \"[^\"]*\"|hash = \"${SRC_HASH}\"|;}" "${OVERRIDE_FILE}"

echo "4. Computing npmDepsHash..."
sed -i '' 's|npmDepsHash = "sha256-[^"]*"|npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="|' "${OVERRIDE_FILE}"
git add "${LOCKFILE}"
NPM_DEPS_HASH=$( (nix build ".#claude-code-override" 2>&1 || true) |
	sed -nE 's/.*got: *(sha256-[A-Za-z0-9+/=-]+).*/\1/p' | head -1)
sed -i '' "s|npmDepsHash = \"sha256-[^\"]*\"|npmDepsHash = \"${NPM_DEPS_HASH}\"|" "${OVERRIDE_FILE}"

echo "claude-code has been updated to version ${VERSION}"
