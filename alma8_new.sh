#!/bin/bash


################################################################################################################################################
#### SPECIAL FOR ALMALINUX 8 #### --------------------------------------------------------------------------------------------------- ##_2024_##
################################################################################################################################################


################################################################################################################################################
#### INSTALL SOME DEPENDENCIES:) #### -------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

# sudo dnf update -y  # Remove sudo, running as root
# sudo dnf upgrade -y  # Remove sudo, running as root

/usr/bin/crb enable

yum -y install epel-release
yum -y install terminator
yum -y install expect
yum -y install curl
yum -y install wget
yum -y install git
yum -y install jq

timedatectl set-timezone Europe/Paris

################################################################################################################################################
#### CHANGE SSH PORT TO 4477 AND SET HOSTNAME #### ------------------------------------------------------------------------------------- #######
################################################################################################################################################

NEW_SSH_PORT=4477

cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
sed -i "s/#Port 22/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config

# Wait for firewalld to be active
until systemctl is-active firewalld; do
  echo "Waiting for firewalld to start..."
  sleep 2
done

firewall-cmd --zone=public --add-port=$NEW_SSH_PORT/tcp --permanent
firewall-cmd --reload

systemctl restart firewalld # Redundant but safe

####### SET HOSTNAME #######
SERVER_IP=$(hostname -I | awk '{print $1}')
hostnamectl set-hostname ${SERVER_IP}.myworld.com
systemctl restart systemd-hostnamed

################################################################################################################################################
#### INSTALL VNC SERVER #### ----------------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

dnf groupinstall "server with GUI" -y  # Remove sudo, running as root
dnf install tigervnc-server -y # Remove sudo, running as root

mkdir -p ~/.vnc/

content=$(cat <<END
session=gnome
geometry=1280x800
localhost
alwaysshared
END
)

echo "$content" > ~/.vnc/config

# Configure the firewall to allow VNC
firewall-cmd --add-service=vnc-server --permanent
firewall-cmd --reload

# Create a new user 'admin' with a predefined password
adduser admin
echo "admin:Money22" | chpasswd  # Set the password for 'admin'

# Grant the 'admin' user passwordless sudo access for specific commands
echo "admin ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/admin_no_password
chmod 440 /etc/sudoers.d/admin_no_password
visudo -c  # Check syntax of sudoers files

# Switch to the 'admin' user environment to configure VNC
su - admin -c <<'EOF'

# Ensure .vnc directory exists
mkdir -p ~/.vnc

# Set the VNC password directly
echo "Money22" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start the VNC server with specified geometry
vncserver :1 -geometry 1280x800

# Create a systemd service for the VNC server
cat <<SERVICE_EOF | sudo tee /etc/systemd/system/vncserver@:1.service >/dev/null
[Unit]
Description=VNC Server
After=network.target

[Service]
Type=forking
User=admin
ExecStart=/usr/bin/vncserver :1 -geometry 1280x800
ExecStop=/usr/bin/vncserver -kill :1

[Install]
WantedBy=multi-user.target
SERVICE_EOF

####### Enable VNC to start on reboot #######
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1.service

EOF


systemctl daemon-reload
systemctl enable --now vncserver@:1.service

################################################################################################################################################
#### SELINUX SSHD #### ----------------------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

semanage port -a -t ssh_port_t -p tcp 4477
systemctl restart sshd.service

################################################################################################################################################
#### FINAL SETUP MESSAGE TO TG #### ---------------------------------------------------------------------------------------------------- #######
################################################################################################################################################



################################################################################################################################################
#### INSTALL SOME SOFTWARE #### -------------------------------------------------------------------------------------------------------- #######
################################################################################################################################################

###### CCRYPT INSTALL ######
wget https://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11-1.x86_64.rpm
rpm -Uvh ccrypt-1.11-1.x86_64.rpm

rm -rf ccrypt-1.11-1.x86_64.rpm

###### SUBLIME TEXT ######
rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg # Remove sudo, running as root
dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo  # Remove sudo, running as root
dnf install sublime-text -y # Remove sudo, running as root

###### LIBRE OFFICE ######
#yum install -y libreoffice

###### GEANY ######
#sudo dnf install geany -y

###### GOOGLE CHROME ######
dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm # Remove sudo, running as root

###### VSCODE ######
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
#sudo dnf install code -y

####### INSTALL SPEEDTEST #######
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | bash # Remove sudo, running as root
yum -y install speedtest # Remove sudo, running as root

#mdkir /root/vscode

################################################################################################################################################
#### DELETE ALL SCRIPTS AND CLEAN UP  #### --------------------------------------------------------------------------------------------- #######
################################################################################################################################################

rm -rf /root/vnc
