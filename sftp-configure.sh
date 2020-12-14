#!/bin/bash
#juho@syrjanen.org

logfile="/var/log/valtti-sftp.log"
timestamp=`date "+%Y-%m-%d %H:%M:%S"`
sshconf=/etc/ssh/sshd_config
conf=sftpuser

#Root check
if ! [ $(id -u) = 0 ]; then
   echo "Please run as sudo."
   exit 1
fi

echo "This script will configure server to use Valtti SFTP service."
echo -e
echo "Checking if configuration is already in place..."

#simple check if stpuser group already set in sshd_config
if grep -q "$conf" "$sshconf"; then
  echo "Configuration is in place or similar exists. Exiting."
  exit
else 
  echo "No existing configuration detected. Resuming.."
fi

#Remove default sftp conf
sed -i '/Subsystem/d' /etc/ssh/sshd_config

##Create standard SFTP service configuration in sshd.conf
cat <<EOF >> /etc/ssh/sshd_confog
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

