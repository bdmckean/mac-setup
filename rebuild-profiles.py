#!/usr/bin/env python3
"""
Rebuild iTerm2 profiles with full color schemes from .itermcolors files
"""

import json
import plistlib
import os
from pathlib import Path

# Paths
REPO_BASE_DIR = Path.home() / "work" / "repo"
DYNAMIC_PROFILES_DIR = Path.home() / "Library" / "Application Support" / "iTerm2" / "DynamicProfiles"
SCHEMES_DIR = Path.home() / "Downloads" / "iTerm2-Color-Schemes-master" / "schemes"

# Repo to color scheme mappings
REPO_SCHEMES = {
    "mac-setup": "Solarized Dark Patched",
    "transcript_extraction_dev": "Dracula",
    "budget_claude": "Gruvbox Dark",
    "budget_cursor": "Monokai Soda",
    "budget_tracing": "Nord",
    "budget": "Monokai Remastered",
    "agentic_ai_learning": "Gruvbox Material Dark",
    "intro-to-langsmith": "Dracula+",
    "seafoam": "Seafoam Pastel",
}

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

def create_profile(repo_name, scheme_name, colors):
    """Create a profile dictionary with full color scheme"""
    import uuid

    profile = {
        "Name": repo_name,
        "Guid": f"{repo_name}-{uuid.uuid4()}",
        "Dynamic Profile Parent Name": "Default",
        "Custom Directory": "Yes",
        "Working Directory": str(REPO_BASE_DIR / repo_name),
        "Bound Hosts": ["*"],
        "Tags": ["repo", "auto-switch"],
        "Badge Text": repo_name,
        "Normal Font": "JetBrainsMono-Regular 13",
        "Scrollback Lines": 100000,
        "Unlimited Scrollback": False,
        "Terminal Type": "xterm-256color",
        "Use Bold Font": True,
        "Use Bright Bold": True,
        "Use Italic Font": True,
        "Visual Bell": True,
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
                       "Selection Color", "Selected Text Color"]:
        if color_type in colors:
            color_value = extract_color(colors[color_type])
            if color_value:
                profile[color_type] = color_value

    # Add automatic profile switching
    profile["Automatic Profile Switching"] = {
        "Enabled": True,
        "Rules": [
            {
                "Pattern": f"{REPO_BASE_DIR}/{repo_name}*",
                "Type": "Path"
            }
        ]
    }

    return profile

def main():
    profiles = []

    print("Rebuilding iTerm2 profiles with full color schemes...\n")

    for repo_name, scheme_name in REPO_SCHEMES.items():
        scheme_path = SCHEMES_DIR / f"{scheme_name}.itermcolors"

        if not scheme_path.exists():
            print(f"⚠️  Warning: Scheme file not found: {scheme_path}")
            continue

        print(f"✓ Processing {repo_name} → {scheme_name}")

        # Load color scheme
        colors = load_color_scheme(scheme_path)

        # Create profile
        profile = create_profile(repo_name, scheme_name, colors)
        profiles.append(profile)

    # Write profiles JSON
    output_file = DYNAMIC_PROFILES_DIR / "RepoProfiles.json"
    DYNAMIC_PROFILES_DIR.mkdir(parents=True, exist_ok=True)

    profiles_data = {"Profiles": profiles}

    with open(output_file, 'w') as f:
        json.dump(profiles_data, f, indent=2)

    print(f"\n✓ Created {len(profiles)} profiles at: {output_file}")
    print("\nNext steps:")
    print("1. Restart iTerm2 or go to Settings → Profiles → Refresh")
    print("2. The profiles will automatically switch when you cd into each repo")
    print("3. Each profile now has its full color scheme with distinct colors\n")

if __name__ == "__main__":
    main()
