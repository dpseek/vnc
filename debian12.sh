#!/bin/bash

##### SPECIAL FOR DEBIAN 12 #####

################################################################################################################################################
#### INSTALL XRDP  #### ---------------------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

apt update -y
apt install -y task-gnome-desktop

apt install xrdp -y
systemctl start xrdp
systemctl enable xrdp

ufw allow 3389/tcp
ufw allow 2222/tcp

((COMPLETED_STEPS++))
send_progress_message "$((COMPLETED_STEPS * 100 / TOTAL_STEPS))"

################################################################################################################################################
#### INSTALL SOME SOFTWARE ON DEBIAN 12 #### ------------------------------------------------------------------------------------------- #######
################################################################################################################################################

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sublimehq-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
sudo apt-get update
sudo apt-get install sublime-text

################################################################################################################################################
#### INSTALL SOME DEPENDENCIES:) #### -------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

# Install Chromium
echo "Installing Chromium..."
sudo apt install -y chromium

echo "Chromium installation complete!"

sudo apt install curl -y
sudo apt install nano -y
sudo apt install wget -y
sudo apt install mlocate -y
sudo apt install ccrypt -y

# Install Brave Browser on Debian 12 (Bookworm)
set -e

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt install apt-transport-https curl gnupg -y

# Add Brave Browser's repository key
echo "Adding Brave Browser repository key..."
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

# Add Brave Browser's repository
echo "Adding Brave Browser repository..."
echo "deb [signed-by=/etc/apt/trusted.gpg.d/brave-browser-release.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Update package lists again
echo "Updating package lists again..."
sudo apt update

# Install Brave Browser
echo "Installing Brave Browser..."
sudo apt install brave-browser -y


#### CCRYPT 

sudo apt install ccrypt -y

sleep 3

rm -rf /root/vnc/

################################################################################################################################################
#### BYE BYE  !!! #### ----------------------------------------------------------------------------------------------------------------- #######
################################################################################################################################################
