# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains macOS development environment setup scripts for configuring a new Mac with essential development tools and iTerm2 profile automation. It's designed to quickly bootstrap a development machine with a consistent configuration across multiple repositories.

## Key Scripts

### `setup-dev-environment.sh`
Main setup script that installs and configures development tools via Homebrew.

**Usage:**
```bash
./setup-dev-environment.sh
```

**What it does:**
- Installs Homebrew if missing
- Installs development applications: iTerm2, Docker Desktop, Cursor, Neovim
- Installs terminal tools: tmux, tmuxinator, workmux, git
- Installs Python versions: 3.9, 3.11, 3.13
- Installs Python tools: poetry, uv
- Installs Node.js, Ollama, ffmpeg
- Configures tmux with TPM (Tmux Plugin Manager) and custom config
- Updates ~/.zshrc with mac-setup managed block containing aliases and exports
- Attempts to install Claude CLI via npm

**Important behaviors:**
- Idempotent: safe to run multiple times, checks before installing
- Updates Homebrew before installing packages
- Creates/updates ~/.tmux.conf with predefined configuration
- Manages ~/.zshrc with delimited block (between `# >>> mac-setup >>>` and `# <<< mac-setup <<<`)
- Uses colored output (GREEN for info, YELLOW for warnings, RED for errors)
- Tracks installation status for all tools and reports at the end

### `setup-iterm-profiles.sh`
Creates iTerm2 dynamic profiles for automatic color-coded terminal switching per repository.

**Usage:**
```bash
./setup-iterm-profiles.sh
```

**What it does:**
- Installs JetBrains Mono, Fira Code, and Cascadia Code fonts
- Creates dynamic profiles in `~/Library/Application Support/iTerm2/DynamicProfiles/RepoProfiles.json`
- Maps 8 repositories to distinct color schemes:
  - mac-setup → Solarized Dark
  - transcript_extraction_dev → Dracula
  - budget_claude → Gruvbox Dark
  - budget_cursor → One Dark
  - budget_tracing → Nord
  - budget → Monokai
  - agentic_ai_learning → Tomorrow Night
  - intro-to-langsmith → Snazzy
- Sets automatic profile switching rules based on working directory path matching `~/work/repo/<repo-name>*`
- Configures all profiles with JetBrains Mono 13pt font and 100,000 line scrollback buffer
- Updates existing profiles (Default, CaryatidA, seafoam) to 100,000 scrollback lines

**Technical details:**
- Uses zsh associative arrays for repo-to-color mappings
- Converts hex colors to RGB components (0-1 range) for iTerm2 format
- Creates JSON with automatic profile switching rules using path pattern matching

### `rebuild-profiles.py`
Python script that rebuilds iTerm2 profiles from .itermcolors files with full color schemes.

**Usage:**
```bash
python3 rebuild-profiles.py
```

**Prerequisites:**
- Requires iTerm2 color schemes downloaded to `~/Downloads/iTerm2-Color-Schemes-master/schemes/`

**What it does:**
- Parses .itermcolors plist files to extract full color definitions
- Creates complete profiles with all 16 ANSI colors plus background, foreground, cursor, selection colors
- Uses alternative color scheme mappings compared to setup-iterm-profiles.sh

### `uninstall-iterm-profiles.sh`
Removes the dynamic iTerm2 profiles created by setup-iterm-profiles.sh.

**Usage:**
```bash
./uninstall-iterm-profiles.sh
```

**What it does:**
- Prompts for confirmation before removing
- Deletes `~/Library/Application Support/iTerm2/DynamicProfiles/RepoProfiles.json`
- Preserves existing profiles and their scrollback settings

## Repository Structure

This is a flat repository with shell scripts and one Python utility. All scripts are executable and designed to be run from the repository root.

**Directory expectations:**
- Repository base: `~/work/repo/`
- This repo: `~/work/repo/mac-setup/`
- Sibling repos: `~/work/repo/transcript_extraction_dev/`, `~/work/repo/budget_claude/`, etc.

## Configuration Files Modified

**~/.zshrc**
- Managed block between `# >>> mac-setup >>>` and `# <<< mac-setup <<<`
- Contains tmux aliases (ta, tn, tl), nvim aliases (vim, vi), and TERM export
- Uses Python script for idempotent block replacement

**~/.tmux.conf**
- Complete tmux configuration with Ctrl-A prefix
- Includes TPM with plugins: tmux-sensible, tmux-gruvbox, tmux-resurrect, tmux-continuum
- Configured for 1,000,000 line history and 256-color terminal support
- Custom key bindings: `|` for horizontal split, `-` for vertical split
- Vi-mode key bindings enabled

**iTerm2 Dynamic Profiles**
- Location: `~/Library/Application Support/iTerm2/DynamicProfiles/RepoProfiles.json`
- Contains automatic profile switching rules per repository
- Requires iTerm2 restart or manual refresh in Settings → Profiles

## Development Context

**Target environment:**
- macOS (Darwin)
- zsh shell
- Homebrew package manager
- iTerm2 terminal emulator

**Sibling repositories:**
The scripts reference and configure profiles for multiple sibling repositories in `~/work/repo/`:
- transcript_extraction_dev
- budget_claude, budget_cursor, budget_tracing, budget (related budget projects)
- agentic_ai_learning
- intro-to-langsmith

These repositories likely use various Python versions (3.9, 3.11, 3.13), Poetry for dependency management, and may involve AI/ML workflows (references to Claude CLI, Ollama, LangSmith).

## Important Implementation Notes

**When modifying setup-dev-environment.sh:**
- Maintain idempotency: always check if tools are already installed
- Use the helper functions: `command_exists()`, `cask_installed()`, `formula_installed()`, `app_bundle_exists()`
- Track installation status with STATUS variables
- Report all installation statuses at the end

**When modifying iTerm2 profile scripts:**
- iTerm2 dynamic profiles use JSON format with specific key names
- Color values must be in 0-1 RGB range, not 0-255
- Automatic profile switching uses "Pattern" and "Type" in rules
- Profile GUIDs should be unique (use uuidgen)

**When modifying zshrc management:**
- Always use the delimited block pattern to avoid duplicating configuration
- Use Python for reliable regex-based block replacement
- Preserve user's existing .zshrc content outside the managed block
