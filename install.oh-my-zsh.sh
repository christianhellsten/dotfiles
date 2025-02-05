#!/bin/bash
set -e

export ZSH="$HOME/.dotfiles"
DEPENDENCIES=(
    autojump
    zsh-syntax-highlighting
    zsh-autosuggestions
)

echo "Installing Oh My Zsh..."
if [ -d "$ZSH" ]; then
    echo "Oh My Zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ln -sf "$(pwd)/zsh/zshrc" "$HOME/.zshrc"

rm -rf "$ZSH/custom"
ln -sf "$(pwd)/oh-my-zsh/custom" "$ZSH/custom"

for package in "${DEPENDENCIES[@]}"; do
    if ! command -v $package &> /dev/null; then
        brew install $package
    fi
done
