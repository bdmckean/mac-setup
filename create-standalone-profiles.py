#!/usr/bin/env python3
"""
Create standalone iTerm2 profiles for recommended color schemes
These profiles are NOT tied to directories - use them manually or with tmux/workmux
"""

import json
import plistlib
import os
from pathlib import Path

# Paths
DYNAMIC_PROFILES_DIR = Path.home() / "Library" / "Application Support" / "iTerm2" / "DynamicProfiles"
SCHEMES_DIR = Path.home() / "Downloads" / "iTerm2-Color-Schemes-master" / "schemes"

# Recommended color schemes for code development
RECOMMENDED_SCHEMES = [
    # Top Tier - Excellent for long coding sessions
    "TokyoNight Storm",
    "Catppuccin Mocha",
    "Gruvbox Material Dark",
    "Nord",
    "Atom One Dark",

    # High Contrast - Great visibility
    "Dracula",
    "Monokai Pro",
    "Oceanic Next",
    "Material Darker",

    # Unique & Colorful
    "Ayu Mirage",
    "TokyoNight Moon",
    "Snazzy",
    "Material Ocean",

    # Classics
    "Solarized Dark Patched",
    "Gruvbox Dark",
    "Tomorrow Night",

    # Additional good options
    "TokyoNight Night",
    "Catppuccin Frappe",
    "Monokai Remastered",
    "One Dark Two",
]

def extract_color(color_dict):
    """Extract RGB components from color dictionary"""
    if not color_dict or not isinstance(color_dict, dict):
        return None
    return {
        "Red Component": float(color_dict.get("Red Component", 0)),
        "Green Component": float(color_dict.get("Green Component", 0)),
        "Blue Component": float(color_dict.get("Blue Component", 0))
    }

def load_color_scheme(scheme_path):
    """Load color scheme from .itermcolors file"""
    with open(scheme_path, 'rb') as f:
        return plistlib.load(f)

def create_profile(scheme_name, colors, guid_suffix):
    """Create a standalone profile dictionary with full color scheme"""
    import uuid

    profile = {
        "Name": scheme_name,
        "Guid": f"{scheme_name.replace(' ', '-')}-{guid_suffix}",
        "Dynamic Profile Parent Name": "Default",
        "Tags": ["standalone", "code-dev"],
        "Badge Text": scheme_name,
        "Normal Font": "JetBrainsMono-Regular 13",
        "Scrollback Lines": 100000,
        "Unlimited Scrollback": False,
        "Terminal Type": "xterm-256color",
        "Use Bold Font": True,
        "Use Bright Bold": True,
        "Use Italic Font": True,
        "Visual Bell": True,
        "Silence Bell": True,
    }

    # Add background and foreground colors
    if "Background Color" in colors:
        profile["Background Color"] = extract_color(colors["Background Color"])
    if "Foreground Color" in colors:
        profile["Foreground Color"] = extract_color(colors["Foreground Color"])

    # Add all 16 ANSI colors
    for i in range(16):
        ansi_key = f"Ansi {i} Color"
        if ansi_key in colors:
            profile[ansi_key] = extract_color(colors[ansi_key])

    # Add optional colors
    for color_type in ["Cursor Color", "Cursor Text Color", "Bold Color",
                       "Selection Color", "Selected Text Color", "Link Color"]:
        if color_type in colors:
            color_value = extract_color(colors[color_type])
            if color_value:
                profile[color_type] = color_value

    # NO automatic profile switching - let tmux/workmux handle it

    return profile

def main():
    profiles = []
    missing_schemes = []
    guid_suffix = 0

    print("Creating standalone iTerm2 profiles for code development...\n")
    print(f"Looking for schemes in: {SCHEMES_DIR}\n")

    for scheme_name in RECOMMENDED_SCHEMES:
        scheme_path = SCHEMES_DIR / f"{scheme_name}.itermcolors"

        if not scheme_path.exists():
            print(f"⚠️  Scheme not found: {scheme_name}")
            missing_schemes.append(scheme_name)
            continue

        print(f"✓ {scheme_name}")

        # Load color scheme
        colors = load_color_scheme(scheme_path)

        # Create profile
        profile = create_profile(scheme_name, colors, guid_suffix)
        profiles.append(profile)
        guid_suffix += 1

    # Write profiles JSON
    output_file = DYNAMIC_PROFILES_DIR / "CodeDevProfiles.json"
    DYNAMIC_PROFILES_DIR.mkdir(parents=True, exist_ok=True)

    profiles_data = {"Profiles": profiles}

    with open(output_file, 'w') as f:
        json.dump(profiles_data, f, indent=2)

    print(f"\n{'='*60}")
    print(f"✓ Created {len(profiles)} profiles at:")
    print(f"  {output_file}")
    print(f"{'='*60}\n")

    if missing_schemes:
        print(f"⚠️  Missing {len(missing_schemes)} schemes:")
        for scheme in missing_schemes:
            print(f"   - {scheme}")
        print()

    print("Profile categories created:")
    print("  🏆 Top Tier: TokyoNight Storm, Catppuccin Mocha, Gruvbox Material Dark, Nord, Atom One Dark")
    print("  🔥 High Contrast: Dracula, Monokai Pro, Oceanic Next, Material Darker")
    print("  🌈 Unique: Ayu Mirage, TokyoNight Moon, Snazzy, Material Ocean")
    print("  📚 Classics: Solarized Dark Patched, Gruvbox Dark, Tomorrow Night")
    print()
    print("Next steps:")
    print("1. Restart iTerm2 or go to Settings → Profiles → Refresh")
    print("2. Profiles are tagged with 'standalone' and 'code-dev'")
    print("3. Use with tmux/workmux by setting ITERM_PROFILE environment variable:")
    print("   export ITERM_PROFILE='TokyoNight Storm'")
    print("4. Or manually select from the profile dropdown in iTerm2")
    print()
    print("To integrate with tmux/workmux:")
    print("  - In tmux: run-shell 'echo -e \"\\033]50;SetProfile=TokyoNight Storm\\a\"'")
    print("  - In workmux config: set profile per workspace")
    print()

if __name__ == "__main__":
    main()
