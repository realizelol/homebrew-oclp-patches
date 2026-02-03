#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMEBREW_DIR="/usr/local/Homebrew"
PATCH_FILE="$SCRIPT_DIR/homebrew-oclp.patch"
PATCH_URL="https://raw.githubusercontent.com/ajorpheus/homebrew-oclp-patches/master/homebrew-oclp.patch"

echo "=== Homebrew OCLP Patch Installer ==="
echo ""

# Check if Homebrew exists
if [[ ! -d "$HOMEBREW_DIR" ]]; then
    echo "Error: Homebrew not found at $HOMEBREW_DIR"
    exit 1
fi

# Apply patch
echo "[1/4] Applying OCLP patch..."
if git -C "$HOMEBREW_DIR" apply --check "$PATCH_FILE" 2>/dev/null; then
    git -C "$HOMEBREW_DIR" apply "$PATCH_FILE"
    echo "  ✓ Patch applied successfully"
else
    if grep -q "swift-frontend" "$HOMEBREW_DIR/Library/Homebrew/cask/utils/quarantine.swift" 2>/dev/null; then
        echo "  ✓ Patch already applied"
    else
        echo "  ✗ Patch failed - trying to reset and reapply..."
        git -C "$HOMEBREW_DIR" checkout Library/Homebrew/cask/utils/
        git -C "$HOMEBREW_DIR" apply "$PATCH_FILE"
        echo "  ✓ Patch applied after reset"
    fi
fi

# Hide changes from git status
echo "[2/4] Hiding changes from git status..."
git -C "$HOMEBREW_DIR" update-index --assume-unchanged Library/Homebrew/cask/utils/copy-xattrs.swift
git -C "$HOMEBREW_DIR" update-index --assume-unchanged Library/Homebrew/cask/utils/quarantine.swift
git -C "$HOMEBREW_DIR" update-index --assume-unchanged Library/Homebrew/cask/utils/trash.swift
echo "  ✓ Changes hidden from git"

# Install shell wrapper
echo "[3/4] Installing shell wrapper..."
ZSHRC="$HOME/.zshrc"
WRAPPER='
# Homebrew OCLP patch - auto-reapply after brew update
brew() {
    command brew "$@"
    local ret=$?
    if [[ "$1" == "update" ]]; then
        curl -sL "https://raw.githubusercontent.com/ajorpheus/homebrew-oclp-patches/master/homebrew-oclp.patch" | git -C /usr/local/Homebrew apply 2>/dev/null && echo "OCLP patches restored"
    fi
    return $ret
}'

if grep -q "Homebrew OCLP patch" "$ZSHRC" 2>/dev/null; then
    echo "  ✓ Shell wrapper already installed"
else
    echo "$WRAPPER" >> "$ZSHRC"
    echo "  ✓ Shell wrapper added to ~/.zshrc"
fi

# Verify installation
echo "[4/4] Verifying installation..."
PASS=true

if grep -q "swift-frontend" "$HOMEBREW_DIR/Library/Homebrew/cask/utils/copy-xattrs.swift"; then
    echo "  ✓ copy-xattrs.swift patched"
else
    echo "  ✗ copy-xattrs.swift NOT patched"
    PASS=false
fi

if grep -q "swift-frontend" "$HOMEBREW_DIR/Library/Homebrew/cask/utils/quarantine.swift"; then
    echo "  ✓ quarantine.swift patched"
else
    echo "  ✗ quarantine.swift NOT patched"
    PASS=false
fi

if grep -q "swift-frontend" "$HOMEBREW_DIR/Library/Homebrew/cask/utils/trash.swift"; then
    echo "  ✓ trash.swift patched"
else
    echo "  ✗ trash.swift NOT patched"
    PASS=false
fi

# Test brew doctor
echo ""
echo "Running brew doctor..."
if brew doctor 2>&1 | grep -q "No Cask quarantine support"; then
    echo "  ✗ brew doctor still shows quarantine error"
    PASS=false
else
    echo "  ✓ No quarantine errors in brew doctor"
fi

echo ""
if $PASS; then
    echo "=== Installation complete! ==="
    echo ""
    echo "Run 'source ~/.zshrc' or restart your terminal to enable auto-patching."
else
    echo "=== Installation had issues ==="
    exit 1
fi
