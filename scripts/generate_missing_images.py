#!/usr/bin/env python3
"""Gera imagens faltantes do Último Acesso via Gemini Flash Image."""
from __future__ import annotations

import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

# Repo root = parent of scripts/
ROOT = Path(__file__).resolve().parents[1] / "assets" / "images"
PHOTOS = ROOT / "photos"
AVATARS = ROOT / "avatars"
WALLS = ROOT / "wallpapers"

STYLE = (
    "Cinematic smartphone photo, photorealistic, Brazilian urban night atmosphere, "
    "subtle film grain, natural phone-camera look, moody investigative thriller tone, "
    "no watermarks, no real brand logos unless fictional names are requested."
)

# filename -> (folder, aspect hint, prompt)
JOBS: dict[str, tuple[str, str, str]] = {
    # remaining marina gallery
    "ph10.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical realistic smartphone messaging app screenshot dark mode, "
        "single threatening message bubble reading exactly: Você precisa parar de investigar isso. "
        "Unknown sender, night timestamp, minimal UI chrome.",
    ),
    "ph11.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical zoomed phone photo of black car license plate partially obscured, "
        "readable characters like BRT-3 and blurry digits, parking garage night.",
    ),
    "ph12.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical warm office selfie of Brazilian woman journalist smiling at newsroom desk, "
        "natural daylight, slightly lower quality recovered deleted photo feel.",
    ),
    "ph13.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical photo of paper city map on table with red pen X mark near labeled area "
        "São Lucas, phone flash, investigative annotation.",
    ),
    "ph14.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical photo of blurred bank statement printout, visible amount 80.000 and "
        "words AV Services, intentional soft blur on personal data.",
    ),
    "ph15.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical still from shaky phone video in parking corridor, motion blur, dark concrete "
        "hallway, grainy night feel, no clear faces.",
    ),
    "ph16.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical photo of car window reflection at night showing faint female silhouette, "
        "parking lights, mysterious.",
    ),
    "ph17.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical restaurant lunch photo of tired Brazilian male editor looking away from camera, "
        "avoiding eye contact, daylight cafe, Marina POV across table.",
    ),
    "ph18.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical close-up yellow sticky note handwritten text exactly: 0912 — não esquecer, "
        "on fridge, phone photo.",
    ),
    "ph19.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical night photo of modest hotel facade neon glow reading Hotel Norte, "
        "wet street reflections near urban parking.",
    ),
    "ph20.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical older happy couple selfie Brazilian woman journalist and curly-haired man "
        "with headphones vibe, daylight park, nostalgic warm grade.",
    ),
    "ph21.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical realistic smartphone screen recording UI, red REC indicator, timer 00:03:41, "
        "dark blurred content behind overlay.",
    ),
    "ph22.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical contacts app screenshot contact named R. with note: apagar se algo acontecer, "
        "iOS-like dark mode contacts UI.",
    ),
    "ph23.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical bar selfie two Brazilian women smiling, silver bracelet visible on one wrist, "
        "warm lights.",
    ),
    "ph24.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical newsroom corkboard photo, red sticky note reading exactly: AURORA — NÃO PUBLICAR, "
        "fluorescent office light.",
    ),
    "ph25.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical messaging screenshot chat with contact R., message: Eles sabem que alguém vazou, "
        "dark mode chat UI.",
    ),
    "ph26.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical night photo corporate building entrance guard booth CCTV, black car parked nearby, "
        "cold lighting, fictional company.",
    ),
    "ph27.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical photo restaurant bill on table stamped time 23:09 visible, warm restaurant light.",
    ),
    "ph28.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical elevator mirror selfie Brazilian woman with black backpack, tense expression, "
        "fluorescent elevator light.",
    ),
    "ph29.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical clear store receipt prepaid chip number 90000-1717 and AV Services printed.",
    ),
    "ph30.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical bathroom mirror photo lipstick writing on glass exactly: 0912 — não esquecer, "
        "foggy mirror apartment bathroom.",
    ),
    "ph31.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical security camera dashboard UI screenshot, CÂMERA B status SEM SINAL 00:12, "
        "dark monitoring software aesthetic.",
    ),
    "ph32.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical bank transfer screenshot amount 80.000 from AV Services to D. Rocha, "
        "slightly damaged deleted look, fictional NexoBank UI.",
    ),
    "ph33.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical night wet street photo, street sign partially reading São Luc…, empty sidewalk "
        "toward parking garage.",
    ),
    "ph34.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical voice memo app screen file gravacao_2347.m4a duration 03:41, waveform, dark mode.",
    ),
    "phb1.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical empty underground parking, concrete pillar large letter B, yellow sodium lights, "
        "no people, anxious waiting mood.",
    ),
    "phb2.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical phone photo black SUV parking ramp, fictional ValeLogística fleet sticker, "
        "license plate clearly NEX-4A71, night garage.",
    ),
    "phb3.jpg": (
        "photos",
        "9:16",
        f"{STYLE} Vertical banking app screenshot negative balance around 38.000, fictional NexoBank dark mode UI.",
    ),
}


def out_path(name: str, folder: str) -> Path:
    base = {"photos": PHOTOS, "avatars": AVATARS, "wallpapers": WALLS}[folder]
    return base / name


def already_exists(name: str, folder: str) -> bool:
    p = out_path(name, folder)
    stem = p.with_suffix("")
    return any(stem.with_suffix(ext).exists() for ext in (".jpg", ".png", ".jpeg", ".webp"))


def generate_one(api_key: str, model: str, prompt: str, aspect: str) -> bytes:
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{model}:generateContent?key={api_key}"
    )
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
            "imageConfig": {"aspectRatio": aspect},
        },
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = json.loads(resp.read().decode())

    for cand in data.get("candidates", []):
        for part in cand.get("content", {}).get("parts", []):
            inline = part.get("inlineData") or part.get("inline_data")
            if not inline:
                continue
            mime = inline.get("mimeType") or inline.get("mime_type") or ""
            if "image" in mime or inline.get("data"):
                return base64.b64decode(inline["data"])
    raise RuntimeError(f"No image in response: {json.dumps(data)[:500]}")


def main() -> int:
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("MISSING_KEY", file=sys.stderr)
        return 2

    model = os.environ.get("GEMINI_IMAGE_MODEL", "gemini-2.5-flash-image")
    only = set(sys.argv[1:]) if len(sys.argv) > 1 else None
    failed: list[str] = []
    done = 0
    skipped = 0

    for name, (folder, aspect, prompt) in JOBS.items():
        if only and name not in only and name.replace(".jpg", "") not in only:
            continue
        if already_exists(name, folder):
            print(f"SKIP {name}")
            skipped += 1
            continue
        print(f"GEN  {name} ...", flush=True)
        try:
            img = generate_one(api_key, model, prompt, aspect)
            dest = out_path(name, folder)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(img)
            print(f"OK   {name} ({len(img)} bytes)")
            done += 1
            time.sleep(1.2)
        except urllib.error.HTTPError as e:
            err = e.read().decode(errors="replace")
            print(f"FAIL {name}: HTTP {e.code} {err[:300]}")
            failed.append(name)
            if e.code in (429, 403) or "RESOURCE_EXHAUSTED" in err or "quota" in err.lower():
                print("STOP: credits/quota exhausted")
                break
        except Exception as e:  # noqa: BLE001
            print(f"FAIL {name}: {e}")
            failed.append(name)

    print(json.dumps({"done": done, "skipped": skipped, "failed": failed}, ensure_ascii=False))
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
