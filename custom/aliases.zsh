# =============================================================================
# Core System Utilities
# Enhanced versions of basic commands
# =============================================================================

# Enhanced directory listing with human-readable sizes
alias ls="ls -lah"

# Set neovim as the default editor
alias vim='nvim'
alias vi='nvim'

# Use Python 3 by default
alias python="python3"

# Enhanced recursive grep
alias rgrep="grep -r"

# Improved less display with raw control characters
alias less='less -r'

# =============================================================================
# Network Tools
# Commands for network operations and diagnostics
# =============================================================================

# Get external IP address using OpenDNS
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

# Get both external and local IP addresses
alias ipaddr='wanip && ipconfig getifaddr en1'

# Show listening TCP ports (OSX alternative to netstat)
alias netstat-listen='lsof -iTCP -sTCP:LISTEN'

# =============================================================================
# Search Tools
# Enhanced search capabilities and utilities
# =============================================================================

# Configure ack with custom pager settings
alias ack='ACK_PAGER_COLOR="less -x4SRFX" /usr/local/bin/ack'

# Silver searcher with pager
alias ag='ag --pager "less -r"'

# Global search and replace utility
alias search-replace='find "${PATH}" -type f -name "${NAME}" -print0 | xargs -0 sed -i "" -e "s/${SEARCH}/${REPLACE}/g"'

# =============================================================================
# Database Management
# PostgreSQL service and query management
# =============================================================================

# Start PostgreSQL server in background
alias start-postgres='nohup /opt/homebrew/opt/postgresql@12/bin/postgres -D /opt/homebrew/var/postgresql@12 > /tmp/postgres.log &'

# Stop PostgreSQL server quickly
alias stop-postgres='pg_ctl -D /opt/homebrew/opt/postgresql@12/bin/postgres stop -s -m fast'

# Run a Postgres query function
# Usage: pquery database_name "SELECT * FROM table"
pquery() {
  local dbname=$1
  shift
  local query="$@"
  psql -d "$dbname" -c "$query"
}

# =============================================================================
# Ruby/Rails Development
# Rails and Bundle execution shortcuts
# =============================================================================

alias rt="bundle exec rails test"
alias rs="bundle exec rspec"
alias be="bundle exec"

# =============================================================================
# Docker Management
# Container and image cleanup utilities
# =============================================================================

# Clean up unused Docker resources
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

# Podman alternatives (uncomment if using Podman)
#alias docker="podman"
#alias docker-compose="podman-compose"

# =============================================================================
# Git Workflow
# Version control shortcuts
# =============================================================================

# Status and diff
alias gs='git status -sb'
alias gd='git diff'

# Logging
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

# Branch operations
alias gb='git branch'
alias gcb='git copy-branch-name'
alias gco='git checkout'

# Commit operations
alias gc='git commit'
alias gac='git add . && git commit'

# Remote operations
alias gp='git push'
alias gpr='git pull --prune'

# =============================================================================
# Legacy/Disabled Commands
# Commented out commands kept for reference
# =============================================================================

# iOS Simulator launcher
#alias ios-simulator='open /Applications/Xcode.app/Contents/Developer/Applications/iOS\ Simulator.app'
