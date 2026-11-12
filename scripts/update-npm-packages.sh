#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC2016 # `${...}` is Nix interpolation, not shell expansion
readarray -t PACKAGES < <(
	nix eval --impure --raw --expr '
		let
			flake = builtins.getFlake (toString ./.);
			pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
		in
		builtins.concatStringsSep "\n" (builtins.attrNames (import ./modules/node/npm.nix { inherit pkgs; }))
	'
)

for package in "${@:-${PACKAGES[@]}}"; do
	echo "Updating ${package}..."
	nix run nixpkgs#nix-update -- --flake --format "${package}"
	nix build --no-link ".#${package}"
done
