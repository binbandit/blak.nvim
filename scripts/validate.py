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

ROOT = Path(__file__).resolve().parents[1]
LUA = sorted(ROOT.rglob("*.lua"))
REQUIRE_RE = re.compile(r"require\(['\"](blak(?:\.[A-Za-z0-9_\-]+)*)['\"]\)")
ID_RE = re.compile(r"id\s*=\s*['\"]([^'\"]+)['\"]")
KEYWORD_RE = re.compile(r"\b(function|if|for|while|repeat|do|end|until)\b")
DOCS_LINK_RE = re.compile(
    r"\]\(/blak\.nvim/([^)\s#]*)(?:#[^) \t]*)?\)"
    r"|href=[\"']/blak\.nvim/([^\"'#]*)(?:#[^\"']*)?[\"']"
)


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
        if kw == "do" and stack and stack[-1][0] in {"for", "while"}:
            continue
        if kw in {"function", "if", "for", "while", "repeat", "do"}:
            stack.append((kw, pos))
        elif kw == "until":
            if stack and stack[-1][0] == "repeat":
                stack.pop()
            else:
                errors.append(f"{path}: unexpected until near offset {pos}")
        elif kw == "end":
            if stack and stack[-1][0] in {"function", "if", "for", "while", "do"}:
                stack.pop()
            else:
                errors.append(f"{path}: unexpected end near offset {pos}")
    if stack:
        kw, pos = stack[-1]
        errors.append(f"{path}: unclosed {kw} near offset {pos}")
    return errors


def check_blackhole_frames() -> list[str]:
    # The frames module is a milli.nvim export — a per-frame IIFE table of
    # braille (U+2800..U+28FF) strings. We trust upstream for artistic quality
    # and only validate that the shape Blak's runtime expects is still intact.
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
    if (cols, rows) != (50, 14):
        errors.append(f"{rel}: expected 50 cols and 14 rows, got {cols} cols and {rows} rows")

    delay_match = re.search(r"\bdelays\s*=\s*\{([^}]*)\}", text)
    delays = [int(v) for v in re.findall(r"\d+", delay_match.group(1))] if delay_match else []

    frame_re = re.compile(r"M\.frames\[(\d+)\]\s*=\s*\(function\(\)\s*return\s*\{(.*?)\}\s*end\)\(\)", re.S)
    frames: list[list[str]] = []
    for _, body in frame_re.findall(text):
        lines = re.findall(r'"([^"\n]*)"', body)
        frames.append(lines)

    if not frames:
        return errors + [f"{rel}: no frames found"]

    if len(delays) != len(frames):
        errors.append(f"{rel}: {len(delays)} delays for {len(frames)} frames")
    if delays and any(d != delays[0] for d in delays):
        errors.append(f"{rel}: frame delays should be uniform")

    for frame_index, frame in enumerate(frames, start=1):
        if len(frame) != rows:
            errors.append(f"{rel}: frame {frame_index} has {len(frame)} rows, expected {rows}")
            continue
        for line_index, line in enumerate(frame, start=1):
            # Braille cells are 1 display column wide; bail if anything else slipped in.
            if any(not (ch == " " or 0x2800 <= ord(ch) <= 0x28FF) for ch in line):
                errors.append(f"{rel}: frame {frame_index} line {line_index} contains non-braille glyphs")
                break
            if len(line) != cols:
                errors.append(f"{rel}: frame {frame_index} line {line_index} has {len(line)} cells, expected {cols}")
                break

    color_re = re.compile(r"M\.colors\[(\d+)\]\s*=\s*\(function\(\)\s*return\s*\{(.*?)\}\s*end\)\(\)", re.S)
    color_blocks = color_re.findall(text)
    if not color_blocks:
        errors.append(f"{rel}: missing color spans")
    elif len(color_blocks) != len(frames):
        errors.append(f"{rel}: {len(color_blocks)} color frames for {len(frames)} frames")

    run_re = re.compile(r'\{\s*(\d+),\s*(\d+),\s*"(#[0-9a-fA-F]{6})",\s*"(NONE|#[0-9a-fA-F]{6})"\s*\}')
    palette: set[str] = set()
    # Each braille cell is 3 bytes in UTF-8, so column offsets in extmark runs
    # are byte-based and capped at cols * 3.
    max_bytes = cols * 3
    for _, body in color_blocks:
        for start, end, fg, _ in run_re.findall(body):
            s, e = int(start), int(end)
            palette.add(fg.lower())
            if not (0 <= s < e <= max_bytes):
                errors.append(f"{rel}: color run {s}-{e} exceeds {max_bytes} bytes")
                break

    if palette and not any(c not in {"#000000", "#ffffff"} for c in palette):
        errors.append(f"{rel}: color spans do not include red/orange black-hole colors")

    return errors


def doc_slug(path: Path) -> str:
    rel = path.relative_to(ROOT / "docs" / "src" / "content" / "docs").with_suffix("")
    parts = list(rel.parts)
    if parts and parts[-1] == "index":
        parts = parts[:-1]
    suffix = "/".join(parts)
    return "/blak.nvim/" + (suffix + "/" if suffix else "")


def check_docs_links() -> list[str]:
    docs_root = ROOT / "docs" / "src" / "content" / "docs"
    source_root = ROOT / "docs" / "src"
    if not docs_root.exists() or not source_root.exists():
        return []

    slugs = {
        doc_slug(path)
        for path in docs_root.rglob("*")
        if path.suffix in {".md", ".mdx", ".mdoc"}
    }

    errors: list[str] = []
    for path in source_root.rglob("*"):
        if path.suffix not in {".astro", ".md", ".mdx", ".mjs", ".ts"}:
            continue
        text = path.read_text(encoding="utf-8")
        for match in DOCS_LINK_RE.finditer(text):
            target = (match.group(1) or match.group(2) or "").strip()
            normalized = target.strip("/")
            slug = "/blak.nvim/" + (normalized + "/" if normalized else "")
            if slug not in slugs:
                errors.append(f"{path.relative_to(ROOT)}: broken docs link {slug}")
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
    errors.extend(check_docs_links())

    for rel in [
        "README.md",
        "MANIFESTO.md",
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
    ]
    legacy_regexes = [
        re.compile(r":Black(?!Extras\b)"),
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
        for pattern in legacy_regexes:
            if pattern.search(text):
                errors.append(f"{path.relative_to(ROOT)}: legacy Black identifier remains: {pattern.pattern}")

    if errors:
        print("Validation failed:", file=sys.stderr)
        for err in errors:
            print("- " + err, file=sys.stderr)
        return 1

    print(f"Validation passed: {len(LUA)} Lua files, {len(seen)} extras")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
