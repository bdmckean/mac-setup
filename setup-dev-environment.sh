#!/bin/bash

# Mac Dev Environment Setup Script
# This script installs development tools if they are not already installed

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a Homebrew cask is installed
cask_installed() {
    brew list --cask "$1" >/dev/null 2>&1
}

# Function to check if a Homebrew formula is installed
formula_installed() {
    brew list "$1" >/dev/null 2>&1
}

# Function to check if a macOS app bundle exists
app_bundle_exists() {
    [[ -d "/Applications/$1.app" ]]
}

# Ensure Ruby user gem bin is on PATH
ensure_user_gem_path() {
    local user_gem_bin
    user_gem_bin="$(ruby -e 'puts Gem.user_dir')/bin"
    if [[ ":$PATH:" != *":$user_gem_bin:"* ]]; then
        export PATH="$user_gem_bin:$PATH"
        print_warning "Added user gem bin to PATH for this session: $user_gem_bin"
        print_info "Consider adding it to your shell profile if needed."
    fi
}

# Ensure .zshrc has a managed, idempotent block
ensure_zshrc_block() {
    local zshrc="$HOME/.zshrc"
    local block_start="# >>> mac-setup >>>"
    local block_end="# <<< mac-setup <<<"
    local block_content
    block_content="$(cat <<'EOF'
# >>> mac-setup >>>
# tmux
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux ls'

# NVIM
alias vim='nvim'
alias vi='nvim'

# General
alias h='history'

# Exports
export TERM=xterm-256color
# <<< mac-setup <<<
EOF
)"

    if [[ -f "$zshrc" ]]; then
        if grep -q "$block_start" "$zshrc"; then
            /usr/bin/python3 - <<PY
from pathlib import Path
zshrc = Path("$HOME/.zshrc")
text = zshrc.read_text()
start = "$block_start"
end = "$block_end"
replacement = """$block_content"""
import re
pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.S)
text, count = pattern.subn(replacement.strip(), text)
if count == 0:
    text = text.rstrip() + "\\n\\n" + replacement.strip() + "\\n"
zshrc.write_text(text)
PY
        else
            printf "\n%s\n" "$block_content" >> "$zshrc"
        fi
    else
        printf "%s\n" "$block_content" > "$zshrc"
    fi
}

# Track install status
ITERM2_STATUS="missing"
TMUX_STATUS="missing"
TPM_STATUS="missing"
TMUX_CONF_STATUS="missing"
TMUXINATOR_STATUS="missing"
WORKMUX_STATUS="missing"
GIT_STATUS="missing"
CURSOR_STATUS="missing"
CLAUDE_STATUS="missing"
DOCKER_STATUS="missing"
NODE_STATUS="missing"
PYTHON_39_STATUS="missing"
PYTHON_311_STATUS="missing"
PYTHON_313_STATUS="missing"
POETRY_STATUS="missing"
UV_STATUS="missing"
OLLAMA_STATUS="missing"
FFMPEG_STATUS="missing"
NEOVIM_STATUS="missing"

# Check if Homebrew is installed
if ! command_exists brew; then
    print_warning "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH if needed (for Apple Silicon Macs)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        # Add to shell profile
        if [[ -f "$HOME/.zshrc" ]]; then
            echo 'export PATH="/opt/homebrew/bin:$PATH"' >> "$HOME/.zshrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            echo 'export PATH="/opt/homebrew/bin:$PATH"' >> "$HOME/.bash_profile"
        fi
    fi
else
    print_info "Homebrew is already installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# Install iTerm2 (Homebrew Cask)
if cask_installed iterm2 || app_bundle_exists "iTerm" || app_bundle_exists "iTerm2"; then
    print_info "iTerm2 is already installed"
    ITERM2_STATUS="ok"
else
    print_info "Installing iTerm2..."
    if brew install --cask iterm2; then
        ITERM2_STATUS="ok"
    else
        print_warning "Failed to install iTerm2 via Homebrew. It may already exist in /Applications."
    fi
fi

# Install Docker Desktop (includes Docker Compose)
if cask_installed docker || app_bundle_exists "Docker"; then
    print_info "Docker Desktop is already installed"
    DOCKER_STATUS="ok"
else
    print_info "Installing Docker Desktop..."
    if brew install --cask docker; then
        DOCKER_STATUS="ok"
    else
        print_warning "Failed to install Docker Desktop via Homebrew."
    fi
fi

# Install tmux
if ! command_exists tmux; then
    print_info "Installing tmux..."
    if brew install tmux; then
        TMUX_STATUS="ok"
    fi
else
    print_info "tmux is already installed ($(tmux -V))"
    TMUX_STATUS="ok"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    print_info "TPM (Tmux Plugin Manager) is already installed"
    TPM_STATUS="ok"
else
    print_info "Installing TPM (Tmux Plugin Manager)..."
    if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        print_info "TPM installed successfully"
        TPM_STATUS="ok"
    else
        print_warning "Failed to install TPM"
    fi
fi

# Configure tmux (~/.tmux.conf)
print_info "Configuring tmux (~/.tmux.conf)..."
TMUX_CONF="$HOME/.tmux.conf"
TMUX_CONF_CONTENT='unbind-key C-b
set -g prefix C-a
bind-key C-a send-prefix

bind r source ~/.tmux.conf \; display-message "Reloaded!"
set -g  base-index 1
set -g  renumber-windows on

set -gq allow-passthrough on

# List of plugins
set -g @plugin '\''tmux-plugins/tpm'\''
set -g @plugin '\''tmux-plugins/tmux-sensible'\''

set -g @plugin '\''egel/tmux-gruvbox'\''


set -g renumber-windows on   # renumber all windows when any window is closed
set -g history-limit 1000000 # increase history size (from 2,000)
set -g default-terminal "screen-256color"

set -g @plugin '\''tmux-plugins/tmux-resurrect'\''
set -g @plugin '\''tmux-plugins/tmux-continuum'\''

# Split winowes
bind | split-window -h
bind - split-window -v

set -g @continuum-restore '\''on'\''

setw -g mode-keys vi
set -g history-limit 1000000 

# Other examples:
# set -g @plugin '\''github_username/plugin_name'\''
# set -g @plugin '\''github_username/plugin_name#branch'\''
# set -g @plugin '\''git@github.com:user/plugin'\''
# set -g @plugin '\''git@bitbucket.com:user/plugin'\''

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '\''~/.tmux/plugins/tpm/tpm'\'''

# Check if config needs updating
if [[ -f "$TMUX_CONF" ]]; then
    EXISTING_CONF=$(cat "$TMUX_CONF")
    if [[ "$EXISTING_CONF" == "$TMUX_CONF_CONTENT" ]]; then
        print_info "tmux config is already up to date"
        TMUX_CONF_STATUS="ok"
    else
        print_info "Updating tmux config..."
        echo "$TMUX_CONF_CONTENT" > "$TMUX_CONF"
        TMUX_CONF_STATUS="ok"
    fi
else
    print_info "Creating tmux config..."
    echo "$TMUX_CONF_CONTENT" > "$TMUX_CONF"
    TMUX_CONF_STATUS="ok"
fi

# Install TPM plugins (if TPM is installed)
if [[ -d "$TPM_DIR" && "$TMUX_CONF_STATUS" == "ok" ]]; then
    print_info "Installing tmux plugins via TPM..."
    # TPM install script runs in background, we invoke it directly
    "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 || true
    print_info "tmux plugins installed (or already present)"
fi

# Install Node.js (includes npm)
if command_exists node; then
    print_info "Node.js is already installed ($(node --version))"
    NODE_STATUS="ok"
else
    print_info "Installing Node.js..."
    if brew install node; then
        NODE_STATUS="ok"
    fi
fi

# Install Python versions needed by sibling repos
if command_exists python3.9; then
    print_info "Python 3.9 is already installed ($(python3.9 --version))"
    PYTHON_39_STATUS="ok"
else
    print_info "Installing Python 3.9..."
    if brew install python@3.9; then
        PYTHON_39_STATUS="ok"
    fi
fi

if command_exists python3.11; then
    print_info "Python 3.11 is already installed ($(python3.11 --version))"
    PYTHON_311_STATUS="ok"
else
    print_info "Installing Python 3.11..."
    if brew install python@3.11; then
        PYTHON_311_STATUS="ok"
    fi
fi

if command_exists python3.13; then
    print_info "Python 3.13 is already installed ($(python3.13 --version))"
    PYTHON_313_STATUS="ok"
else
    print_info "Installing Python 3.13..."
    if brew install python@3.13; then
        PYTHON_313_STATUS="ok"
    fi
fi

# Install Poetry
if command_exists poetry; then
    print_info "Poetry is already installed ($(poetry --version))"
    POETRY_STATUS="ok"
else
    print_info "Installing Poetry..."
    if brew install poetry; then
        POETRY_STATUS="ok"
    fi
fi

# Install uv (optional but referenced in repos)
if command_exists uv; then
    print_info "uv is already installed ($(uv --version 2>/dev/null || echo 'installed'))"
    UV_STATUS="ok"
else
    print_info "Installing uv..."
    if brew install uv; then
        UV_STATUS="ok"
    fi
fi

# Install Ollama
if command_exists ollama; then
    print_info "Ollama is already installed ($(ollama --version 2>/dev/null || echo 'installed'))"
    OLLAMA_STATUS="ok"
else
    print_info "Installing Ollama..."
    if brew install ollama; then
        OLLAMA_STATUS="ok"
    fi
fi

# Install ffmpeg
if command_exists ffmpeg; then
    print_info "ffmpeg is already installed ($(ffmpeg -version | head -n 1))"
    FFMPEG_STATUS="ok"
else
    print_info "Installing ffmpeg..."
    if brew install ffmpeg; then
        FFMPEG_STATUS="ok"
    fi
fi

# Install Neovim
if command_exists nvim; then
    print_info "Neovim is already installed ($(nvim --version | head -n 1))"
    NEOVIM_STATUS="ok"
else
    print_info "Installing Neovim..."
    if brew install neovim; then
        NEOVIM_STATUS="ok"
    fi
fi

# Ensure .zshrc updates are applied
print_info "Updating ~/.zshrc with mac-setup defaults..."
ensure_zshrc_block

# Install tmuxinator
if ! command_exists tmuxinator; then
    print_info "Installing tmuxinator..."
    if brew install tmuxinator; then
        print_info "tmuxinator installed via Homebrew"
        TMUXINATOR_STATUS="ok"
    else
        print_warning "Homebrew install failed. Trying Ruby gem (user install)..."
        if gem install --user-install tmuxinator; then
            ensure_user_gem_path
            print_info "tmuxinator installed via Ruby gem (user)"
            TMUXINATOR_STATUS="ok"
        else
            print_warning "tmuxinator installation failed. You may need to install it manually."
        fi
    fi
else
    print_info "tmuxinator is already installed ($(tmuxinator version 2>/dev/null || echo 'installed'))"
    TMUXINATOR_STATUS="ok"
fi

# Install workmux
# Note: workmux might need to be installed via gem or as a tmux plugin
if ! command_exists workmux; then
    print_info "Installing workmux..."
    print_info "Tapping raine/workmux..."
    brew tap raine/workmux >/dev/null 2>&1 || true
    if brew install workmux; then
        print_info "workmux installed via Homebrew"
        WORKMUX_STATUS="ok"
    else
        print_warning "workmux installation failed via Homebrew."
        print_info "Confirm the formula exists or use a tap that provides it."
    fi
else
    print_info "workmux is already installed"
    WORKMUX_STATUS="ok"
fi

# Install git
if ! command_exists git; then
    print_info "Installing git..."
    if brew install git; then
        GIT_STATUS="ok"
    fi
else
    print_info "git is already installed ($(git --version))"
    GIT_STATUS="ok"
fi

# Install Cursor (Homebrew Cask)
if cask_installed cursor || app_bundle_exists "Cursor"; then
    print_info "Cursor is already installed"
    CURSOR_STATUS="ok"
else
    print_info "Installing Cursor..."
    if brew install --cask cursor; then
        CURSOR_STATUS="ok"
    else
        print_warning "Failed to install Cursor via Homebrew. It may already exist in /Applications."
    fi
fi

# Install Claude CLI
# Note: Claude might refer to Anthropic's Claude CLI tool
# Checking if it's available via Homebrew or npm
if ! command_exists claude; then
    print_info "Installing Claude CLI..."
    # Try npm install first (common for Claude CLI tools)
    if command_exists npm; then
        if npm install -g @anthropic-ai/claude-cli 2>/dev/null; then
            print_info "Claude CLI installed via npm"
            CLAUDE_STATUS="ok"
        else
            # Try alternative installation methods
            print_warning "Claude CLI installation via npm failed. Checking other methods..."
            # If there's a Homebrew formula, try that
            if brew search claude 2>/dev/null | grep -q claude; then
                if brew install claude 2>/dev/null; then
                    CLAUDE_STATUS="ok"
                else
                    print_warning "Could not install Claude via Homebrew"
                fi
            else
                print_warning "Claude CLI not found in standard repositories."
                print_info "You may need to install it manually. Check: https://github.com/anthropics/claude-cli"
            fi
        fi
    else
        print_warning "npm is not installed. Installing Node.js first..."
        if brew install node; then
            if npm install -g @anthropic-ai/claude-cli 2>/dev/null; then
                CLAUDE_STATUS="ok"
            else
                print_warning "Claude CLI installation failed"
            fi
        fi
    fi
else
    print_info "Claude CLI is already installed ($(claude --version 2>/dev/null || echo 'installed'))"
    CLAUDE_STATUS="ok"
fi

print_info ""
print_info "=========================================="
print_info "Dev environment setup complete!"
print_info "=========================================="
print_info ""
print_info "Installed/Verified tools:"
print_info "  - iTerm2: ${ITERM2_STATUS}"
print_info "  - Docker Desktop: ${DOCKER_STATUS}"
print_info "  - tmux: ${TMUX_STATUS}"
print_info "  - TPM (tmux plugins): ${TPM_STATUS}"
print_info "  - tmux config: ${TMUX_CONF_STATUS}"
print_info "  - Node.js: ${NODE_STATUS}"
print_info "  - Python 3.9: ${PYTHON_39_STATUS}"
print_info "  - Python 3.11: ${PYTHON_311_STATUS}"
print_info "  - Python 3.13: ${PYTHON_313_STATUS}"
print_info "  - Poetry: ${POETRY_STATUS}"
print_info "  - uv: ${UV_STATUS}"
print_info "  - Ollama: ${OLLAMA_STATUS}"
print_info "  - ffmpeg: ${FFMPEG_STATUS}"
print_info "  - Neovim: ${NEOVIM_STATUS}"
print_info "  - tmuxinator: ${TMUXINATOR_STATUS}"
print_info "  - workmux: ${WORKMUX_STATUS}"
print_info "  - git: ${GIT_STATUS}"
print_info "  - Cursor: ${CURSOR_STATUS}"
print_info "  - Claude CLI: ${CLAUDE_STATUS}"
print_info ""
print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect."
