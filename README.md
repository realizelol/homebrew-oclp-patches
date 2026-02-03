# Homebrew OCLP Patches

Fixes for Homebrew cask utilities on macOS with OpenCore Legacy Patcher (OCLP).

## Issue

On OCLP systems, Swift's `CommandLine.arguments` incorrectly includes `swift-frontend` internal flags instead of stripping them, breaking `quarantine.swift`, `copy-xattrs.swift`, and `trash.swift`.

## Apply
```bash
cd /usr/local/Homebrew && git apply ~/homebrew-oclp-patches/homebrew-oclp.patch
```

Or one-liner:
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/homebrew-oclp-patches/main/homebrew-oclp.patch | git -C /usr/local/Homebrew apply
```

## Persist across `brew update`
```bash
cat << 'HOOK' > /usr/local/Homebrew/.git/hooks/post-merge
#!/bin/bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/homebrew-oclp-patches/main/homebrew-oclp.patch | git -C /usr/local/Homebrew apply 2>/dev/null && echo "OCLP patches restored"
HOOK
chmod +x /usr/local/Homebrew/.git/hooks/post-merge
```

## Environment tested

- macOS: 15.6.1 (24G90)
- Homebrew: 5.0.13
- Xcode: 26.2
- Swift: 6.2.3
- OpenCore Legacy Patcher
