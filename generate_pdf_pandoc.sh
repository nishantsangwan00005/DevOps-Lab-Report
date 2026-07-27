#!/bin/bash
# ==============================================================================
# DevOps Lab Manual - Pandoc PDF Generator for GitHub Pages (WSL / macOS)
# Author: Nishant Sangwan (nishantsangwan00005)
# ==============================================================================

set -e

echo "=== DevOps Lab Manual PDF Generator (Pandoc WSL/macOS) ==="

# 1. Install Dependencies Check
if ! command -v pandoc &> /dev/null; then
    echo "Pandoc not found. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y pandoc weasyprint wkhtmltopdf texlive-latex-base
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pandoc BasicTeX
    fi
fi

# 2. PDF Generation Configuration
OUTPUT_PDF="DevOps_Lab_Report_Pandoc.pdf"
GITHUB_PAGES_URL="https://nishantsangwan00005.github.io/DevOps-Lab-Report/"

echo "Compiling Markdown to PDF via Pandoc..."

if [ -f "README.md" ]; then
    pandoc README.md -o "$OUTPUT_PDF" \
        --toc \
        --toc-depth=2         --variable margin-left=1in \
        --variable margin-right=1in \
        --variable margin-top=1in \
        --variable margin-bottom=1in \
        --pdf-engine=weasyprint || pandoc README.md -o "$OUTPUT_PDF" --pdf-engine=xelatex || true
    echo "Generated PDF: $OUTPUT_PDF"
fi

if command -v wkhtmltopdf &> /dev/null; then
    echo "Rendering PDF directly from GitHub Pages URL: $GITHUB_PAGES_URL"
    wkhtmltopdf "$GITHUB_PAGES_URL" "GitHub_Pages_Report.pdf" || true
    echo "Generated PDF from URL: GitHub_Pages_Report.pdf"
fi

echo "=== PDF Generation Complete! ==="
