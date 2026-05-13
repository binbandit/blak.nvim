#!/usr/bin/env python3
"""Regenerate lua/blak/splash/frames/blackhole.lua from assets/blackhole.gif."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageSequence

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "blackhole.gif"
OUT = ROOT / "lua" / "blak" / "splash" / "frames" / "blackhole.lua"
CHARS = " .:-=+*#%@"
WIDTH = 62
WANTED = 32

# The upstream GIF is a full terminal preview. This crop removes terminal chrome
# and keeps the black-hole art itself.
CROP = (360, 130, 840, 530)


def lua_string(value: str) -> str:
    return "[=[" + value + "]=]"


def frame_height() -> int:
    crop_w, crop_h = CROP[2] - CROP[0], CROP[3] - CROP[1]
    return max(18, round(crop_h / crop_w * WIDTH * 0.50))


def pixel_to_char(r: int, g: int, b: int) -> str:
    # The milli preview uses orange/red characters on a dark terminal. Use red
    # dominance rather than raw luminance so terminal chrome and dark background
    # collapse to spaces while the accretion disk remains.
    red = r / 255.0
    dominance = max(0.0, (r - max(g, b) * 0.82) / 255.0)
    lum = max(dominance * 1.8, red * dominance * 2.2)
    if lum < 0.025:
        return " "
    lum = min(1.0, lum**0.55)
    return CHARS[min(len(CHARS) - 1, int(lum * (len(CHARS) - 1)))]


def image_to_lines(image: Image.Image, height: int) -> list[str]:
    rgb = image.convert("RGB").crop(CROP)
    rgb.thumbnail((WIDTH, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (WIDTH, height), (0, 0, 0))
    canvas.paste(rgb, ((WIDTH - rgb.width) // 2, (height - rgb.height) // 2))

    lines: list[str] = []
    for py in range(height):
        line = []
        for px in range(WIDTH):
            line.append(pixel_to_char(*canvas.getpixel((px, py))))
        lines.append("".join(line).rstrip())
    return lines


def main() -> None:
    im = Image.open(SRC)
    height = frame_height()
    frame_count = getattr(im, "n_frames", 1)
    indices = sorted(
        set(round(i * (frame_count - 1) / max(1, WANTED - 1)) for i in range(WANTED))
    )

    frames: list[list[str]] = []
    delays: list[int] = []
    for idx, frame in enumerate(ImageSequence.Iterator(im)):
        if idx not in indices:
            continue
        delays.append(int(frame.info.get("duration", 40) or 40))
        frames.append(image_to_lines(frame, height))

    out = [
        "-- Generated from assets/blackhole.gif, sourced from the milli.nvim media preview for blackhole.",
        "-- Source: https://raw.githubusercontent.com/amansingh-afk/milli.nvim/media/previews/blackhole.gif",
        "-- Regenerate with: python3 scripts/generate_blackhole_frames.py",
        "return {",
        '  source = "milli.nvim media/previews/blackhole.gif",',
        f"  cols = {WIDTH},",
        f"  rows = {height},",
        "  delays = { " + ", ".join(map(str, delays)) + " },",
        "  frames = {",
    ]
    for frame in frames:
        out.append("    {")
        for line in frame:
            out.append("      " + lua_string(line) + ",")
        out.append("    },")
    out.extend(["  },", "}"])
    OUT.write_text("\n".join(out) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
