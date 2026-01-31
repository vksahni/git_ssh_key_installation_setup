#!/bin/bash

# GitHub + SSH Setup Script (Linux)
# Author: Vishal
# This script installs Git, configures Git, generates SSH keys,
# and prepares the system for GitHub SSH usage.

set -e

echo "=============================="
echo " GitHub SSH Setup Script"
echo "=============================="

# 1. Install Git
echo "[1/7] Installing Git..."
sudo apt update
sudo apt install git -y

echo "Git version:"
git --version
echo

# 2. Configure Git
read -p "Enter your GitHub username: " GIT_NAME
read -p "Enter your GitHub email: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "Git configured successfully."
echo

# 3. Generate SSH Key
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists at $SSH_KEY"
else
    echo "[3/7] Generating SSH key..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"
fi
echo

# 4. Set correct permissions
echo "[4/7] Setting SSH permissions..."
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
echo

# 5. Start SSH agent and add key
echo "[5/7] Starting SSH agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo

# 6. Display public key
echo "[6/7] Copy the SSH public key below and add it to GitHub:"
echo "--------------------------------------------"
cat ~/.ssh/id_ed25519.pub
echo "--------------------------------------------"
echo "GitHub → Settings → SSH and GPG keys → New SSH key"
echo

# 7. Test GitHub connection
read -p "Press ENTER after adding the key to GitHub..."

echo "[7/7] Testing GitHub SSH connection..."
ssh -T git@github.com || true

echo
echo "=============================="
echo " Setup Complete"
echo "=============================="
echo "You can now use: git clone, git pull, git push"
