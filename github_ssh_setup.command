#!/usr/bin/env bash

# GitHub + SSH Setup Script (macOS .command + Linux)
# macOS: double-click in Finder, or run: bash github_ssh_setup.command
# Author: Vishal
# Installs Git, configures Git, generates an SSH key,
# and prepares the system for GitHub SSH usage.

set -euo pipefail

echo "=============================="
echo " GitHub SSH Setup Script"
echo "=============================="

# 0. Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)  PLATFORM="linux" ;;
    Darwin*) PLATFORM="macos" ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac
echo "Detected platform: $PLATFORM"
echo

# 1. Install Git
echo "[1/7] Checking Git installation..."
if command -v git >/dev/null 2>&1; then
    echo "Git is already installed."
else
    if [ "$PLATFORM" = "macos" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install git
        else
            echo "Homebrew not found. Triggering Xcode Command Line Tools install (includes Git)..."
            xcode-select --install || true
            echo "Finish the installer popup, then re-run this script."
            exit 1
        fi
    else
        if command -v apt >/dev/null 2>&1; then
            sudo apt update
            sudo apt install git openssh-client -y
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install git openssh-clients -y
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm git openssh
        else
            echo "No supported package manager found (apt/dnf/pacman). Install Git manually."
            exit 1
        fi
    fi
fi

echo "Git version:"
git --version
echo

# 2. Configure Git
echo "[2/7] Configuring Git..."
read -r -p "Enter your GitHub username: " GIT_NAME
read -r -p "Enter your GitHub email: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "Git configured successfully."
echo

# 3. Generate SSH Key
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    echo "[3/7] SSH key already exists at $SSH_KEY"
else
    echo "[3/7] Generating SSH key..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"
fi
echo

# 4. Set correct permissions
echo "[4/7] Setting SSH permissions..."
chmod 600 "$SSH_KEY"
chmod 644 "$SSH_KEY.pub"
echo

# 5. Start SSH agent and add key
echo "[5/7] Starting SSH agent and adding key..."
eval "$(ssh-agent -s)" >/dev/null

if [ "$PLATFORM" = "macos" ]; then
    # Persist the key + passphrase in the macOS Keychain
    SSH_CONFIG="$SSH_DIR/config"
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"

    if ! grep -q "UseKeychain yes" "$SSH_CONFIG"; then
        cat >> "$SSH_CONFIG" <<EOF

Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
        echo "Added Keychain settings to $SSH_CONFIG"
    fi

    # Newer macOS uses --apple-use-keychain; older versions use -K
    ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add -K "$SSH_KEY" || ssh-add "$SSH_KEY"
else
    ssh-add "$SSH_KEY"
fi
echo

# 6. Display public key
echo "[6/7] Copy the SSH public key below and add it to GitHub:"
echo "--------------------------------------------"
cat "$SSH_KEY.pub"
echo "--------------------------------------------"

# Try to copy to clipboard automatically
if [ "$PLATFORM" = "macos" ]; then
    pbcopy < "$SSH_KEY.pub" && echo "(Public key copied to clipboard)"
elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy < "$SSH_KEY.pub" && echo "(Public key copied to clipboard)"
elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard < "$SSH_KEY.pub" && echo "(Public key copied to clipboard)"
fi

echo "GitHub → Settings → SSH and GPG keys → New SSH key"
echo

# 7. Test GitHub connection
read -r -p "Press ENTER after adding the key to GitHub..."

echo "[7/7] Testing GitHub SSH connection..."
# Auto-accept GitHub's host key on first connect; exit code 1 is normal on success
ssh -o StrictHostKeyChecking=accept-new -T git@github.com || true

echo
echo "=============================="
echo " Setup Complete"
echo "=============================="
echo "You can now use: git clone, git pull, git push"

# When double-clicked from Finder, keep the Terminal window open
if [ "$PLATFORM" = "macos" ] && [ -t 0 ]; then
    echo
    read -r -p "Press ENTER to close this window..."
fi
