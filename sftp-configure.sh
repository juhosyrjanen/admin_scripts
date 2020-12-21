##!/bin/bash
#juho@syrjanen.org

logfile="/var/log/sftp.log"
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
#Root checks ends

#notify
echo "This script will configure server to use Valtti SFTP service. Use for new servers only!"
echo -e
echo "Checking if configuration is already in place..."

#Conf check starts
if grep -q "$conf" "$sshconf"; then
  echo "Configuration is in place or similar exists. Exiting."
  exit 1
else 
  echo "No existing configuration detected. Resuming.."
fi
#Conf check ends

#user confirmation
while true; do
    read -p "Configure this server to use Valtti SFTP service? [yes/no]? " yn
    case $yn in
        [Yy]* ) echo "Starting config.."; break;;
        [Nn]* ) echo "Exiting.."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Backup starts
sleep 1
echo -e "Creating backup of sshd_config."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sleep 1
echo "To revert configuration run following command manually: cp /etc/ssh/sshd_confif.bak /etc/ssh/sshd_config"
echo -e
sleep 1
#Backup ends

#OS check starts
distrocheck=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

if [[ $distrocheck == *"centos"* ]]; then
  echo "Running CentOS.."
  os=rhel
elif [[ $distrocheck == *"ubuntu"* ]]; then
  echo "Running Ubuntu.."  
  os=ubuntu
elif [[ $distrocheck == *"rhel"* ]]; then
  echo "Running RHEL.."  
  os=rhel
elif [[ $distrocheck == *"debian"* ]]; then
  echo "Running Debian.."  
  os=deb
fi
#OS check ends

echo -e 
echo "Running firewall configuration.."
#Firewall configuration starts
#assuming ubuntu runs ufw, rhel/centos firewalld, debian iptables..
if [[ $os == *"rhel"* ]] && [ -e /bin/firewall-cmd ]; then
  firewall-cmd --permanent --add-service=ssh
  systemctl enable firewalld
  systemctl restart firewalld
elif [[ $os == *"ubuntu"* ]]; then
  ufw allow ssh
  echo "y" | sudo ufw enable
elif [[ $distrocheck == *"debian"* ]] && [ -e /etc/sysconfig/iptables ]; then
  	iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
	/sbin/service iptables save
fi
#Firewall configuration ends

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

echo "Checking if /sftp folder already exists.."
if [ -d "/sftp" ] 
then
    echo "/sftp exists. Setting permissions.." 
    chown root:root /sftp
    chmod 755 /sftp

else
    echo "/sftp does not exist, creating and setting permissions.."
    mkdir /sftp
    chown root:root /sftp
    chmod 755 /sftp
fi

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
