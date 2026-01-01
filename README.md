# terraform-project-vpc-alb-modules-workspace



sudo apt update
sudo apt install python3-pip python3-venv -y


python3.14 -m  venv ~/pip

source ~/pip/bin/activate

pip3 install checkov

checkov -d .
checkov -d . -o json > checkov-report.json
