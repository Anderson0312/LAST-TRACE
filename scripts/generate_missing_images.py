#!/usr/bin/env python3
"""Generate missing Último Acesso visual assets via Gemini image API."""
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PHOTOS = ROOT / "assets" / "images" / "photos"
AVATARS = ROOT / "assets" / "images" / "avatars"
WALLS = ROOT / "assets" / "images" / "wallpapers"

STYLE = (
    "Photorealistic smartphone photo, natural Brazilian urban night or indoor lighting, "
    "subtle film grain, no text overlays except when the prompt requires readable UI text, "
    "no watermarks, no logos of real brands unless fictional names are requested."
)

JOBS: dict[str, tuple[str, str, str]] = {
    "ph10.jpg": ("photos", "9:16", f"{STYLE} Vertical realistic smartphone messaging screenshot."),
}

def main() -> int:
    print("generate_missing_images stub — use full script from local project")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
