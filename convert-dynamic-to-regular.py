#!/usr/bin/env python3
"""
Convert iTerm2 dynamic profiles to regular profiles
Reads ColorProfiles.json and adds them as regular profiles to iTerm2 preferences
"""

import json
import plistlib
import subprocess
from pathlib import Path

# Paths
DYNAMIC_PROFILES_FILE = Path.home() / "Library" / "Application Support" / "iTerm2" / "DynamicProfiles" / "ColorProfiles.json"
ITERM_PLIST = Path.home() / "Library" / "Preferences" / "com.googlecode.iterm2.plist"

def main():
    print("Converting dynamic profiles to regular profiles...\n")

    # Check if dynamic profiles file exists
    if not DYNAMIC_PROFILES_FILE.exists():
        print(f"❌ Dynamic profiles file not found: {DYNAMIC_PROFILES_FILE}")
        return 1

    # Read dynamic profiles
    print(f"Reading dynamic profiles from: {DYNAMIC_PROFILES_FILE}")
    with open(DYNAMIC_PROFILES_FILE, 'r') as f:
        dynamic_data = json.load(f)

    dynamic_profiles = dynamic_data.get("Profiles", [])
    print(f"Found {len(dynamic_profiles)} dynamic profiles")

    # Read current iTerm2 preferences using plutil (safer than plistlib for binary plists)
    print(f"\nReading iTerm2 preferences...")
    try:
        # Convert binary plist to XML for easier handling
        result = subprocess.run(
            ['plutil', '-convert', 'xml1', '-o', '-', str(ITERM_PLIST)],
            capture_output=True,
            text=False,
            check=True
        )
        plist_data = plistlib.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error reading iTerm2 preferences: {e}")
        return 1

    # Get existing profiles
    existing_profiles = plist_data.get("New Bookmarks", [])
    print(f"Found {len(existing_profiles)} existing profiles")

    # Get existing profile names to avoid duplicates
    existing_names = {p.get("Name") for p in existing_profiles}

    # Convert and add dynamic profiles
    added_count = 0
    for profile in dynamic_profiles:
        profile_name = profile.get("Name", "Unnamed")

        # Skip if profile already exists
        if profile_name in existing_names:
            print(f"⚠️  Skipping '{profile_name}' - already exists as regular profile")
            continue

        # Remove dynamic profile specific keys
        keys_to_remove = [
            "Dynamic Profile Parent Name",
            "Dynamic Profile Filename",
            "Automatic Profile Switching",
            "Custom Directory",
            "Working Directory",
            "Bound Hosts",
            "Tags",
            "Badge Text"
        ]

        # Create clean profile
        regular_profile = {k: v for k, v in profile.items() if k not in keys_to_remove}

        # Ensure required fields are present
        if "Guid" not in regular_profile:
            import uuid
            regular_profile["Guid"] = str(uuid.uuid4())

        # Add some standard fields if not present
        if "Custom Command" not in regular_profile:
            regular_profile["Custom Command"] = "No"

        existing_profiles.append(regular_profile)
        added_count += 1
        print(f"✓ Added '{profile_name}' as regular profile")

    if added_count == 0:
        print("\n⚠️  No new profiles to add")
        return 0

    # Update the plist data
    plist_data["New Bookmarks"] = existing_profiles

    # Write back to iTerm2 preferences
    print(f"\nWriting {added_count} new profiles to iTerm2 preferences...")
    try:
        # Write the plist
        with open(ITERM_PLIST, 'wb') as f:
            plistlib.dump(plist_data, f)
        print("✓ Successfully updated iTerm2 preferences")
    except Exception as e:
        print(f"❌ Error writing preferences: {e}")
        return 1

    # Reload iTerm2 preferences
    print("\nReloading iTerm2 preferences...")
    subprocess.run(['defaults', 'read', 'com.googlecode.iterm2'],
                   capture_output=True, check=False)

    print("\n" + "="*60)
    print(f"✓ Successfully converted {added_count} dynamic profiles to regular profiles")
    print("\nNext steps:")
    print("1. Restart iTerm2 or go to Settings → Profiles → Refresh")
    print("2. The new profiles will appear in your profile list")
    print("3. You can now manually select them or set directory-based rules")
    print("4. After verifying, you can delete ColorProfiles.json")
    print("="*60)

    return 0

if __name__ == "__main__":
    exit(main())
