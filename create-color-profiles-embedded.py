#!/usr/bin/env python3

import json
import plistlib
from pathlib import Path
import uuid

# Paths
color_presets_dir = Path.home() / "Library/Application Support/iTerm2/ColorPresets"
dynamic_profiles_dir = Path.home() / "Library/Application Support/iTerm2/DynamicProfiles"
output_file = dynamic_profiles_dir / "ColorProfiles.json"

# Create directory if needed
dynamic_profiles_dir.mkdir(parents=True, exist_ok=True)

# The 10 color schemes we want
schemes = [
    "Dracula.itermcolors",
    "Gruvbox Dark.itermcolors",
    "Nord.itermcolors",
    "Atom One Dark.itermcolors",
    "Solarized Dark Higher Contrast.itermcolors",
    "Monokai Remastered.itermcolors",
    "TokyoNight.itermcolors",
    "Catppuccin Mocha.itermcolors",
    "Pale Night Hc.itermcolors",
    "Ayu.itermcolors",
]

# Friendly names (without .itermcolors extension)
friendly_names = {
    "Dracula.itermcolors": "Dracula",
    "Gruvbox Dark.itermcolors": "Gruvbox Dark",
    "Nord.itermcolors": "Nord",
    "Atom One Dark.itermcolors": "Atom One Dark",
    "Solarized Dark Higher Contrast.itermcolors": "Solarized Dark",
    "Monokai Remastered.itermcolors": "Monokai",
    "TokyoNight.itermcolors": "Tokyo Night",
    "Catppuccin Mocha.itermcolors": "Catppuccin",
    "Pale Night Hc.itermcolors": "Palenight",
    "Ayu.itermcolors": "Ayu",
}

profiles = []

print("Creating 10 color profiles with embedded colors...")

for scheme_file in schemes:
    scheme_path = color_presets_dir / scheme_file
    
    if not scheme_path.exists():
        print(f"⚠ Not found: {scheme_file}")
        continue
    
    # Read the .itermcolors file (it's a plist)
    try:
        with open(scheme_path, 'rb') as f:
            colors = plistlib.load(f)
        
        profile_name = friendly_names.get(scheme_file, scheme_file.replace('.itermcolors', ''))
        
        # Create profile with embedded colors
        profile = {
            "Name": profile_name,
            "Guid": f"{profile_name}-{uuid.uuid4()}",
            "Dynamic Profile Parent Name": "Default",
            "Normal Font": "JetBrainsMono-Regular 13",
            "Scrollback Lines": 100000,
            "Unlimited Scrollback": False,
            "Terminal Type": "xterm-256color",
            "Use Bold Font": True,
            "Use Bright Bold": True,
            "Use Italic Font": True,
            "Visual Bell": True,
        }
        
        # Copy all color settings from the scheme
        for key, value in colors.items():
            if 'Color' in key:
                profile[key] = value
        
        profiles.append(profile)
        print(f"✓ {profile_name}")
        
    except Exception as e:
        print(f"⚠ Error reading {scheme_file}: {e}")

# Write the JSON file
output_data = {"Profiles": profiles}

with open(output_file, 'w') as f:
    json.dump(output_data, f, indent=2)

print(f"\n✓ Created {len(profiles)} profiles at: {output_file}")
print("\nProfiles created:")
for profile in profiles:
    print(f"  • {profile['Name']}")
print("\nRestart iTerm2 to see the profiles.")
print("They will appear directly in: Profiles → Open Profiles")
print("No submenus - all at the top level!")
