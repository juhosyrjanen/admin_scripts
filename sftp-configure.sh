#!/bin/bash
#juho@syrjanen.org

logfile="/var/log/valtti-sftp.log"
timestamp=`date "+%Y-%m-%d %H:%M:%S"`
sshconf=/etc/ssh/sshd_config
conf=sftpuser
green=`tput setaf 2`
reset=`tput sgr0`



#Root check
if ! [ $(id -u) = 0 ]; then
   echo "Please run as sudo."
   exit 1
fi

echo "This script will configure server to use SFTP service. Use for new servers only!"
echo -e
echo "Checking if configuration is already in place..."

if grep -q "$conf" "$sshconf"; then
  echo "Configuration is in place or similar exists. Exiting."
  exit 1
else 
  echo "No existing configuration detected. Resuming.."
fi

echo -e "Creating backup of sshd_config."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
echo "To revert configuration run following command manually: cp /etc/ssh/sshd_confif.bak /etc/ssh/sshd_config"
echo -e

#Remove default sftp conf
sed -i '/Subsystem/d' /etc/ssh/sshd_config

##Create standard SFTP service configuration in sshd.conf
cat <<EOF >> /etc/ssh/sshd_config
Subsystem   sftp    internal-sftp 
    Match Group sftpuser 
    ForceCommand internal-sftp 
    ChrootDirectory /sftp/%u 
    X11Forwarding no 
    AllowTcpForwarding no
EOF

#Create sftp directories and set permissions
mkdir /sftp
chown root:root /sftp
chmod 755 /sftp

#Create SFTP group
groupadd sftpuser

#Restarting SSH
systemctl restart sshd

#print success message :)
echo "======="
echo "${green}SFTP service configured. ${reset}"
echo "Use useradd script to confirm configuration."
echo -e
echo "======="

#logging action
touch $logfile
id=$(whoami) 
echo "$timestamp SFTP configuration script run by $id." >> $logfile

