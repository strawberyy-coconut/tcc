#!/bin/sh
# Extract text from a PDF and search for a keyword/phrase
# Usage: ./verify-pdf.sh references/file.pdf "search phrase"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <pdf-file> <search-phrase>"
    exit 1
fi

PDF="$1"
PHRASE="$2"

if [ ! -f "$PDF" ]; then
    echo "Error: PDF not found: $PDF"
    exit 1
fi

if ! command -v pdftotext >/dev/null 2>&1; then
    echo "Error: pdftotext not found. Install poppler-utils."
    exit 1
fi

# Extract text and search (case-insensitive, show 3 lines of context)
pdftotext "$PDF" - | grep -i -C 3 "$PHRASE"

if [ $? -ne 0 ]; then
    echo "Phrase not found in PDF."
    exit 1
fi
