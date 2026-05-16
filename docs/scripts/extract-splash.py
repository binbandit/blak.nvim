#!/usr/bin/env python3
"""
Convert the milli braille frame data at lua/blak/splash/frames/blackhole.lua
into a compact JSON file the docs site can render in-browser.

The Lua file's color spans use byte offsets (each braille character is 3 bytes
UTF-8). We convert those to character offsets so the web renderer can slice
strings without worrying about encoding.

We also drop spans whose foreground is white (#ffffff) — in the Neovim splash
those are background paint over blank braille cells that never show color in
the editor. On a pure-black web page, painting them white would surround the
disc with a glowing square. Dropping them lets the disc float in the void.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
LUA = REPO / "lua" / "blak" / "splash" / "frames" / "blackhole.lua"
OUT = REPO / "docs" / "src" / "data" / "splash.json"


def find_int(pattern: str, text: str, label: str) -> int:
    m = re.search(pattern, text)
    if not m:
        raise SystemExit(f"could not find {label}")
    return int(m.group(1))


def parse_lua(text: str) -> dict:
    cols = find_int(r"cols\s*=\s*(\d+)", text, "cols")
    rows = find_int(r"rows\s*=\s*(\d+)", text, "rows")

    delays_match = re.search(r"delays\s*=\s*\{([^}]+)\}", text)
    if not delays_match:
        raise SystemExit("could not find delays")
    delays = [int(x) for x in re.findall(r"\d+", delays_match.group(1))]

    frames = parse_frames(text)
    colors = parse_colors(text)

    if len(frames) != len(colors):
        raise SystemExit(f"frame/color mismatch: {len(frames)} vs {len(colors)}")

    return {
        "cols": cols,
        "rows": rows,
        "delays": delays,
        "frames": frames,
        "colors": colors,
    }


def parse_frames(text: str) -> list[list[str]]:
    """Each frame is `M.frames[N] = (function() return { "...", "..." } end)()`."""
    out: list[list[str]] = []
    for idx in range(1, 10_000):
        marker = f"M.frames[{idx}]"
        start = text.find(marker)
        if start < 0:
            break
        open_brace = text.find("{", start)
        close_brace = text.find("} end)()", open_brace)
        body = text[open_brace + 1 : close_brace]
        lines = re.findall(r'"([^"]*)"', body)
        if not lines:
            raise SystemExit(f"frame {idx} has no string lines")
        out.append(lines)
    return out


def parse_colors(text: str) -> list[list[list[list]]]:
    """Each colors entry is a list of rows; each row is a list of spans
    `{start_byte, end_byte, fg, bg}`. We convert byte offsets to character
    offsets (divide by 3), drop the bg, and drop white spans entirely.
    """
    out: list[list[list[list]]] = []
    for idx in range(1, 10_000):
        marker = f"M.colors[{idx}]"
        start = text.find(marker)
        if start < 0:
            break
        open_brace = text.find("{", start)
        close_brace = text.find("} end)()", open_brace)
        body = text[open_brace + 1 : close_brace]

        rows: list[list[list]] = []
        # Each row is wrapped in its own braces and contains span tuples
        # `{a,b,"#xxxxxx","NONE"}`. Pull the row blocks first.
        depth = 0
        row_start = 0
        for i, ch in enumerate(body):
            if ch == "{":
                if depth == 0:
                    row_start = i
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    row_text = body[row_start : i + 1]
                    rows.append(parse_row_spans(row_text))
        out.append(rows)
    return out


def parse_row_spans(row_text: str) -> list[list]:
    """Inside one row, extract every `{start,end,"#xxx","NONE"}` tuple."""
    spans: list[list] = []
    for match in re.finditer(
        r'\{\s*(\d+)\s*,\s*(\d+)\s*,\s*"([^"]+)"\s*,\s*"[^"]+"\s*\}',
        row_text,
    ):
        start_byte, end_byte, fg = (
            int(match.group(1)),
            int(match.group(2)),
            match.group(3),
        )
        if fg.lower() == "#ffffff":
            continue
        # Byte → character offset (each braille char is 3 bytes UTF-8).
        spans.append([start_byte // 3, end_byte // 3, fg])
    return spans


def main() -> None:
    text = LUA.read_text(encoding="utf-8")
    data = parse_lua(text)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, separators=(",", ":"), ensure_ascii=False))
    print(
        f"wrote {OUT.relative_to(REPO)}: "
        f"{len(data['frames'])} frames, {data['cols']}x{data['rows']}, "
        f"{OUT.stat().st_size} bytes"
    )


if __name__ == "__main__":
    main()
