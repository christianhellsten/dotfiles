#!/bin/bash

# Exit on error
set -e

echo "Starting oh-my-zsh installation and configuration..."

# Check if oh-my-zsh is already installed
if [ -d "$HOME/.dotfiles" ]; then
    echo "oh-my-zsh is already installed"
else
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Create .dotfiles directory if it doesn't exist
echo "Setting up .dotfiles directory..."
mkdir -p "$HOME/.dotfiles/custom"

# Copy custom folder contents
echo "Copying oh-my-zsh custom folder contents..."
cp -r "custom/"* "$HOME/.dotfiles/custom/" 2>/dev/null || true

# Install required packages using Homebrew
echo "Installing required packages..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install autojump
if ! command -v autojump &> /dev/null; then
    echo "Installing autojump..."
    brew install autojump
fi

# Install zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..."
brew install zsh-syntax-highlighting

# Install zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
brew install zsh-autosuggestions

# Update .zshrc to include plugins
echo "Configuring plugins in .zshrc..."
PLUGINS_LINE="plugins=(git dotenv autojump ssh-agent gpg-agent)"

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    echo "Backed up existing .zshrc to .zshrc.backup"
fi

# Update plugins line in .zshrc
if grep -q "^plugins=(" "$HOME/.zshrc"; then
    sed -i.bak "s/^plugins=(.*/$PLUGINS_LINE/" "$HOME/.zshrc"
else
    echo "$PLUGINS_LINE" >> "$HOME/.zshrc"
fi

# Add source commands for brew-installed plugins
echo "Adding source commands for brew-installed plugins..."
AUTOSUGGESTIONS_SOURCE="source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_SOURCE="source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Add source commands if they don't exist
if ! grep -q "zsh-autosuggestions.zsh" "$HOME/.zshrc"; then
    echo "$AUTOSUGGESTIONS_SOURCE" >> "$HOME/.zshrc"
fi

if ! grep -q "zsh-syntax-highlighting.zsh" "$HOME/.zshrc"; then
    echo "$SYNTAX_HIGHLIGHTING_SOURCE" >> "$HOME/.zshrc"
fi

# Reload zsh configuration
echo "Installation complete!"
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
