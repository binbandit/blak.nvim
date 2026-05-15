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
WIDTH = 50
HEIGHT = 14
WANTED = 32
ART_WIDTH = 44
FRAME_DELAY_MS = 80
COLOR_PALETTE = (
    "#661100",
    "#771100",
    "#881100",
    "#991100",
    "#aa2200",
    "#bb2200",
    "#cc3300",
    "#dd4400",
    "#ee6600",
    "#ff8811",
)

# The upstream GIF is a full terminal preview. This crop removes terminal chrome
# and keeps the black-hole art itself.
CROP = (360, 130, 840, 530)


def lua_string(value: str) -> str:
    return "[=[" + value + "]=]"


def frame_height() -> int:
    return HEIGHT


def red_signal(r: int, g: int, b: int) -> float:
    red = r / 255.0
    dominance = max(0.0, (r - max(g, b) * 0.82) / 255.0)
    return max(dominance * 1.8, red * dominance * 2.2)


def pixel_to_char(r: int, g: int, b: int) -> str:
    # The milli preview uses orange/red characters on a dark terminal. Use red
    # dominance rather than raw luminance so terminal chrome and dark background
    # collapse to spaces while the accretion disk remains.
    lum = red_signal(r, g, b)
    if lum < 0.025:
        return " "
    lum = min(1.0, lum**0.55)
    return CHARS[min(len(CHARS) - 1, int(lum * (len(CHARS) - 1)))]


def pixel_to_color(r: int, g: int, b: int) -> str:
    # The resized GIF pixels are very dark after anti-aliasing, so preserve the
    # source's red/orange intent by mapping the same red signal to a terminal
    # palette similar to milli.nvim's generated splash colors.
    strength = min(1.0, max(0.0, (red_signal(r, g, b) - 0.02) / 0.16))
    index = min(len(COLOR_PALETTE) - 1, int((strength**0.7) * len(COLOR_PALETTE)))
    return COLOR_PALETTE[index]


def row_color_runs(chars: list[str], colors: list[str]) -> list[tuple[int, int, str, str]]:
    runs: list[tuple[int, int, str, str]] = []
    run_start: int | None = None
    run_color: str | None = None
    for col, (char, color) in enumerate(zip(chars, colors, strict=True)):
        if char == " ":
            if run_start is not None and run_color is not None:
                runs.append((run_start, col, run_color, "NONE"))
            run_start = None
            run_color = None
            continue
        if run_color != color:
            if run_start is not None and run_color is not None:
                runs.append((run_start, col, run_color, "NONE"))
            run_start = col
            run_color = color
    if run_start is not None and run_color is not None:
        runs.append((run_start, len(chars), run_color, "NONE"))
    return runs


def image_to_frame(image: Image.Image, height: int) -> tuple[list[str], list[list[tuple[int, int, str, str]]]]:
    rgb = image.convert("RGB").crop(CROP)
    rgb = rgb.resize((ART_WIDTH, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (WIDTH, height), (0, 0, 0))
    canvas.paste(rgb, ((WIDTH - rgb.width) // 2, 0))

    lines: list[str] = []
    color_runs: list[list[tuple[int, int, str, str]]] = []
    for py in range(height):
        chars = []
        colors = []
        for px in range(WIDTH):
            r, g, b = canvas.getpixel((px, py))
            chars.append(pixel_to_char(r, g, b))
            colors.append(pixel_to_color(r, g, b))
        lines.append("".join(chars).rstrip())
        color_runs.append(row_color_runs(chars, colors))
    return lines, color_runs


def visible_cells(lines: list[str]) -> int:
    return sum(ch != " " for line in lines for ch in line)


def sample_indices(count: int, wanted: int) -> list[int]:
    return sorted(set(round(i * (count - 1) / max(1, wanted - 1)) for i in range(wanted)))


def main() -> None:
    im = Image.open(SRC)
    height = frame_height()
    source_frames: list[tuple[list[str], list[list[tuple[int, int, str, str]]], int, int]] = []
    for frame in ImageSequence.Iterator(im):
        lines, colors = image_to_frame(frame, height)
        duration = FRAME_DELAY_MS
        source_frames.append((lines, colors, duration, visible_cells(lines)))

    counts = [count for _, _, _, count in source_frames if count > 0]
    if not counts:
        raise RuntimeError(f"{SRC} did not produce any visible ASCII frames")

    # The upstream GIF starts with a few tiny terminal-cursor delta frames. If
    # sampled, they make the loop visibly flash when the animation wraps.
    min_visible_cells = round(median(counts) * 0.60)
    visible_frames = [frame for frame in source_frames if frame[3] >= min_visible_cells]
    indices = sample_indices(len(visible_frames), WANTED)

    frames = [visible_frames[idx][0] for idx in indices]
    colors = [visible_frames[idx][1] for idx in indices]
    delays = [visible_frames[idx][2] for idx in indices]

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
    out.append("  },")
    out.append("  colors = {")
    for frame_colors in colors:
        out.append("    {")
        for row_runs in frame_colors:
            if row_runs:
                runs = ", ".join(
                    f'{{ {start}, {end}, "{fg}", "{bg}" }}'
                    for start, end, fg, bg in row_runs
                )
                out.append(f"      {{ {runs} }},")
            else:
                out.append("      {},")
        out.append("    },")
    out.extend(["  },", "}"])
    OUT.write_text("\n".join(out) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
