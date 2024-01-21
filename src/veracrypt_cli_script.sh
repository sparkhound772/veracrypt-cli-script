#!/bin/bash

# Name: veracrypt-cti-script.sh
# Description: Decrypt and mount VeraCrypt containers with the VeraCrypt and Bitwarden command line tools.
# Author: sparklehound
# Last edit: 2024-01-21

global_pass=1
global_bw_pass=1

# The main function which displays the main menu and runs the rest of the script.
main () {
	local choice
	while true;	do
		main_menu
		read choice 
				case "$choice" in
			1)
				general_info
				;;
			2)
				list_mounted_veracrypt
				;;
			3)
				bw sync
				echo
				;;
			4)
				echo
				enter_global_bw_pass
				echo
				echo "*** Remember to close the script when done to remove the password from the computers memory ***"
				echo
				continue
				;;
			5)
				prepare_for_decryption	
				;;
			6|q)
				echo
				echo Bye bye
				echo
				exit
				;;
			*)
				echo
				echo Please enter a digit between 1-5 and press Enter 
				echo
				continue
				;;
		esac
	done
}

# Gathering necessary information for decryption
prepare_for_decryption () {
	echo
	local name
	read -p "Enter the name of the Bitwarden entry for the device (ex. \"usbbackup1\"? " name
	echo
	local slot
	read -p "Enter slot number in Veracrypt to use: " slot
	echo
	while true; do
		local path
		read -p "Enter the file path (absolute or relative) to the drive or container (or type (l)ist to display drives and partitions on the system): " path
		if echo "$path" | grep -qE ^[.~]\?\(\/[^\/]*\)+[^\/]\+
		then
			decrypt_and_mount "$name" "$path" "/mnt/veracrypt$slot" "$slot"
			break
		elif [ "$path" = 'l' ] || [ $path = 'list' ] 
		then
			echo
			lsblk --shell
			echo
			continue
		else
			echo
			echo Unvalid input. Valid examples: \'/dev/sda\', \'./veracrypt_container\'   
			echo
			continue
		fi
	done
}

# Decrypt and mount in VeraCrypt (when there is no hidden volume inside).
# $1 - password name in Bitwarden
# $2 - path to device or container to mount 
# $3 - path to mountpoint
# $4 - slot
decrypt_and_mount () {
	local local_bw_pass
	if [ "$global_pass" -eq 0 ]
	then
		local_bw_pass=global_bw_pass
	else
		echo 
		read -s -p "Enter your BW master password and press Enter (input is silent): " local_bw_pass
		echo
	fi		
	local decryption_pass=$(echo "$local_bw_pass" | bw get password $1)
	echo
	sudo veracrypt --text --mount "$2" "$3" --slot="$4" --password="$decryption_pass" --pim=0 --keyfiles="" --protect-hidden=no --verbose --background-task
	unset $local_bw_pass
	echo "/** If you get a message above here that says:"
	echo "    \"Volume '/path/file' has been dismounted.\""
	echo "    that means success."
	echo "    The message is just a bug with the VeraCrypt program... choose \"2\""
	echo "    in the main menu to see whether it's actually mounted) */"
	echo
}

# The BW master password is prompted for, stored as a global variable,
# and then will be piped to bitwarden-cli to retrieve the decryption password for the volume.
enter_global_bw_pass () {
	read -s -p "Enter your BW master password and press Enter (input is silent): " global_bw_pass
	global_pass=0
	echo
}

# In order to mount the container, the partition where it resides must first be mounted.
# $1 - path to the dir where the container resides
mount_ordinary_partition_first () {
	echo First attemping to mkdir and mount $1 where the container resides, in case it isn\'t already...
	sudo mkdir -p $1
	sudo mount /dev/sda4 $1
}

# List the presently mounted VeraCrypt devices and containers
list_mounted_veracrypt () {
	echo
	echo The following VeraCrypt container\(s\) are mounted at present:
	veracrypt -t -l
	echo
}

main_menu () {
	echo "/- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\"
	echo " Choose:"
	echo
    echo " 1. Display general script info"
	echo " 2. List mounted and decrypted VeraCrypt containers"
	echo " 3. Sync with BW first (to get the latest versions of your VeraCrypt passwords)"
	echo " 4. Store BW master password as a global variable for the duration of the script"
	echo "    to decrypt >1 drives/containers faster (less secure)"
	echo " 5. Decrypt and mount drive/container"
	echo " 6. Quit"
	echo 
	echo " Enter your choice below:"
	echo "\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -/"
}

# Display general information
general_info () {
	echo
	echo This script decrypts and mounts a VeraCrypt encrypted drives and containers,
   	echo using the Bitwarden and VeraCrypt command line tools in the background.
	echo
	echo In order for it to work the user will need to: 
	echo
	echo - Have VeraCrypt installed as well as the bitwarden-cli.
	echo - Already be logged in with the terminal command: \'bw login\' \(thus the user is already 2FA verified and \'bw get password MYPASS\' can be used by the script\).
	echo - Enter her/his Bitwarden master password.
	echo - Know the name in Bitwarden of the password entry for the VeraCrypt device/container \(e.g. \"myencryptedcontainer1\" or such\).
	echo - Know the path of the device/container on her/his local machine \(if unsure, please open a new terminal tab and find out\).
	echo
}

main


### EXTRAS ###

# # implementera ifall gömda behållare ska användas.
#
# read -p "Decrypt outer (1) or inner hidden (2) volume? " vol
#
# if [ $vol -eq 1 ]
# then
# 	outerpass=$(echo "$global_bw_pass" | bw get password usbbackup1)
# 	hiddenpass=$(echo "$global_bw_pass" | bw get password usbbackuphidden1)
# 	sudo veracrypt --text --mount /dev/"$device" /mnt/veracrypt"$slot" --slot="$slot" --password="$outerpass" --pim=0 --keyfiles="" --password="$outerpass" --protect-hidden=yes --protection-password="$hiddenpass" --protection-pim=0 --protection-keyfiles="" --verbose --background-task
# 	echo \(*ignore the above line*\)
# elif [ $vol -eq 2 ]
# then
# 	hiddenpass=$(echo "$global_bw_pass" | bw get password usbbackuphidden1)
# 	sudo veracrypt --text --mount /dev/"$device" /mnt/veracrypt"$slot" --slot="$slot" --password="$hiddenpass" --pim=0 --keyfiles="" --protect-hidden=no --verbose --background-task
# 	echo \(*ignore the above line*\)
# else
# 	echo Please rerun and enter 1 or 2
# fi

## Ask question to user about action to be done, prompt for input "yes" or "no", fault check, and run command.
## $1 Question
## $2 Execute if yes
## $3 Execute if no
#yes_or_no () {
#	local yn
#	local yesno='(y)es / (n)o:' 
#	echo "$1" "$yesno" 
#	while true;	do
#		read yn 
#		case $yn in
#			y|yes)
#				$2	
#				break
#				;;
#			n|no)
#				$3
#				break
#				;;
#			*)
#				echo
#				echo Please enter "yes (y)" or "no (n)" 
#				continue
#				;;
#		esac
#	done
#}

## List the presently mounted partitions in the filesystem
#list_mounted () {
#	local list
#	read -s -p "Display a list of devices and partitions on the system? (y)es / (n)o" list
#	while true; do
#		case $list in
#			y)
#				echo
#				lsblk --shell
#				break
#				;;
#			n)
#				break
#				;;
#			*)
#				echo Please enter \"y\" or \"n\" and press Enter
#				continue
#				;;
#		esac
#	done
#}
#
