#!/bin/bash
set -euo pipefail

echo "📦 Updating package index and installing base packages..."
sudo apt update -y
sudo apt install -y \
  git \
  curl \
  ca-certificates \
  gnupg \
  lsb-release

# -----------------------------
# MySQL Client (Ubuntu official)
# -----------------------------
echo "📦 Installing MySQL client..."
sudo apt install -y mysql-client

# -----------------------------
# NVM + Node.js 22
# -----------------------------
echo "📦 Installing NVM (Node Version Manager)..."
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

echo "📦 Installing Node.js v22 via NVM..."
nvm install 22
nvm use 22
nvm alias default 22

echo "📦 Installing PM2..."
npm install -g pm2

# -----------------------------
# Verify installations
# -----------------------------
echo "📦 Verifying installations..."
node -v
npm -v
pm2 -v
mysql --version

echo "✅ Ubuntu Backend AMI preparation complete!"
