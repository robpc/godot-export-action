#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


def parse_versions_file(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(f"versions file '{path}' not found")
    data: dict[str, object] = {}
    current_key: str | None = None
    with path.open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.rstrip("\n")
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if stripped.startswith("- "):
                if current_key is None:
                    raise ValueError(f"List item found without key in line: {line}")
                data.setdefault(current_key, [])
                value = stripped[2:].strip().strip("\"'")
                (data[current_key]).append(value)  # type: ignore[index]
                continue
            if ":" in stripped:
                key, value = stripped.split(":", 1)
                key = key.strip()
                value = value.strip()
                if value:
                    data[key] = value.strip("\"'")
                    current_key = None
                else:
                    data[key] = []
                    current_key = key
                continue
            raise ValueError(f"Unsupported line in versions file: {line}")
    return data


def normalize_bool(value: object) -> bool:
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def find_versions_files(root: Path) -> list[Path]:
    candidates: list[Path] = []
    for candidate in [
        root / "godot4" / "versions.yml",
        root / "godot3" / "versions.yml",
        root / "versions.yml",
    ]:
        if candidate.is_file():
            candidates.append(candidate)
    return candidates


def compute_supported_versions(files: list[Path]) -> tuple[list[str], str | None]:
    supported: list[str] = []
    example_version: str | None = None

    for file_path in files:
        data = parse_versions_file(file_path)
        versions = [str(v) for v in data.get("versions", [])]
        supported.extend(versions)

        provides_latest = normalize_bool(data.get("provides_latest", False))
        latest = str(data.get("latest", versions[0] if versions else "")).strip()
        if provides_latest and latest:
            example_version = latest

    if example_version is None and supported:
        example_version = supported[0]

    return supported, example_version


def format_supported_versions(versions: list[str]) -> str:
    if not versions:
        return ""
    refs = [f"`v{v}`" for v in versions]
    if len(refs) == 1:
        return refs[0]
    if len(refs) == 2:
        return f"{refs[0]} and {refs[1]}"
    return f"{', '.join(refs[:-1])} and {refs[-1]}"


def replace_between_markers(text: str, marker: str, replacement: str) -> str:
    start = f"<!-- {marker}:start -->"
    end = f"<!-- {marker}:end -->"

    start_index = text.find(start)
    end_index = text.find(end)
    if start_index == -1 or end_index == -1 or end_index < start_index:
        raise SystemExit(f"Missing or malformed markers for '{marker}' in README")

    content_start = start_index + len(start)
    return text[:content_start] + "\n" + replacement.rstrip("\n") + "\n" + text[end_index:]


def replace_action_uses_version(text: str, version: str) -> str:
    pattern = re.compile(r"(uses:\s*robpc/godot-export-action@)v[0-9][0-9A-Za-z._-]*")
    return pattern.sub(rf"\g<1>v{version}", text)


def main() -> int:
    root = Path(".")
    readme_path = root / "README.md"
    if not readme_path.is_file():
        raise SystemExit("README.md not found")

    versions_files = find_versions_files(root)
    if not versions_files:
        raise SystemExit("No versions.yml found (expected versions.yml or godot*/versions.yml)")

    supported_versions, example_version = compute_supported_versions(versions_files)
    supported_versions_text = format_supported_versions(supported_versions)

    original = readme_path.read_text(encoding="utf-8")
    updated = original
    updated = replace_between_markers(updated, "supported-versions", supported_versions_text)

    if example_version:
        updated = replace_action_uses_version(updated, example_version)

    if updated != original:
        readme_path.write_text(updated, encoding="utf-8")

    return 0


if __name__ == "__main__":
    sys.exit(main())
