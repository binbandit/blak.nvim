#!/usr/bin/env python3
"""Static validation for Blak when Neovim/Lua are unavailable.

This does not replace running `nvim --headless` in CI, but it catches the
maintenance mistakes that are easiest to make in a modular Lua distro: broken
require paths, unbalanced delimiters, duplicate extra ids, and missing docs.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[1]
LUA = sorted(ROOT.rglob("*.lua"))
REQUIRE_RE = re.compile(r"require\(['\"](blak(?:\.[A-Za-z0-9_\-]+)*)['\"]\)")
ID_RE = re.compile(r"id\s*=\s*['\"]([^'\"]+)['\"]")
KEYWORD_RE = re.compile(r"\b(function|if|for|while|repeat|end|until)\b")


def strip_lua(text: str) -> str:
    """Remove Lua comments and strings while preserving delimiter-bearing code.

    This is intentionally small, but it handles quoted strings, escapes,
    generated long-bracket strings like [=[...]=], and line comments inside
    shell command strings such as "rg --hidden".
    """
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""

        if ch in {'"', "'"}:
            quote = ch
            out.append(quote + quote)
            i += 1
            while i < n:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == quote:
                    i += 1
                    break
                i += 1
            continue

        if ch == "[":
            m = re.match(r"\[(=*)\[", text[i:])
            if m:
                eq = m.group(1)
                end_pat = "]" + eq + "]"
                end_idx = text.find(end_pat, i + len(eq) + 2)
                out.append("''")
                i = n if end_idx == -1 else end_idx + len(end_pat)
                continue

        if ch == "-" and nxt == "-":
            # Long comment: --[[...]] or --[=[...]=]
            m = re.match(r"--\[(=*)\[", text[i:])
            if m:
                eq = m.group(1)
                end_pat = "]" + eq + "]"
                end_idx = text.find(end_pat, i + len(eq) + 4)
                i = n if end_idx == -1 else end_idx + len(end_pat)
                continue
            # Line comment.
            end_idx = text.find("\n", i)
            if end_idx == -1:
                break
            out.append("\n")
            i = end_idx + 1
            continue

        out.append(ch)
        i += 1
    return "".join(out)


def module_path(require_name: str) -> Path:
    parts = require_name.split(".")
    return ROOT / "lua" / Path(*parts).with_suffix(".lua")


def check_balanced(path: Path, text: str) -> list[str]:
    clean = strip_lua(text)
    pairs = {')': '(', '}': '{', ']': '['}
    stack: list[tuple[str, int]] = []
    errors: list[str] = []
    for idx, ch in enumerate(clean):
        if ch in "({[":
            stack.append((ch, idx))
        elif ch in pairs:
            if not stack or stack[-1][0] != pairs[ch]:
                errors.append(f"{path}: unmatched {ch} near offset {idx}")
                break
            stack.pop()
    if stack:
        ch, idx = stack[-1]
        errors.append(f"{path}: unmatched {ch} near offset {idx}")
    return errors



def check_keyword_balance(path: Path, text: str) -> list[str]:
    clean = strip_lua(text)
    stack: list[tuple[str, int]] = []
    errors: list[str] = []
    for match in KEYWORD_RE.finditer(clean):
        kw, pos = match.group(1), match.start()
        if kw in {"function", "if", "for", "while", "repeat"}:
            stack.append((kw, pos))
        elif kw == "until":
            if stack and stack[-1][0] == "repeat":
                stack.pop()
            else:
                errors.append(f"{path}: unexpected until near offset {pos}")
        elif kw == "end":
            if stack and stack[-1][0] in {"function", "if", "for", "while"}:
                stack.pop()
            else:
                errors.append(f"{path}: unexpected end near offset {pos}")
    if stack:
        kw, pos = stack[-1]
        errors.append(f"{path}: unclosed {kw} near offset {pos}")
    return errors


def check_blackhole_frames() -> list[str]:
    path = ROOT / "lua" / "blak" / "splash" / "frames" / "blackhole.lua"
    text = path.read_text(encoding="utf-8")
    rel = path.relative_to(ROOT)
    errors: list[str] = []

    cols_match = re.search(r"\bcols\s*=\s*(\d+)", text)
    rows_match = re.search(r"\brows\s*=\s*(\d+)", text)
    if not cols_match or not rows_match:
        return [f"{rel}: missing cols/rows metadata"]

    cols = int(cols_match.group(1))
    rows = int(rows_match.group(1))
    if not (0.48 <= rows / cols <= 0.52):
        errors.append(f"{rel}: frame table aspect should stay near 1:2")

    frame_blocks = re.findall(r"    \{\n(.*?)\n    \},", text, re.S)
    frames = [re.findall(r"\[=\[(.*?)\]=\]", block) for block in frame_blocks]
    delay_match = re.search(r"\bdelays\s*=\s*\{([^}]*)\}", text)
    delays = [int(value) for value in re.findall(r"\d+", delay_match.group(1))] if delay_match else []

    if not frames:
        errors.append(f"{rel}: no frames found")
        return errors
    if len(delays) != len(frames):
        errors.append(f"{rel}: {len(delays)} delays for {len(frames)} frames")

    counts: list[int] = []
    centers: list[tuple[int, float]] = []
    body_widths: list[int] = []
    for frame_index, frame in enumerate(frames, start=1):
        if len(frame) != rows:
            errors.append(f"{rel}: frame {frame_index} has {len(frame)} rows, expected {rows}")
        for line_index, line in enumerate(frame, start=1):
            if len(line) > cols:
                errors.append(f"{rel}: frame {frame_index} line {line_index} is wider than {cols}")

        coords = [
            (x, y)
            for y, line in enumerate(frame)
            for x, ch in enumerate(line)
            if ch != " "
        ]
        counts.append(len(coords))
        if coords:
            xs = [x for x, _ in coords]
            centers.append((frame_index, (min(xs) + max(xs)) / 2))
            body_widths.append(max(xs) - min(xs) + 1)

    visible_counts = [count for count in counts if count > 0]
    if not visible_counts:
        errors.append(f"{rel}: frames contain no visible cells")
        return errors

    minimum_visible = median(visible_counts) * 0.60
    for frame_index, count in enumerate(counts, start=1):
        if count < minimum_visible:
            errors.append(f"{rel}: frame {frame_index} is sparse enough to flash on loop")

    expected_center = (cols - 1) / 2
    for frame_index, center in centers:
        if abs(center - expected_center) > 2:
            errors.append(f"{rel}: frame {frame_index} is horizontally off-center")

    if body_widths and median(body_widths) < 40:
        errors.append(f"{rel}: visible black-hole body is too narrow")

    return errors


def main() -> int:
    errors: list[str] = []

    for path in LUA:
        text = path.read_text(encoding="utf-8")
        errors.extend(check_balanced(path.relative_to(ROOT), text))
        errors.extend(check_keyword_balance(path.relative_to(ROOT), text))
        for req in REQUIRE_RE.findall(text):
            target = module_path(req)
            init_target = ROOT / "lua" / Path(*req.split(".")).joinpath("init.lua")
            if not target.exists() and not init_target.exists():
                # blak.user is intentionally optional.
                if req != "blak.user":
                    errors.append(f"{path.relative_to(ROOT)}: require({req!r}) has no module file")

    seen: dict[str, Path] = {}
    for path in (ROOT / "lua" / "blak" / "extras").rglob("*.lua"):
        if path.name in {"init.lua", "state.lua"}:
            continue
        text = path.read_text(encoding="utf-8")
        match = ID_RE.search(text)
        if not match:
            errors.append(f"{path.relative_to(ROOT)}: missing extra id")
            continue
        extra_id = match.group(1)
        if extra_id in seen:
            errors.append(f"duplicate extra id {extra_id}: {seen[extra_id]} and {path}")
        seen[extra_id] = path

    errors.extend(check_blackhole_frames())

    for rel in [
        "README.md",
        "CONTRIBUTING.md",
        "NOTICE",
        "doc/blak.txt",
        "doc/blak-extras.txt",
        "doc/blak-keymaps.txt",
        ".github/workflows/ci.yml",
    ]:
        if not (ROOT / rel).exists():
            errors.append(f"missing {rel}")

    legacy_patterns = [
        'require("black',
        "require('black",
        "lua/black",
        "doc/black",
        "colors/black.lua",
        "checkhealth black",
        "vim.g.black",
        "vim.b.black",
        ":Black",
    ]
    for path in ROOT.rglob("*"):
        if path.is_dir() or path.name == "blackhole.gif" or path == ROOT / "scripts" / "validate.py" or ".git" in path.parts:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for pattern in legacy_patterns:
            if pattern in text:
                errors.append(f"{path.relative_to(ROOT)}: legacy Black identifier remains: {pattern}")

    if errors:
        print("Validation failed:", file=sys.stderr)
        for err in errors:
            print("- " + err, file=sys.stderr)
        return 1

    print(f"Validation passed: {len(LUA)} Lua files, {len(seen)} extras")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
