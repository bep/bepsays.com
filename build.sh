#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds a Hugo site hosted on a Cloudflare Worker.
#
# The Cloudflare Worker automatically installs Node.js dependencies.
#------------------------------------------------------------------------------

# Exit on error, undefined variables, or pipe failures
set -euo pipefail

build_temp_dir=""

# Perform cleanup
cleanup() {
	if [[ -n "${build_temp_dir:-}" && -d "${build_temp_dir}" ]]; then
		rm -rf "${build_temp_dir}"
	fi
}

# Register the cleanup trap
trap cleanup EXIT SIGINT SIGTERM

main() {
	# Define tool versions
	HUGO_VERSION=0.164.0
	GO_VERSION=1.26.4

	# Set the build timezone
	export TZ=Europe/Oslo

	# Set the build cache directory
	export HUGO_CACHEDIR="${PWD}/.cache/hugo_cache"

	# Create and move into a temporary directory for downloads
	build_temp_dir=$(mktemp -d)
	pushd "${build_temp_dir}" >/dev/null

	# Create the local tools directory
	mkdir -p "${HOME}/.local"

	# Install Go
	echo "Installing Go ${GO_VERSION}..."
	curl -sLJO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
	tar -C "${HOME}/.local" -xf "go${GO_VERSION}.linux-amd64.tar.gz"
	export PATH="${HOME}/.local/go/bin:${PATH}"

	# Install Hugo
	echo "Installing Hugo ${HUGO_VERSION}..."
	curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
	mkdir -p "${HOME}/.local/hugo"
	tar -C "${HOME}/.local/hugo" -xf "hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
	export PATH="${HOME}/.local/hugo:${PATH}"

	# Return to the project root
	popd >/dev/null

	# Verify installations
	echo "Verifying installations..."
	echo Go: "$(go version)"
	echo Hugo: "$(hugo version)"
	echo Node.js: "$(node --version)"

	# Configure Git
	echo "Configuring Git..."
	git config core.quotepath false
	if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
		git fetch --unshallow
	fi

	# Build the site
	echo "Building the site..."
	hugo build --gc --minify
}

main "$@"
