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
echo -e "--- ${green}SFTP ${reset} service ---"
echo -e "This script will delete SFTP user and all its files."
echo
echo -e "Enter new SFTP user's username and press [ENTER] or to exit without changes press CTRL+C"
read username
echo

if id "$username" &>/dev/null; then
    echo 'User '$username' found.'
else
    echo 'User '$username' not found! Exiting..'
    exit
fi

echo -e 

while true; do
    read -p "Delete user "$username" and all its files? ${red}THIS IS A PERMANENT ACTION! ${reset}[yes/no]? " yn
    case $yn in
        [Yy]* ) userdel $username && rm -rf /sftp/$username ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e 
sleep 1
echo "${green}User "$username" and its files have been deleted. ${reset}"

#logging action
touch $logfile
id=$(whoami) 
echo "$timestamp userdel script run by $id." >> $logfile
echo "removed user $username." >> $logfile
