#!/bin/zsh

# iTerm2 Top Development Color Schemes Installer
# Installs 10 carefully selected schemes with distinct visual styles

SCHEMES_DIR="$HOME/.iterm2-color-schemes"
ITERM_SCHEMES_DIR="$HOME/Library/Application Support/iTerm2/ColorPresets"

# Create directories
mkdir -p "$ITERM_SCHEMES_DIR"
mkdir -p "$SCHEMES_DIR"

echo "Downloading iTerm2 color schemes repository..."

# Clone or update the color schemes repository
if [ -d "$SCHEMES_DIR/.git" ]; then
    echo "Updating existing repository..."
    cd "$SCHEMES_DIR"
    git pull
else
    echo "Cloning color schemes repository..."
    rm -rf "$SCHEMES_DIR"
    git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git "$SCHEMES_DIR"
fi

echo ""
echo "Installing top 10 development color schemes..."

# Array of the best development schemes (visually distinct)
BEST_SCHEMES=(
    "Dracula"                      # Purple/dark - most popular
    "Gruvbox Dark"                # Warm brown/beige - retro feel
    "Nord"                        # Cool blue-gray - minimal
    "Atom One Dark"               # Dark gray - Atom editor
    "Solarized Dark Higher Contrast"  # Blue-green - classic
    "Monokai Remastered"          # Black/gray - Sublime Text
    "TokyoNight"                  # Deep blue - trendy
    "Catppuccin Mocha"            # Purple/lavender - modern
    "Pale Night Hc"               # Purple-blue - Material theme
    "Ayu"                         # Dark blue - clean
)

# Copy selected schemes
for scheme in "${BEST_SCHEMES[@]}"; do
    if [ -f "$SCHEMES_DIR/schemes/${scheme}.itermcolors" ]; then
        cp "$SCHEMES_DIR/schemes/${scheme}.itermcolors" "$ITERM_SCHEMES_DIR/"
        echo "✓ Installed: $scheme"
    else
        echo "⚠ Not found: $scheme (trying variations...)"
        # Try without spaces
        scheme_nospace="${scheme// /}"
        if [ -f "$SCHEMES_DIR/schemes/${scheme_nospace}.itermcolors" ]; then
            cp "$SCHEMES_DIR/schemes/${scheme_nospace}.itermcolors" "$ITERM_SCHEMES_DIR/"
            echo "✓ Installed: $scheme_nospace"
        fi
    fi
done

echo ""
echo "Configuring keyboard shortcuts (Command+Left/Right for tabs)..."

ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [ ! -f "$ITERM_PLIST" ]; then
    echo "⚠ iTerm2 preferences not found. Please open iTerm2 at least once."
else
    /usr/bin/python3 - <<'PYPLIST'
import plistlib
from pathlib import Path

plist_path = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"

try:
    with open(plist_path, 'rb') as f:
        plist_data = plistlib.load(f)

    if 'GlobalKeyMap' not in plist_data:
        plist_data['GlobalKeyMap'] = {}

    # Command+Left Arrow -> Previous Tab (Action 5)
    plist_data['GlobalKeyMap']['0x7b-0x100000'] = {
        'Action': 5,
        'Text': ''
    }

    # Command+Right Arrow -> Next Tab (Action 6)
    plist_data['GlobalKeyMap']['0x7c-0x100000'] = {
        'Action': 6,
        'Text': ''
    }

    with open(plist_path, 'wb') as f:
        plistlib.dump(plist_data, f)

    print("✓ Keyboard shortcuts configured")
    print("  Command+Left Arrow  = Previous Tab")
    print("  Command+Right Arrow = Next Tab")

except Exception as e:
    print(f"⚠ Could not configure shortcuts: {e}")
PYPLIST

fi

echo ""
echo "=========================================="
echo "Installed Color Schemes (by background):"
echo "=========================================="
echo ""
echo "Purple tones:"
echo "  • Dracula          - Most popular dark purple"
echo "  • Catppuccin Mocha - Modern purple/lavender"
echo "  • Palenight        - Material purple-blue"
echo ""
echo "Blue tones:"
echo "  • Nord             - Cool blue-gray (minimal)"
echo "  • Tokyo Night      - Deep blue (trendy)"
echo "  • Ayu Dark         - Clean dark blue"
echo "  • Solarized Dark   - Classic blue-green"
echo ""
echo "Warm/Neutral tones:"
echo "  • Gruvbox Dark     - Warm brown/retro"
echo "  • Monokai          - Classic black/gray"
echo "  • One Dark         - Atom editor gray"
echo ""
echo "To use them:"
echo "1. Restart iTerm2 (or open Preferences)"
echo "2. Preferences → Profiles → Colors → Color Presets"
echo "3. Select any scheme from the dropdown"
echo ""
echo "Tip: Use different schemes for different projects!"
echo "     Purple = personal, Blue = work, Warm = experiments"
