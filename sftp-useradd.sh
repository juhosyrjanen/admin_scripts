#!/bin/bash

#Root check
if ! [ $(id -u) = 0 ]; then
   echo "Please run as sudo."
   exit 1
fi

##set variables prior to running

sftpgroup=sftpuser
#path without /
mountpoint=sftp

## Set username variable
echo -e "--- **** SFTP service ---"
echo -e "This script will create an SFTP user for new SFTP client."
echo
echo -e "Enter new SFTP client username and press [ENTER] or to exit without changes press CTRL+C"
read username
echo

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
usermod -aG $sftpgroup $username

#Create necessary folders  for chroot jail
echo
echo -e "Creating SFTP folders for " $username".."
mkdir /$mountpoint/$username
mkdir /$mountpoint/$username/uploads

#Set correct permissions for uploads-folder, sftp chroot jail forbids write on chroot, user must write in uploads-folder.
chown $username:$username /$mountpoint/$username/uploads

echo
echo -e " - - -"
echo "SFTP user "$username "has been created with the following password:" $pw
echo -e " - - -"
sleep 2
exit
