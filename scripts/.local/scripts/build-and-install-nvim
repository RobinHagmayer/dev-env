#!/usr/bin/env bash

set -euo pipefail

# Cache sudo credentials
sudo -v

die() {
    echo "Error: $*" >&2
    exit 1
}

build_and_install_nvim() {
    if [[ -f Makefile ]]; then
        echo "Cleaning previous builds ..."
        # Suppress errors with "|| true"
        make distclean > /dev/null 2>&1 || true
        echo "Finished Cleaning previous builds!"
    fi

    echo "Compiling ..."
    if ! make CMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1; then
        die "Compilation failed."
    fi
    echo "Finished compiling!"

    pushd build > /dev/null 2>&1
    echo "Building package ..."
    if ! cpack -G DEB > /dev/null 2>&1; then
        die "Building package failed."
    fi
    echo "Finished building!"

    echo "Installing package..."
    if ! sudo dpkg -i nvim-linux-x86_64.deb > /dev/null 2>&1; then
        die "Installation failed."
    fi
    echo "Successfully installed 'nvim'!"
    popd > /dev/null 2>&1
}

build_and_install_nvim
