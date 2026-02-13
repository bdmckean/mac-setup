#!/usr/bin/env python3
"""
Add color scheme profiles to iTerm2 as regular profiles
"""

import plistlib
import uuid
from pathlib import Path

ITERM_PLIST = Path.home() / "Library" / "Preferences" / "com.googlecode.iterm2.plist"

# Profile names to add
COLOR_SCHEMES = [
    "Dracula",
    "Gruvbox Dark",
    "Nord",
    "Atom One Dark",
    "Solarized Dark",
    "Monokai",
    "Tokyo Night",
    "Catppuccin",
    "Palenight",
    "Ayu"
]

def read_plist():
    """Read iTerm2 preferences"""
    with open(ITERM_PLIST, 'rb') as f:
        return plistlib.load(f)

def write_plist(data):
    """Write iTerm2 preferences"""
    with open(ITERM_PLIST, 'wb') as f:
        plistlib.dump(data, f)

def create_profile_from_default(name, default_profile):
    """Create a new profile based on default"""
    profile = default_profile.copy()
    profile["Name"] = name
    profile["Guid"] = str(uuid.uuid4())

    # Set the color preset name
    profile["Color Preset Name"] = name

    # Standard settings
    profile["Normal Font"] = "JetBrainsMono-Regular 13"
    profile["Scrollback Lines"] = 100000
    profile["Unlimited Scrollback"] = False
    profile["Terminal Type"] = "xterm-256color"
    profile["Use Bold Font"] = True
    profile["Use Bright Bold"] = True
    profile["Use Italic Font"] = True
    profile["Visual Bell"] = True

    return profile

def main():
    print("Adding color scheme profiles to iTerm2...\n")

    # Read current preferences
    try:
        plist_data = read_plist()
    except Exception as e:
        print(f"❌ Error reading iTerm2 preferences: {e}")
        return 1

    # Get existing profiles
    existing_profiles = plist_data.get("New Bookmarks", [])
    existing_names = {p.get("Name") for p in existing_profiles}

    # Get default profile as template
    default_profile = None
    for p in existing_profiles:
        if p.get("Name") == "Default":
            default_profile = p
            break

    if not default_profile:
        print("❌ Could not find Default profile")
        return 1

    print(f"Found {len(existing_profiles)} existing profiles")
    print(f"Existing profiles: {', '.join(sorted(existing_names))}\n")

    # Add color scheme profiles
    added = []
    skipped = []

    for scheme_name in COLOR_SCHEMES:
        if scheme_name in existing_names:
            skipped.append(scheme_name)
            continue

        # Create new profile
        new_profile = create_profile_from_default(scheme_name, default_profile)
        existing_profiles.append(new_profile)
        added.append(scheme_name)
        print(f"✓ Added '{scheme_name}' profile")

    if added:
        # Update preferences
        plist_data["New Bookmarks"] = existing_profiles

        try:
            write_plist(plist_data)
            print(f"\n✓ Successfully added {len(added)} new profiles")
        except Exception as e:
            print(f"\n❌ Error writing preferences: {e}")
            return 1

    if skipped:
        print(f"\n⚠️  Skipped {len(skipped)} existing profiles: {', '.join(skipped)}")

    if not added:
        print("\n⚠️  No new profiles to add")
        return 0

    print("\n" + "="*60)
    print("Next steps:")
    print("1. Restart iTerm2 completely (Cmd+Q, then reopen)")
    print("2. Go to Settings → Profiles to see all profiles")
    print("3. Select any profile from the dropdown menu")
    print("4. Download color schemes from iterm2colorschemes.com if needed")
    print("="*60)

    return 0

if __name__ == "__main__":
    exit(main())
