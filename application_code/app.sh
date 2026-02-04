#!/bin/bash
set -euo pipefail

WEB_USER="ubuntu"
HOME_DIR="/home/$WEB_USER"
APP_DIR="$HOME_DIR/app_files"

echo "========== Ensuring correct ownership and permissions =========="
sudo chown -R $WEB_USER:$WEB_USER "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

echo "========== Running app as $WEB_USER =========="
sudo -u $WEB_USER bash <<EOF
set -euo pipefail

# Load NVM environment
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"

# Load environment variables
if [ -f /etc/profile.d/app_env.sh ]; then
    source /etc/profile.d/app_env.sh
fi

cd "$APP_DIR"

echo "📦 Installing Node.js dependencies..."
npm install @aws-sdk/client-secrets-manager mysql2 aws-sdk
npm install
npm audit fix || true

echo "🚀 Starting app with PM2..."
pm2 start index.js

echo "🔧 Configuring PM2 systemd startup for $WEB_USER..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save
EOF

echo "✅ App started and PM2 configured for reboot."
