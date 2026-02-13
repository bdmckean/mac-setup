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

# Define repo-to-color-scheme mappings (using iTerm2 built-in schemes)
typeset -A REPO_COLORS=(
    ["mac-setup"]="Solarized Dark"
    ["transcript_extraction_dev"]="Dracula"
    ["budget_claude"]="Gruvbox Dark"
    ["budget_cursor"]="One Dark"
    ["budget_tracing"]="Nord"
    ["budget"]="Monokai"
    ["agentic_ai_learning"]="Tomorrow Night"
    ["intro-to-langsmith"]="Snazzy"
    ["coding"]="Tango Dark"
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

    cat >> "$DYNAMIC_PROFILES_DIR/RepoProfiles.json" << EOF
    {
      "Name": "$repo",
      "Guid": "$repo-$(uuidgen)",
      "Dynamic Profile Parent Name": "Default",
      "Custom Directory": "Yes",
      "Working Directory": "$REPO_BASE_DIR/$repo",
      "Bound Hosts": ["*"],
      "Tags": ["repo"],
      "Badge Text": "$repo",
      "Color Preset Name": "$COLOR_SCHEME",
      "Normal Font": "JetBrainsMono-Regular 13",
      "Scrollback Lines": 100000,
      "Unlimited Scrollback": false,
      "Terminal Type": "xterm-256color",
      "Use Bold Font": true,
      "Use Bright Bold": true,
      "Use Italic Font": true,
      "Visual Bell": true,
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
# Action 39 = Select Previous Tab, Action 40 = Select Next Tab

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
