#!/bin/bash

# TCC Project Build Script
# Manages compilation and watch mode for Typst document

set -e

# Configuration
SOURCE_FILE="src/main.typ"
OUTPUT_DIR="build"
OUTPUT_FILE="$OUTPUT_DIR/tcc.pdf"

# Functions
print_help() {
    echo "TCC Project Build Script"
    echo ""
    echo "Usage: ./project.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build       Compile the TCC document once"
    echo "  dev         Watch for changes and auto-compile (development mode)"
    echo "  clean       Remove build artifacts"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./project.sh build    # Compile once"
    echo "  ./project.sh dev      # Start watch mode"
}

check_typst() {
    if ! command -v typst &> /dev/null; then
        echo "Error: typst is not installed"
        echo "Please install typst from: https://github.com/typst/typst"
        exit 1
    fi
}

setup_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo "Created output directory: $OUTPUT_DIR"
    fi
}

build() {
    echo "Building TCC document..."
    setup_output_dir

    if typst compile "$SOURCE_FILE" "$OUTPUT_FILE"; then
        echo "[SUCCESS] Build successful!"
        echo "Output: $OUTPUT_FILE"

        # Show file size
        if [ -f "$OUTPUT_FILE" ]; then
            FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
            echo "File size: $FILE_SIZE"
        fi
    else
        echo "[ERROR] Build failed"
        exit 1
    fi
}

dev() {
    echo "Starting development mode (watch)..."
    echo "Watching for changes in: $SOURCE_FILE"
    echo "Press Ctrl+C to stop"
    echo ""

    setup_output_dir

    # Use typst watch command for auto-compilation
    typst watch "$SOURCE_FILE" "$OUTPUT_FILE"
}

clean() {
    echo "Cleaning build artifacts..."

    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
        echo "[SUCCESS] Removed $OUTPUT_DIR"
    else
        echo "Nothing to clean"
    fi
}

# Main script logic
check_typst

case "${1:-}" in
    build)
        build
        ;;
    dev|watch)
        dev
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        print_help
        ;;
    "")
        echo "[ERROR] No command specified"
        echo ""
        print_help
        exit 1
        ;;
    *)
        echo "[ERROR] Unknown command '$1'"
        echo ""
        print_help
        exit 1
        ;;
esac
