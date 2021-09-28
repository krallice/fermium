#!/bin/bash

# Install Deps:
echo "Installing Deps" | systemd-cat -t deploy-fermium
apt update -y
apt install python3.8-venv net-tools -y

# Install Python Environment:
echo "Creating Python Environment" | systemd-cat -t deploy-fermium
mkdir -v /fermium
cd /fermium
python3 -m venv ./venv
. ./venv/bin/activate

# Install Flask
echo "Installing Flask and PyYaml" | systemd-cat -t deploy-fermium
pip install flask
pip install pyyaml

# Grab Code:
echo "Grabbing Code" | systemd-cat -t deploy-fermium
curl https://raw.githubusercontent.com/krallice/fermium/master/fermium/main.py -o ./main.py

# Run:
echo "Running Fermium" | systemd-cat -t deploy-fermium
export FLASK_APP="main"; flask run --host="0.0.0.0" --port="80" &
