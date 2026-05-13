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
