#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Initialize Git LFS for this repository.

This script will:
  1. Check if git-lfs is installed, and install it if missing
  2. Configure Git LFS for this repository
  3. Fetch LFS-tracked files (if available)

Usage: $0 [--help]

This repository uses Git LFS to track large files:
  - *.omod files (OpenMRS modules)
  - *.sql files (database initialization scripts)

Files tracked by LFS are defined in .gitattributes
EOF
    exit 0
fi

# Function to print colored messages
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository. Please run this script from the repository root."
    exit 1
fi

info "Initializing Git LFS for this repository..."

# Check if git-lfs is installed
if ! command -v git-lfs &> /dev/null; then
    warning "git-lfs is not installed. Attempting to install..."
    
    # Detect OS and install git-lfs
    OS="$(uname -s)"
    case "${OS}" in
        Linux*)
            if command -v apt-get &> /dev/null; then
                info "Installing git-lfs via apt-get (requires sudo)..."
                sudo apt-get update && sudo apt-get install -y git-lfs
            elif command -v yum &> /dev/null; then
                info "Installing git-lfs via yum (requires sudo)..."
                sudo yum install -y git-lfs
            elif command -v dnf &> /dev/null; then
                info "Installing git-lfs via dnf (requires sudo)..."
                sudo dnf install -y git-lfs
            elif command -v pacman &> /dev/null; then
                info "Installing git-lfs via pacman (requires sudo)..."
                sudo pacman -S --noconfirm git-lfs
            else
                error "Could not detect package manager. Please install git-lfs manually:"
                error "  Visit: https://git-lfs.github.com/"
                exit 1
            fi
            ;;
        Darwin*)
            if command -v brew &> /dev/null; then
                info "Installing git-lfs via Homebrew..."
                brew install git-lfs
            else
                error "Homebrew not found. Please install git-lfs manually:"
                error "  brew install git-lfs"
                error "  Or visit: https://git-lfs.github.com/"
                exit 1
            fi
            ;;
        *)
            error "Unsupported operating system: ${OS}"
            error "Please install git-lfs manually: https://git-lfs.github.com/"
            exit 1
            ;;
    esac
    
    success "git-lfs installed successfully"
else
    success "git-lfs is already installed ($(git-lfs version | head -n1))"
fi

# Initialize git-lfs for this repository
info "Configuring git-lfs for this repository..."
if git lfs install; then
    success "Git LFS initialized successfully"
else
    error "Failed to initialize git-lfs"
    exit 1
fi

# Check if there are LFS files to pull
info "Checking for LFS files in current branch..."
LFS_FILES=$(git lfs ls-files 2>/dev/null || true)
if echo "$LFS_FILES" | grep -q .; then
    info "Found LFS files. Fetching LFS content..."
    if git lfs pull; then
        success "LFS files fetched successfully"
    else
        warning "Some LFS files may not have been fetched. This is normal if you don't have access to the LFS storage."
    fi
else
    info "No LFS files found in current branch (this is normal for new clones or branches without LFS files)"
fi

success "Git LFS setup complete!"
info "This repository uses Git LFS to track large files (*.omod and *.sql files)."
info "Files tracked by LFS are defined in .gitattributes"
