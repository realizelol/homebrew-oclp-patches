#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMEBREW_DIR="/usr/local/Homebrew"
PATCH_FILE="$SCRIPT_DIR/homebrew-oclp.patch"

# Check if Homebrew exists
if [[ ! -d "$HOMEBREW_DIR" ]]; then
    echo "Error: Homebrew not found at $HOMEBREW_DIR"
    exit 1
fi

# Apply patch
echo "Applying OCLP patch..."
if git -C "$HOMEBREW_DIR" apply --check "$PATCH_FILE" 2>/dev/null; then
    git -C "$HOMEBREW_DIR" apply "$PATCH_FILE"
    echo "✓ Patch applied successfully"
else
    echo "Patch already applied or conflicts exist, skipping..."
fi

# Create post-merge hook
echo "Installing post-merge hook..."
cat << 'HOOK' > "$HOMEBREW_DIR/.git/hooks/post-merge"
#!/bin/bash
PATCH_URL="https://raw.githubusercontent.com/ashj-centrica/homebrew-oclp-patches/main/homebrew-oclp.patch"
curl -sL "$PATCH_URL" | git -C /usr/local/Homebrew apply 2>/dev/null && echo "OCLP patches restored"
HOOK
chmod +x "$HOMEBREW_DIR/.git/hooks/post-merge"
echo "✓ Post-merge hook installed"

# Verify
echo ""
echo "Verifying installation..."
if grep -q "swift-frontend" "$HOMEBREW_DIR/Library/Homebrew/cask/utils/quarantine.swift"; then
    echo "✓ All patches verified"
    brew doctor 2>&1 | grep -i quarantine || echo "✓ No quarantine errors"
else
    echo "✗ Verification failed"
    exit 1
fi

echo ""
echo "Done! Run 'brew doctor' to confirm."
