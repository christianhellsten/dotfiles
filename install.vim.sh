#!/bin/bash
set -e

echo "Setting up Vim configuration..."

# Remove existing .vim directory if it's a symlink
[ -L "$HOME/.vim" ] && rm "$HOME/.vim"

# Link plugin directory
ln -sf "$(pwd)/vim/plugin" "$HOME/.vim/plugin"

# Link vimrc
ln -sf "$(pwd)/vim/vimrc" "$HOME/.vimrc"

# Install vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install vim plugins
echo "Installing vim plugins..."
vim +PlugInstall +qall --not-a-term
