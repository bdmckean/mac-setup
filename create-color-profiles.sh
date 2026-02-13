#!/bin/zsh

# Create iTerm2 profiles for each of the 10 color schemes
# No tags = no submenus

DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DYNAMIC_PROFILES_DIR"

echo "Creating 10 color scheme profiles..."

# Define the 10 color schemes
typeset -A COLOR_SCHEMES=(
    ["Dracula"]="Dracula"
    ["Gruvbox Dark"]="Gruvbox Dark"
    ["Nord"]="Nord"
    ["Atom One Dark"]="Atom One Dark"
    ["Solarized Dark"]="Solarized Dark Higher Contrast"
    ["Monokai"]="Monokai Remastered"
    ["Tokyo Night"]="TokyoNight"
    ["Catppuccin"]="Catppuccin Mocha"
    ["Palenight"]="Pale Night Hc"
    ["Ayu"]="Ayu"
)

# Start JSON
cat > "$DYNAMIC_PROFILES_DIR/ColorProfiles.json" << 'EOF'
{
  "Profiles": [
EOF

FIRST=true
for profile_name in "${(@k)COLOR_SCHEMES}"; do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$DYNAMIC_PROFILES_DIR/ColorProfiles.json"
    fi

    COLOR_PRESET="${COLOR_SCHEMES[$profile_name]}"

    cat >> "$DYNAMIC_PROFILES_DIR/ColorProfiles.json" << EOF
    {
      "Name": "$profile_name",
      "Guid": "$profile_name-$(uuidgen)",
      "Dynamic Profile Parent Name": "Default",
      "Color Preset Name": "$COLOR_PRESET",
      "Normal Font": "JetBrainsMono-Regular 13",
      "Scrollback Lines": 100000,
      "Unlimited Scrollback": false,
      "Terminal Type": "xterm-256color",
      "Use Bold Font": true,
      "Use Bright Bold": true,
      "Use Italic Font": true,
      "Visual Bell": true
    }
EOF
done

# Close JSON
cat >> "$DYNAMIC_PROFILES_DIR/ColorProfiles.json" << 'EOF'
  ]
}
EOF

echo "✓ Created 10 color profiles at: $DYNAMIC_PROFILES_DIR/ColorProfiles.json"
echo ""
echo "Profiles created:"
for profile_name in "${(@k)COLOR_SCHEMES}"; do
    echo "  • $profile_name"
done
echo ""
echo "Restart iTerm2 to see the new profiles."
echo "They will appear in: Profiles → Open Profiles"
echo ""
echo "To switch profiles: Cmd+O (Open Profiles), then select one"
