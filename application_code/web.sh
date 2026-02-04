#!/bin/bash
set -euo pipefail

WEB_USER="ubuntu"
HOME_DIR="/home/$WEB_USER"
APP_REPO="$HOME_DIR/terraform-project-vpc-alb-modules-workspace"
WEB_DIR="$HOME_DIR/web_files"

echo "========== Setting permissions =========="
sudo chown -R $WEB_USER:$WEB_USER "$HOME_DIR"
sudo chmod -R 755 "$HOME_DIR"

echo "========== Copying web_files =========="
cp -rf "$APP_REPO/application_code/web_files" "$WEB_DIR"

sudo chown -R $WEB_USER:$WEB_USER "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

echo "========== Running build as $WEB_USER =========="
sudo -u $WEB_USER bash <<EOF
set -euo pipefail

# Load NVM environment
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"

cd "$WEB_DIR"

echo "📦 Installing dependencies..."
npm install

echo "🚀 Building frontend app..."
npm run build
EOF

echo "✅ Frontend build complete."
