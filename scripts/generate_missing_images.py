#!/usr/bin/env python3
"""Gera placeholders visuais faltantes para o jogo Último Acesso.

Uso:
  python3 scripts/generate_missing_images.py
"""
from __future__ import annotations

import math
import os
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError as e:
    raise SystemExit(
        "Pillow é necessário. Instale com: pip install pillow"
    ) from e

ROOT = Path(__file__).resolve().parents[1]
IMG = ROOT / "assets" / "images"


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def gradient(size, c1, c2):
    w, h = size
    im = Image.new("RGB", size)
    px = im.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(c1[0] + (c2[0] - c1[0]) * t)
        g = int(c1[1] + (c2[1] - c1[1]) * t)
        b = int(c1[2] + (c2[2] - c1[2]) * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return im


def save_jpeg(im: Image.Image, path: Path, quality: int = 82) -> None:
    ensure_dir(path.parent)
    rgb = im.convert("RGB")
    rgb.save(path, "JPEG", quality=quality, optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({path.stat().st_size} bytes)")


def make_wallpaper(name: str, c1, c2) -> None:
    im = gradient((1080, 1920), c1, c2)
    draw = ImageDraw.Draw(im)
    # soft circles
    for i in range(8):
        x = 120 + (i * 137) % 900
        y = 200 + (i * 211) % 1600
        r = 80 + (i * 37) % 180
        col = tuple(min(255, c + 30) for c in c2) + (40,)
        overlay = Image.new("RGBA", im.size, (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse((x - r, y - r, x + r, y + r), fill=col)
        im = Image.alpha_composite(im.convert("RGBA"), overlay).convert("RGB")
    save_jpeg(im, IMG / "wallpapers" / f"{name}.jpg")


def make_avatar(name: str, seed: int) -> None:
    c1 = ((seed * 37) % 180, (seed * 59) % 180, (seed * 83) % 180)
    c2 = ((c1[0] + 40) % 220, (c1[1] + 60) % 220, (c1[2] + 80) % 220)
    im = gradient((512, 512), c1, c2)
    draw = ImageDraw.Draw(im)
    # head silhouette
    draw.ellipse((156, 90, 356, 290), fill=(240, 220, 200))
    draw.ellipse((120, 280, 392, 520), fill=(40, 40, 50))
    letter = name.replace("char_", "")[:1].upper()
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 120)
    except Exception:
        font = ImageFont.load_default()
    draw.text((220, 160), letter, fill=(30, 30, 30), font=font)
    save_jpeg(im, IMG / "avatars" / f"{name}.jpg")


def make_photo(name: str, seed: int, label: str) -> None:
    c1 = ((seed * 17) % 160 + 20, (seed * 29) % 160 + 20, (seed * 41) % 160 + 20)
    c2 = ((c1[0] + 70) % 255, (c1[1] + 50) % 255, (c1[2] + 90) % 255)
    im = gradient((900, 1200), c1, c2)
    draw = ImageDraw.Draw(im)
    for i in range(6):
        x = (seed * 13 + i * 97) % 800
        y = (seed * 19 + i * 131) % 1000
        r = 40 + (i * 23) % 120
        draw.ellipse((x, y, x + r, y + r), fill=(c2[0] // 2, c2[1] // 2, c2[2] // 2))
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 36)
    except Exception:
        font = ImageFont.load_default()
    draw.rectangle((0, 1100, 900, 1200), fill=(0, 0, 0))
    draw.text((24, 1125), label[:40], fill=(255, 255, 255), font=font)
    save_jpeg(im, IMG / "photos" / f"{name}.jpg", quality=78)


def main() -> None:
    ensure_dir(IMG / "wallpapers")
    ensure_dir(IMG / "avatars")
    ensure_dir(IMG / "photos")

    # Wallpapers
    make_wallpaper("dusk_harbor", (12, 24, 48), (80, 60, 90))
    make_wallpaper("blush_concrete", (60, 40, 40), (180, 140, 130))

    avatars = [
        "char_bruno", "char_camila", "char_daniel", "char_leo",
        "char_marina", "char_rafael", "char_rita", "char_sofia", "char_unknown",
    ]
    for i, a in enumerate(avatars):
        dest = IMG / "avatars" / f"{a}.jpg"
        if not dest.exists() or dest.stat().st_size < 1000:
            make_avatar(a, 100 + i * 17)

    # Narrative photos ph1..ph34 + phb1..phb3
    for i in range(1, 35):
        name = f"ph{i}"
        dest = IMG / "photos" / f"{name}.jpg"
        if not dest.exists() or dest.stat().st_size < 1000:
            make_photo(name, 200 + i * 11, f"photo {name}")
    for i in range(1, 4):
        name = f"phb{i}"
        dest = IMG / "photos" / f"{name}.jpg"
        if not dest.exists() or dest.stat().st_size < 1000:
            make_photo(name, 500 + i * 13, f"device B {name}")

    print("done")


if __name__ == "__main__":
    main()
