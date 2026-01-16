# Set up a new mac
This starts with some work in progress on an existing mac
Will Add notes as I go


## Quick Start: Dev Environment Setup

Run the automated setup script to install all development tools:

```bash
./setup-dev-environment.sh
```

This script will install (if not already installed):
- **iTerm2** - Terminal emulator
- **tmux** - Terminal multiplexer
- **tmuxinator** - tmux session manager
- **workmux** - Workspace manager for tmux
- **git** - Version control
- **Cursor** - AI-powered code editor
- **Claude CLI** - Anthropic Claude command-line tool

The script automatically:
- Checks for and installs Homebrew if needed
- Verifies each tool before installing
- Updates Homebrew before installing packages
- Provides colored output for easy reading

## iTerm2 Color-Coded Profiles

Set up automatic profile switching with different color schemes for each repository:

```bash
./setup-iterm-profiles.sh
```

This script creates iTerm2 profiles that automatically switch based on your current directory. Each repo gets a distinct color scheme:

- **mac-setup** → Solarized Dark
- **transcript_extraction_dev** → Dracula
- **budget_claude** → Gruvbox Dark
- **budget_cursor** → One Dark
- **budget_tracing** → Nord
- **budget** → Monokai
- **agentic_ai_learning** → Tomorrow Night
- **intro-to-langsmith** → Snazzy

### Features:
- **Installs development fonts**: JetBrains Mono (primary), Fira Code, and Cascadia Code
- **Automatic profile switching** when you `cd` into each repo
- **JetBrains Mono 13pt font** for all profiles (excellent readability and ligatures)
- **100,000 line scrollback** buffer (~100-200 MB per tab)
- **Visual bell** enabled
- **Bold, bright bold, and italic** font styling
- Updates your existing profiles (Default, CaryatidA, seafoam) to use 100k scrollback

After running the script, restart iTerm2 and the profiles will automatically activate when you `cd` into each repository.

### To uninstall:
```bash
./uninstall-iterm-profiles.sh
```

This removes the repo profiles but keeps your existing profiles intact.

## 1. Brew install

Reference:  https://brew.sh/

1. Download brew 
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

2. Add to path
a. check path `brew --prefix`
b. add to .bash_profile or .bash_rc `export PATH="/opt/homebrew/bin:$PATH"`


## 2. If you need node, npm you can install with brew
`brew install node`



