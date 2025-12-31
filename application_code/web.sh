#!/bin/bash
set -e   # exit on error

# Download app-tier code


cd /home/ec2-user

sudo chown -R ec2-user:ec2-user /home/ec2-user
sudo chmod -R 755 /home/ec2-user

sudo rm -rf terraform-project-vpc-alb-modules-workspace
git clone https://github.com/harishnshetty/terraform-project-vpc-alb-modules-workspace.git

cp -rf terraform-project-vpc-alb-modules-workspace/application_code/web_files .

cd /home/ec2-user/web_files

# Ensure correct ownership/permissions
sudo chown -R ec2-user:ec2-user /home/ec2-user
sudo chmod -R 755 /home/ec2-user/web_files



# Run build as ec2-user
su - ec2-user <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Sync latest code
# rsync -av --delete ~/terraform-project-vpc-alb-modules-workspace/application_code/web_files/ ~/web_files/
cd /home/ec2-user/web_files
npm install
npm run build
EOF