#!/bin/sh

#Ubuntu Server setup as a Plex Server, x64
#ACL for ssh access to add your media to /media/FOLDERS (set in Plex).
#Smartmontools to monitor HDD/SDD condition.  Auto-schedule set with email via msmtp for early warning.
#Run as root, or with sudo privileges.

echo "Script Initializing..."
sleep 2
#Script downloads Plex first.  Check that the link is still valid before running script.
wget -cO - https://downloads.plex.tv/plex-media-server-new/1.21.2.3943-a91458577/debian/plexmediaserver_1.21.2.3943-a91458577_amd64.deb > plexmediaserver.deb

#If time zone defaults to UTC, this sets it.  Currently Eastern time.
echo "Setting local time zone.."
timedatectl set-timezone America/New_York

#Install necessary packages
echo "Installing packages..."
sleep 2
dpkg -i plexmediaserver.deb
rm plexmediaserver.deb

for package in acl smartmontools mailutils msmtp msmtp-mta; do
	apt-get install $package -y
done

echo "Enabling Plex Respository..."
sleep 2
echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

echo "Creating media directories for Plex..."
sleep 2
mkdir /media/Movies /media/Music /media/Shows

echo "Setting Access Control List for media folders..."
read -p 'Enter username to grant access, other than root: ' varname
setfacl -R -m u:$varname:rwx /media
sleep 2

#Smartmontools via SmartD will be scheduled at /etc/smartd.conf
echo "Setting up SmartD pre-written schedule..."
echo "Confirm email address SmartD error reports should be delivered to:"
read -p 'Email: ' varsend
#sed -i 21's/.*/#&/' /etc/smartd.conf
sed -i '21d' /etc/smartd.conf
sed -i "20 a DEVICESCAN -a -s (S/../.././(02|10|18)|L/../(01|15)/./03|C/../01/./04) -m $varsend -M test" /etc/smartd.conf

#MSMTP initial setup at /etc/msmtprc
echo "Initializing Msmtp setup.."
sleep 2
echo "confirm email provider (EX: gmail, yahoo, etc):"
read -p 'Account: ' varacc
echo "Confirm host SMTP address (EX: smtp.gmail.com):"
read -p 'Host: ' varhost
echo "Input your email address to send mail from:"
read -p 'Email: ' varmail
echo "Input email username login:"
read -p 'Username: ' varuser
echo "Input password for email (use app-generated password if able!):"
read -p 'Password: ' varpass

echo "defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile /var/log/msmtp.log

#Email configuration
account $varacc
host $varhost
port 587
from $varmail
user $varuser
password $varpass

account default: $varacc" >> /etc/msmtprc

echo "If you inputted the previous configuration parameters incorrectly, you can fix at /etc/msmtprc."
echo "Cleanup.."
sleep 2
apt update -y
apt upgrade -y
apt-get clean -y

echo "Script complete.  Rebooting in 10 seconds.  Please wait.."
sleep 10
reboot