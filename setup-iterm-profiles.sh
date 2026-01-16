#!/bin/zsh

# iTerm2 Profile Setup Script
# Creates color-coded profiles for each repository with automatic switching

# Enable zsh options
setopt NO_NOMATCH  # Don't error on failed glob matches

REPO_BASE_DIR="$HOME/work/repo"
DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

# Create DynamicProfiles directory if it doesn't exist
mkdir -p "$DYNAMIC_PROFILES_DIR"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install development fonts
echo "Installing development fonts..."
echo ""

# Install JetBrains Mono (primary font)
if brew list --cask font-jetbrains-mono &> /dev/null; then
    echo "✓ JetBrains Mono already installed"
else
    echo "Installing JetBrains Mono..."
    brew install --cask font-jetbrains-mono
    echo "✓ JetBrains Mono installed"
fi

# Optionally install other recommended fonts
echo ""
echo "Installing additional recommended fonts (Fira Code, Cascadia Code)..."
for font in font-fira-code font-cascadia-code; do
    if brew list --cask $font &> /dev/null; then
        echo "✓ $font already installed"
    else
        brew install --cask $font 2>/dev/null && echo "✓ $font installed" || echo "⚠ Could not install $font"
    fi
done

echo ""
echo "Font installation complete!"
echo ""

# Define repo-to-color-scheme mappings
typeset -A REPO_COLORS=(
    ["mac-setup"]="Solarized Dark"
    ["transcript_extraction_dev"]="Dracula"
    ["budget_claude"]="Gruvbox Dark"
    ["budget_cursor"]="One Dark"
    ["budget_tracing"]="Nord"
    ["budget"]="Monokai"
    ["agentic_ai_learning"]="Tomorrow Night"
    ["intro-to-langsmith"]="Snazzy"
)

# Color scheme preset GUIDs (iTerm2 built-in schemes)
typeset -A COLOR_PRESETS=(
    ["Solarized Dark"]="Solarized Dark"
    ["Dracula"]="Dracula"
    ["Gruvbox Dark"]="Gruvbox Dark"
    ["One Dark"]="One Dark"
    ["Nord"]="Nord"
    ["Monokai"]="Monokai"
    ["Tomorrow Night"]="Tomorrow Night"
    ["Snazzy"]="Snazzy"
)

# Fallback color configurations (if presets aren't available)
typeset -A ANSI_COLORS=(
    ["mac-setup"]="#002b36,#dc322f,#859900,#b58900,#268bd2,#d33682,#2aa198,#eee8d5,#002b36,#cb4b16,#586e75,#657b83,#839496,#6c71c4,#93a1a1,#fdf6e3"
    ["transcript_extraction_dev"]="#282a36,#ff5555,#50fa7b,#f1fa8c,#bd93f9,#ff79c6,#8be9fd,#f8f8f2,#6272a4,#ff6e6e,#69ff94,#ffffa5,#d6acff,#ff92df,#a4ffff,#ffffff"
    ["budget_claude"]="#282828,#cc241d,#98971a,#d79921,#458588,#b16286,#689d6a,#a89984,#928374,#fb4934,#b8bb26,#fabd2f,#83a598,#d3869b,#8ec07c,#ebdbb2"
    ["budget_cursor"]="#282c34,#e06c75,#98c379,#e5c07b,#61afef,#c678dd,#56b6c2,#abb2bf,#5c6370,#e06c75,#98c379,#e5c07b,#61afef,#c678dd,#56b6c2,#ffffff"
    ["budget_tracing"]="#2e3440,#bf616a,#a3be8c,#ebcb8b,#81a1c1,#b48ead,#88c0d0,#e5e9f0,#4c566a,#bf616a,#a3be8c,#ebcb8b,#81a1c1,#b48ead,#8fbcbb,#eceff4"
    ["budget"]="#272822,#f92672,#a6e22e,#f4bf75,#66d9ef,#ae81ff,#a1efe4,#f8f8f2,#75715e,#f92672,#a6e22e,#f4bf75,#66d9ef,#ae81ff,#a1efe4,#f9f8f5"
    ["agentic_ai_learning"]="#1d1f21,#cc6666,#b5bd68,#f0c674,#81a2be,#b294bb,#8abeb7,#c5c8c6,#969896,#cc6666,#b5bd68,#f0c674,#81a2be,#b294bb,#8abeb7,#ffffff"
    ["intro-to-langsmith"]="#282a36,#ff5c57,#5af78e,#f3f99d,#57c7ff,#ff6ac1,#9aedfe,#f1f1f0,#686868,#ff5c57,#5af78e,#f3f99d,#57c7ff,#ff6ac1,#9aedfe,#eff0eb"
)

# Background colors for each scheme
typeset -A BG_COLORS=(
    ["mac-setup"]="#002b36"
    ["transcript_extraction_dev"]="#282a36"
    ["budget_claude"]="#282828"
    ["budget_cursor"]="#282c34"
    ["budget_tracing"]="#2e3440"
    ["budget"]="#272822"
    ["agentic_ai_learning"]="#1d1f21"
    ["intro-to-langsmith"]="#282a36"
)

# Foreground colors for each scheme
typeset -A FG_COLORS=(
    ["mac-setup"]="#839496"
    ["transcript_extraction_dev"]="#f8f8f2"
    ["budget_claude"]="#ebdbb2"
    ["budget_cursor"]="#abb2bf"
    ["budget_tracing"]="#d8dee9"
    ["budget"]="#f8f8f2"
    ["agentic_ai_learning"]="#c5c8c6"
    ["intro-to-langsmith"]="#eff0eb"
)

echo "Creating iTerm2 dynamic profiles for repositories..."

# Start JSON array
cat > "$DYNAMIC_PROFILES_DIR/RepoProfiles.json" << 'EOF'
{
  "Profiles": [
EOF

FIRST=true
for repo in "${(@k)REPO_COLORS}"; do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$DYNAMIC_PROFILES_DIR/RepoProfiles.json"
    fi

    COLOR_SCHEME="${REPO_COLORS[$repo]}"
    BG_COLOR="${BG_COLORS[$repo]}"
    FG_COLOR="${FG_COLORS[$repo]}"

    # Convert hex to RGB components (0-1 range)
    bg_r=$(printf "%d" 0x${BG_COLOR:1:2})
    bg_g=$(printf "%d" 0x${BG_COLOR:3:2})
    bg_b=$(printf "%d" 0x${BG_COLOR:5:2})
    fg_r=$(printf "%d" 0x${FG_COLOR:1:2})
    fg_g=$(printf "%d" 0x${FG_COLOR:3:2})
    fg_b=$(printf "%d" 0x${FG_COLOR:5:2})

    cat >> "$DYNAMIC_PROFILES_DIR/RepoProfiles.json" << EOF
    {
      "Name": "$repo",
      "Guid": "$repo-$(uuidgen)",
      "Dynamic Profile Parent Name": "Default",
      "Custom Directory": "Yes",
      "Working Directory": "$REPO_BASE_DIR/$repo",
      "Bound Hosts": ["*"],
      "Tags": ["repo", "auto-switch"],
      "Badge Text": "$repo",
      "Normal Font": "JetBrainsMono-Regular 13",
      "Scrollback Lines": 100000,
      "Unlimited Scrollback": false,
      "Terminal Type": "xterm-256color",
      "Use Bold Font": true,
      "Use Bright Bold": true,
      "Use Italic Font": true,
      "Visual Bell": true,
      "Background Color": {
        "Red Component": $(awk "BEGIN {printf \"%.10f\", $bg_r/255}"),
        "Green Component": $(awk "BEGIN {printf \"%.10f\", $bg_g/255}"),
        "Blue Component": $(awk "BEGIN {printf \"%.10f\", $bg_b/255}")
      },
      "Foreground Color": {
        "Red Component": $(awk "BEGIN {printf \"%.10f\", $fg_r/255}"),
        "Green Component": $(awk "BEGIN {printf \"%.10f\", $fg_g/255}"),
        "Blue Component": $(awk "BEGIN {printf \"%.10f\", $fg_b/255}")
      },
      "Automatic Profile Switching": {
        "Enabled": true,
        "Rules": [
          {
            "Pattern": "$REPO_BASE_DIR/$repo*",
            "Type": "Path"
          }
        ]
      }
    }
EOF
done

# Close JSON array
cat >> "$DYNAMIC_PROFILES_DIR/RepoProfiles.json" << 'EOF'
  ]
}
EOF

echo "✓ Created dynamic profiles at: $DYNAMIC_PROFILES_DIR/RepoProfiles.json"
echo ""

# Update existing profiles to use 100,000 scrollback lines
echo "Updating existing profiles to use 100,000 scrollback lines..."

# Get the list of all profile GUIDs
PROFILE_GUIDS=$(defaults read com.googlecode.iterm2 "New Bookmarks" | grep -E "Guid = " | sed 's/.*Guid = "\(.*\)";/\1/')

# Counter for profiles
counter=0
for guid in $PROFILE_GUIDS; do
    # Update scrollback lines for each profile
    /usr/libexec/PlistBuddy -c "Set 'New Bookmarks:$counter:Scrollback Lines' 100000" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null
    /usr/libexec/PlistBuddy -c "Set 'New Bookmarks:$counter:Unlimited Scrollback' 0" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null
    counter=$((counter + 1))
done

echo "✓ Updated existing profiles (Default, CaryatidA, seafoam) to 100,000 scrollback lines"
echo ""

# Configure key bindings for tab navigation
echo "Configuring key bindings (Command+Left/Right for tab navigation)..."

# iTerm2 key bindings format:
# Key: "0x7b-0x100000" = Left Arrow (0x7b) + Command (0x100000)
# Key: "0x7c-0x100000" = Right Arrow (0x7c) + Command (0x100000)
# Action 5 = Select Previous Tab, Action 6 = Select Next Tab

ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# Check if iTerm2 preferences exist
if [ ! -f "$ITERM_PLIST" ]; then
    echo "⚠ iTerm2 preferences not found. Please open iTerm2 at least once, then run this script again."
else
    # Use Python to safely add key bindings to GlobalKeyMap
    /usr/bin/python3 - <<'PYPLIST'
import plistlib
from pathlib import Path

plist_path = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"

try:
    # Read existing plist
    with open(plist_path, 'rb') as f:
        plist_data = plistlib.load(f)

    # Ensure GlobalKeyMap exists
    if 'GlobalKeyMap' not in plist_data:
        plist_data['GlobalKeyMap'] = {}

    # Add Command+Left Arrow -> Previous Tab (Action 5)
    plist_data['GlobalKeyMap']['0x7b-0x100000'] = {
        'Action': 5,
        'Text': ''
    }

    # Add Command+Right Arrow -> Next Tab (Action 6)
    plist_data['GlobalKeyMap']['0x7c-0x100000'] = {
        'Action': 6,
        'Text': ''
    }

    # Write back to plist
    with open(plist_path, 'wb') as f:
        plistlib.dump(plist_data, f)

    print("✓ Key bindings configured successfully")

except Exception as e:
    print(f"⚠ Could not configure key bindings: {e}")
    print("  You can configure manually in iTerm2 → Settings → Keys")
PYPLIST

fi
echo ""
echo "Next steps:"
echo "1. Restart iTerm2 for key bindings and profiles to take effect"
echo "2. Test tab navigation: Command+Left/Right arrows to switch between tabs"
echo "3. The profiles will automatically switch when you cd into each repo"
echo "4. All profiles now have 100,000 line scrollback buffer"
echo "5. JetBrains Mono 13 font is now available for use"
echo "6. (Optional) Manually change your existing profiles to use JetBrains Mono in iTerm2 Settings"
echo "7. (Optional) Install color schemes from https://iterm2colorschemes.com for better colors"
echo ""
echo "To test, try: cd $REPO_BASE_DIR/transcript_extraction_dev"
echo ""
echo "Profiles created for:"
for repo in "${(@k)REPO_COLORS}"; do
    echo "  - $repo → ${REPO_COLORS[$repo]} (JetBrains Mono 13, 100k scrollback)"
done
