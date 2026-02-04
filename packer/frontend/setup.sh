#!/bin/bash
set -euo pipefail

echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "📦 Installing nginx, git, and curl..."
sudo apt install -y nginx git curl

sudo systemctl enable nginx
sudo systemctl start nginx

# -----------------------------
# NVM + Node.js
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

echo "📦 Verifying Node.js installation..."
node -v
npm -v

echo "✅ Frontend AMI preparation complete!"
