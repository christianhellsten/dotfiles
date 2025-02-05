#!/bin/bash
set -e

echo "Setting up brew..."

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

PACKAGES=(
    gpg
    yq
    jq
)

for package in "${PACKAGES[@]}"; do
    if ! command -v $package &> /dev/null; then
        brew install $package
    fi
done
