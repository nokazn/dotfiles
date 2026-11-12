#!/usr/bin/env bash
set -euo pipefail

NODE_VERSION=26

fnm install "${NODE_VERSION}"
fnm default "${NODE_VERSION}"
DEFAULT_NODE_VERSION="$(fnm exec --using=default node --version)"

# fnm has no built-in pruning, so remove every installed version except the default
fnm list |
	awk -v default_version="${DEFAULT_NODE_VERSION}" '$2 ~ /^v/ && $2 != default_version { print $2 }' |
	xargs -I {} fnm uninstall {}

mise install
mise prune --yes
