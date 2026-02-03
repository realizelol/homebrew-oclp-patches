# Homebrew OCLP Patches

Fixes for Homebrew cask utilities on macOS with OpenCore Legacy Patcher (OCLP).

## Issue

On OCLP systems running macOS Sequoia, Swift's `CommandLine.arguments` incorrectly includes `swift-frontend` internal flags instead of stripping them. This breaks `quarantine.swift`, `copy-xattrs.swift`, and `trash.swift`.

## Quick Install
```bash
git clone https://github.com/ajorpheus/homebrew-oclp-patches.git
cd homebrew-oclp-patches
./install.sh
source ~/.zshrc
```

## What it does

1. Patches the three affected Swift scripts
2. Hides changes from `git status` / `brew doctor`
3. Adds a shell wrapper to auto-reapply patches after `brew update`

## Manual Apply
```bash
curl -sL https://raw.githubusercontent.com/ajorpheus/homebrew-oclp-patches/master/homebrew-oclp.patch | git -C /usr/local/Homebrew apply
```

## Environment Tested

- macOS: 15.6.1 (24G90)
- Homebrew: 5.0.13
- Xcode: 26.2
- Swift: 6.2.3
- OpenCore Legacy Patcher

## Related

- [Homebrew Issue #18656](https://github.com/Homebrew/brew/issues/18656)
- [Homebrew Discussion #5482](https://github.com/orgs/Homebrew/discussions/5482)
