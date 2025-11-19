#!/usr/bin/env python3

"""Generate a Firebase CLI import bundle for recipesv1."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create Firestore import JSON from a newline-delimited titles file.",
    )
    parser.add_argument(
        "--input",
        required=True,
        type=Path,
        help="Path to the recipe titles text file (one title per line).",
    )
    parser.add_argument(
        "--output",
        required=True,
        type=Path,
        help="Path to write the Firestore import JSON file.",
    )
    parser.add_argument(
        "--collection",
        default="recipesv1",
        help="Root collection name to generate (default: recipesv1).",
    )
    return parser.parse_args()


def slurp_titles(path: Path) -> list[str]:
    if not path.exists():
        raise FileNotFoundError(f"Input file not found: {path}")
    with path.open("r", encoding="utf-8") as handle:
        return [line.strip() for line in handle if line.strip()]


def build_documents(titles: list[str]) -> dict[str, dict[str, object]]:
    now = datetime.now(timezone.utc).isoformat()
    documents: dict[str, dict[str, object]] = {}

    for index, title in enumerate(titles):
        document_id = f"recipe_{index:06d}"
        lower = title.lower()
        words = [word for word in lower.split() if len(word) > 2]

        documents[document_id] = {
            "title": {"stringValue": title},
            "createdAt": {"timestampValue": now},
            "titleLower": {"stringValue": lower},
            "titleWords": {
                "arrayValue": {
                    "values": [{"stringValue": word} for word in words]
                }
            },
        }

    return documents


def write_bundle(path: Path, collection: str, documents: dict[str, dict[str, object]]) -> None:
    bundle = {"__collections__": {collection: {"documents": documents}}}
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(bundle, handle, indent=2, ensure_ascii=False)


def main() -> None:
    args = parse_args()
    titles = slurp_titles(args.input)
    documents = build_documents(titles)
    write_bundle(args.output, args.collection, documents)
    print(f"Created import bundle with {len(documents)} recipes → {args.output}")


if __name__ == "__main__":
    main()
