# Plugin name: python-venv-auto
# Automatically activates/deactivates Python virtual environments when entering/leaving directories

autoload -U add-zsh-hook

_VENV_AUTO_OLD_PATH=""

_venv_auto_activate() {
  local venv_path=""
  local current_path="$PWD"

    # Search for common venv directory names
    local venv_dirs=(".venv" "venv" "env" ".env")

    for dir in "${venv_dirs[@]}"; do
      if [[ -f "$current_path/$dir/bin/activate" ]]; then
        venv_path="$current_path/$dir"
        break
      fi
    done

    # Deactivate if we've left a venv directory
    if [[ -n "$VIRTUAL_ENV" && "$current_path" != "$_VENV_AUTO_OLD_PATH"* ]]; then
      deactivate
    fi

    # Activate if we've found a new venv
    if [[ -n "$venv_path" && "$VIRTUAL_ENV" != "$venv_path" ]]; then
      echo "Activating virtual environment: $venv_path"
      source "$venv_path/bin/activate"
      _VENV_AUTO_OLD_PATH="$current_path"
    fi
  }

# Add hook to check directory changes
add-zsh-hook chpwd _venv_auto_activate

# Initialize for current directory
_venv_auto_activate
