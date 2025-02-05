#!/bin/bash
set -e

echo "Starting installation..."

# Run all install scripts
for script in install.*.sh; do
    if [ -f "$script" ]; then
        echo "Running $script..."
        bash "$script"
    fi
done

echo "Installation complete!"
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
