#!/usr/bin/env python3
"""
Add color schemes as regular iTerm2 profiles with full color definitions
Reads .itermcolors files and adds them directly to iTerm2 preferences
"""

import plistlib
import uuid
from pathlib import Path

ITERM_PLIST = Path.home() / "Library" / "Preferences" / "com.googlecode.iterm2.plist"
SCHEMES_DIR = Path.home() / "Downloads" / "iTerm2-Color-Schemes-master" / "schemes"

# Map friendly names to .itermcolors files
COLOR_SCHEMES = {
    "Dracula": "Dracula.itermcolors",
    "Gruvbox Dark": "Gruvbox Dark.itermcolors",
    "Nord": "Nord.itermcolors",
    "Atom One Dark": "Atom One Dark.itermcolors",
    "Solarized Dark": "Solarized Dark Higher Contrast.itermcolors",
    "Monokai": "Monokai Remastered.itermcolors",
    "Tokyo Night": "TokyoNight.itermcolors",
    "Catppuccin": "Catppuccin Mocha.itermcolors",
    "Palenight": "Pale Night Hc.itermcolors",
    "Ayu": "Ayu.itermcolors"
}

def main():
    print("Adding 10 color schemes as regular iTerm2 profiles...\n")

    # Check schemes directory
    if not SCHEMES_DIR.exists():
        print(f"❌ Schemes directory not found: {SCHEMES_DIR}")
        return 1

    # Read iTerm2 preferences
    print("Reading iTerm2 preferences...")
    try:
        with open(ITERM_PLIST, 'rb') as f:
            plist_data = plistlib.load(f)
    except Exception as e:
        print(f"❌ Error reading iTerm2 preferences: {e}")
        return 1

    # Get existing profiles
    bookmarks = plist_data.get("New Bookmarks", [])
    existing_names = {p.get("Name") for p in bookmarks}

    print(f"Found {len(bookmarks)} existing profiles\n")

    # Get Default profile as template
    default_profile = None
    for p in bookmarks:
        if p.get("Name") == "Default":
            default_profile = p.copy()
            break

    if not default_profile:
        print("❌ No Default profile found")
        return 1

    # Add each color scheme
    added = 0
    skipped = 0

    for profile_name, scheme_file in COLOR_SCHEMES.items():
        if profile_name in existing_names:
            print(f"⚠️  Skipping '{profile_name}' - already exists")
            skipped += 1
            continue

        scheme_path = SCHEMES_DIR / scheme_file

        if not scheme_path.exists():
            print(f"❌ Not found: {scheme_file}")
            continue

        try:
            # Read the .itermcolors file (it's a plist)
            with open(scheme_path, 'rb') as f:
                colors = plistlib.load(f)

            # Create new profile from default
            new_profile = default_profile.copy()
            new_profile["Name"] = profile_name
            new_profile["Guid"] = str(uuid.uuid4())

            # Set standard properties
            new_profile["Normal Font"] = "JetBrainsMono-Regular 13"
            new_profile["Scrollback Lines"] = 100000
            new_profile["Unlimited Scrollback"] = False
            new_profile["Terminal Type"] = "xterm-256color"
            new_profile["Use Bold Font"] = True
            new_profile["Use Bright Bold"] = True
            new_profile["Use Italic Font"] = True
            new_profile["Visual Bell"] = True

            # Copy all color definitions from the scheme
            for key, value in colors.items():
                if 'Color' in key:
                    new_profile[key] = value

            bookmarks.append(new_profile)
            added += 1
            print(f"✓ Added '{profile_name}' with full color definitions")

        except Exception as e:
            print(f"❌ Error processing {scheme_file}: {e}")

    if added > 0:
        # Write back to preferences
        print(f"\nWriting {added} new profiles to iTerm2 preferences...")
        plist_data["New Bookmarks"] = bookmarks

        try:
            with open(ITERM_PLIST, 'wb') as f:
                plistlib.dump(plist_data, f)
            print("✓ Successfully updated iTerm2 preferences")
        except Exception as e:
            print(f"❌ Error writing preferences: {e}")
            return 1

    print("\n" + "="*60)
    print(f"✓ Added {added} new profiles")
    if skipped > 0:
        print(f"⚠️  Skipped {skipped} existing profiles")
    print("\nNext steps:")
    print("1. Restart iTerm2 completely (Cmd+Q, then reopen)")
    print("2. Go to Settings → Profiles")
    print("3. All 10 color schemes should now be available as regular profiles")
    print("4. Select any profile or set directory-based switching in Advanced")
    print("="*60)

    return 0

if __name__ == "__main__":
    exit(main())
