#!/bin/bash
set -euo pipefail

echo "========== Updating system & installing dependencies =========="
apt update -y
apt upgrade -y
apt install -y nginx git curl

# -----------------------------
# Use Ubuntu default home
# -----------------------------
WEB_USER="ubuntu"
HOME_DIR="/home/$WEB_USER"

echo "========== Cloning application repository =========="
cd "$HOME_DIR"
git clone https://github.com/86views/terraform-project-vpc-alb-modules-workspace.git || true

echo "========== Copying web.sh =========="
cp -f "$HOME_DIR/terraform-project-vpc-alb-modules-workspace/application_code/web.sh" "$HOME_DIR/web.sh"
chmod +x "$HOME_DIR/web.sh"

echo "========== Preparing nginx.conf =========="
# Replace placeholder BEFORE moving nginx.conf into /etc
sed -i "s|REPLACE-WITH-INTERNAL-LB-DNS|__APP_ALB_DNS__|g" \
    "$HOME_DIR/terraform-project-vpc-alb-modules-workspace/application_code/nginx.conf"

# Backup old config & apply new one
mv /etc/nginx/nginx.conf /etc/nginx/nginx-backup.conf || true
cp -f "$HOME_DIR/terraform-project-vpc-alb-modules-workspace/application_code/nginx.conf" /etc/nginx/nginx.conf

echo "========== Running web.sh =========="
bash "$HOME_DIR/web.sh"

echo "========== Validating nginx configuration =========="
nginx -t

echo "========== Restarting & enabling nginx =========="
systemctl restart nginx
systemctl enable nginx

echo "✅ Web user data setup complete!"
