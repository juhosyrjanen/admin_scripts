#!/bin/bash
#juho@syrjanen.org

logfile="/var/log/sftp.log"
timestamp=`date "+%Y-%m-%d %H:%M:%S"`

#Root check
if ! [ $(id -u) = 0 ]; then
   echo "Please run as sudo."
   exit 1
fi

#text color variables
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

## Set username variable
echo -e "--- ${green}Valtti ${reset}SFTP service ---"
echo -e "This script will create an SFTP user for new SFTP client."
echo
echo -e "Enter new SFTP client username and press [ENTER] or to exit without changes press CTRL+C"
read username
echo

#check if user already exists
if id "$username" &>/dev/null; then
    echo 'User '$username' already exists.'
    exit
fi

# Generating password for new user
echo -e "Generating random password for user "$username".."
pw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
sleep 2
echo -e "...."

#Add user with username variable
useradd $username
#Set password for user
echo $username:$pw | chpasswd
#Set SFTP-group for user
usermod -aG sftpuser $username

#Create necessary folders  for chroot jail
echo
echo -e "Creating SFTP folders for " $username".."
mkdir /sftp/$username

while true; do
    read -p "Create read-only user? [Y/N] ?" yn
    case $yn in
        [Nn]* ) mkdir /sftp/$username/uploads && cd /sftp/$username && chown $username:$username uploads; echo "SFTP user "$username "has been created with the following password:" $pw && sleep 2 ; exit;;
        [Yy]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "SFTP read-only user "$username "has been created with the following password:" $pw
echo

#logging action
touch $logfile
id=$(whoami) 
echo "$timestamp useradd script run by $id." >> $logfile
echo "Added user $username." >> $logfile

sleep 2
