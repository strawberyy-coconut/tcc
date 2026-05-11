#!/bin/sh
# Extract all unique @key citations from a Typst file
# Usage: ./extract-citations.sh src/chapter-2.typ

if [ $# -lt 1 ]; then
    echo "Usage: $0 <typst-file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

# Extract @key citations, sort uniquely
grep -oE '@[a-zA-Z0-9_-]+' "$FILE" | sed 's/^@//' | sort -u
