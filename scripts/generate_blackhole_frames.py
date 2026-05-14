#!/usr/bin/env python3
"""Regenerate lua/blak/splash/frames/blackhole.lua from assets/blackhole.gif."""
from __future__ import annotations

from pathlib import Path
from statistics import median

from PIL import Image, ImageSequence

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "blackhole.gif"
OUT = ROOT / "lua" / "blak" / "splash" / "frames" / "blackhole.lua"
CHARS = " .:-=+*#%@"
WIDTH = 62
WANTED = 32
CELL_WIDTH_TO_HEIGHT = 0.60
ART_WIDTH = 34

# The upstream GIF is a full terminal preview. This crop removes terminal chrome
# and keeps the black-hole art itself.
CROP = (360, 130, 840, 530)


def lua_string(value: str) -> str:
    return "[=[" + value + "]=]"


def frame_height() -> int:
    crop_w, crop_h = CROP[2] - CROP[0], CROP[3] - CROP[1]
    return max(18, round(crop_h / crop_w * WIDTH * CELL_WIDTH_TO_HEIGHT))


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
    rgb = rgb.resize((ART_WIDTH, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (WIDTH, height), (0, 0, 0))
    canvas.paste(rgb, ((WIDTH - rgb.width) // 2, 0))

    lines: list[str] = []
    for py in range(height):
        line = []
        for px in range(WIDTH):
            line.append(pixel_to_char(*canvas.getpixel((px, py))))
        lines.append("".join(line).rstrip())
    return lines


def visible_cells(lines: list[str]) -> int:
    return sum(ch != " " for line in lines for ch in line)


def sample_indices(count: int, wanted: int) -> list[int]:
    return sorted(set(round(i * (count - 1) / max(1, wanted - 1)) for i in range(wanted)))


def main() -> None:
    im = Image.open(SRC)
    height = frame_height()
    source_frames: list[tuple[list[str], int, int]] = []
    for frame in ImageSequence.Iterator(im):
        lines = image_to_lines(frame, height)
        duration = int(frame.info.get("duration", 40) or 40)
        source_frames.append((lines, duration, visible_cells(lines)))

    counts = [count for _, _, count in source_frames if count > 0]
    if not counts:
        raise RuntimeError(f"{SRC} did not produce any visible ASCII frames")

    # The upstream GIF starts with a few tiny terminal-cursor delta frames. If
    # sampled, they make the loop visibly flash when the animation wraps.
    min_visible_cells = round(median(counts) * 0.60)
    visible_frames = [frame for frame in source_frames if frame[2] >= min_visible_cells]
    indices = sample_indices(len(visible_frames), WANTED)

    frames = [visible_frames[idx][0] for idx in indices]
    delays = [visible_frames[idx][1] for idx in indices]

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
