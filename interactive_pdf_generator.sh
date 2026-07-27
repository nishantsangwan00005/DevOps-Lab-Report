#!/bin/bash
# ==============================================================================
# Interactive Pandoc PDF Generator for DevOps Lab Manuals (WSL / macOS)
# ==============================================================================

echo "========================================================"
echo " Interactive Pandoc PDF Generator (WSL / macOS)"
echo "========================================================"

read -p "Enter GitHub Username [default: nishantsangwan00005]: " GH_USER
GH_USER=${GH_USER:-nishantsangwan00005}

read -p "Enter GitHub Repo Name [default: DevOps-Lab-Report]: " GH_REPO
GH_REPO=${GH_REPO:-DevOps-Lab-Report}

PAGES_URL="https://${GH_USER}.github.io/${GH_REPO}/"
echo "Target GitHub Pages URL: $PAGES_URL"

echo ""
echo "Select PDF Engine Method:"
echo "1) Convert Local Markdown (README.md) to PDF using Pandoc"
echo "2) Download & Convert Live GitHub Pages URL to PDF"
read -p "Selection [1 or 2]: " CHOICE

if [ "$CHOICE" == "2" ]; then
    if ! command -v wkhtmltopdf &> /dev/null; then
        echo "Installing wkhtmltopdf..."
        sudo apt update && sudo apt install -y wkhtmltopdf
    fi
    wkhtmltopdf "$PAGES_URL" "${GH_REPO}_Pages.pdf"
    echo "Saved PDF to ${GH_REPO}_Pages.pdf"
else
    if ! command -v pandoc &> /dev/null; then
        echo "Installing pandoc..."
        sudo apt update && sudo apt install -y pandoc weasyprint
    fi
    pandoc README.md -o "${GH_REPO}_Pandoc.pdf" --toc
    echo "Saved PDF to ${GH_REPO}_Pandoc.pdf"
fi

echo "Process Finished Successfully!"
