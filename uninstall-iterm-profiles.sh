#!/bin/bash

# iTerm2 Profile Uninstall Script
# Removes the dynamic profiles created by setup-iterm-profiles.sh

DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
PROFILE_FILE="$DYNAMIC_PROFILES_DIR/RepoProfiles.json"

echo "iTerm2 Profile Uninstall"
echo "========================"
echo ""

if [ -f "$PROFILE_FILE" ]; then
    echo "Found dynamic profiles at: $PROFILE_FILE"
    echo ""
    echo "This will remove the 8 repo-specific profiles:"
    echo "  - mac-setup"
    echo "  - transcript_extraction_dev"
    echo "  - budget_claude"
    echo "  - budget_cursor"
    echo "  - budget_tracing"
    echo "  - budget"
    echo "  - agentic_ai_learning"
    echo "  - intro-to-langsmith"
    echo ""
    echo "Your existing profiles (Default, CaryatidA, seafoam) will NOT be affected."
    echo "They will keep their 100,000 line scrollback setting."
    echo ""
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$PROFILE_FILE"
        echo "✓ Removed $PROFILE_FILE"
        echo ""
        echo "Next steps:"
        echo "1. Restart iTerm2 or go to Settings → Profiles → Refresh"
        echo "2. The repo profiles will no longer appear in your profile list"
        echo ""
        echo "To restore the profiles, run: ./setup-iterm-profiles.sh"
    else
        echo "Uninstall cancelled."
    fi
else
    echo "No dynamic profiles found at: $PROFILE_FILE"
    echo "Nothing to uninstall."
fi
