#!/usr/bin/env bash

set -eu -o pipefail

function main() {
	local -r available=$(mpstat | tail -n 1 | awk '{print $NF}')
	local -r used=$(python -c "print(100 - ${available})")
	echo "$(echo "${used}000" | cut -b 1-4)"%
}

main
