#!/bin/bash
#today
#====================
#IPSEC'N'A'SEC
#====================
###################
#====================
#ADJUSTABLE VARIABLES
#====================
strongswan_download='http://download.strongswan.org/strongswan-5.3.5.tar.gz'
ipsec_download="ipsec-tools.x86_64"
red_or_deb=""
#used to determine if user wants kernel or strongswan
#used for type of ipsec, strongswan or ipsec-tools
NON_USABLE_INPUT=777
NULL_STRING=""
user_input=$NON_USABLE_INPUT
guided_or_quick=$NON_USABLE_INPUT
user_topology=$NON_USABLE_INPUT
setkey_check=$NULL_STRING
strong_check=$NULL_STRING
user_flows=$NON_USABLE_INPUT

#====================


#====================
#FUNCTIONS
#====================
function run()
{
	
	sleep 1
	greeting
	sleep 1
	argument_check $1 $2
	sleep 1
	config_script_check
	directory_check
	install_check
	sleep 1
	linux_version
	user_check
	install_IPSEC
	sleep 1
	if [ $guided_or_quick == 0 ]; then
		ipsec_topology
		implement
	fi
} 
function run_config()
{
	chmod +x config.py
	python config.py "$user_input" "$user_topology" "$user_flows"
}
function argument_check()
{
	if [ $# -eq 0 ]; then

		echo "No arguments provided, running in guided mode"
		guided_or_quick=0
	else
		echo "Arguments found, running in quick mode"
		quided_or_quick=1
	fi
}
function greeting()
{
	echo -e "\n========================="
	echo -e "Welcome to IPSEC Generator"
	echo    "========================="
	echo -e "Thank you for using...\n"
	echo -ne "Performing environment check\r"
	sleep .5	
	echo -ne "Performing environment check.\r"	
	sleep .5
	echo -ne "Performing environment check..\r"	
	sleep .5
	echo -ne "Performing environment check...\r"	
	sleep .5
	echo -e "Performing environment check...[done]"	
}
function user_check()
{
	echo -e "\nWhich IPSec do you wish to use"
	while [ $user_input -lt 0 ] || [ $user_input -gt 1  ]
	do
		echo -e "Type [0] for Kernel IPSec using setkey"
		echo -e "Type [1] for Strongswan IPSec"
		printf 'Enter input: '
		read -r user_input
		if [ -z "$user_input" ]; then
			user_input=$NON_USABLE_INPUT
		fi
		if [ $user_input -lt 0 ] || [ $user_input -gt 1 ]; then
			echo -e "\nERROR: User Input out of bounds"
		fi 
	done
	echo "User input accepted"
}
function config_script_check()
{
	if [ -e "$(pwd)/config.py" ]; then
		echo -e "1.) config.py detected"
	else
		echo -e "1.) config.py not detected...aborting"
		exit 1
	fi
	
}
function directory_check()
{
	if [ -d "/root" ]; then
		echo -e "2.) root directory detected"
	else
		echo -e "2.) root directory not detected...aborting"
		exit 1
	fi
}
function linux_version()
{
	if [ -e "/etc/redhat-release" ]; then
		red_or_deb="red"
	elif [ -e "/etc/debian_version" ]; then
		red_or_deb="deb"
	else
		red_or_deb="null"
	fi
}
function strongswan_install()
{
	if [ $red_or_deb = "deb" ]; then	
		temp_aptitude_check=$( which aptitude )
		if [[ $temp_aptitude_check = $NULL_STRING ]]; then
			echo "Since you are using a Debian based Distribution, please install aptitude"
			echo "apt-get install aptitude"
			exit 1
		fi	
	fi
	cd /root/
	mkdir -p strongswan/tarfiles
	mkdir -p strongswan/conf_files
	cd strongswan/tarfiles
	wget --no-check-certificate $strongswan_download
	file_to_untar=$( echo $strongswan_download | awk 'BEGIN { FS="/";} {print $4}')	
	tar xvf $file_to_untar	
	strongswan_directory=$( echo $file_to_untar | awk 'BEGIN {FS=".tar.gz";} {print $1}')
	cd $(pwd)/$strongswan_directory
	echo "Strongswan build directory will be installed in /root/strongswan/tar_files"
	echo "Strongswan binary will be in /usr/local/sbin"
	sleep 7	
	./configure --prefix=/usr/local/ --sysconfdir=/root/strongswan/conf_files
	#checks the exit code of the ./configure script
	if [ $( echo $? ) = 1 ]; then
		echo -e "\nEnsure shared library support libgmp10 is installed\n"
		echo -e "Use \'aptitude install libgmp10\' and creates a symbolic link without the .version"
		echo -e "Also, use \'aptitude install libgmp-dev\'"
		echo "cleaning up"
		rm -rf /root/strongswan
		exit 1
	fi
	
	make && make install
	if [ $( echo $? ) = 1 ]; then
		echo "Strongswan install Failed"
		echo "Cleaning up"
		rm -rf /root/strongswan
		exit 1
	fi
} 
function setkey_install()
{
	debian_ipsec=$( echo $ipsec_download | awk -F. '{print $1}')
	echo $debian_ipsec
	if [ $red_or_deb == "red" ]; then
		yum install $ipsec_download
	elif [ $red_or_deb == "deb" ]; then
		apt-get install $debian_ipsec
	fi
}
function ipsec_topology()
{
	
	echo -e "\nPlease choose a Toplogy"
	sleep .5
	echo -e "\n    *****"
	echo "    *KEY*"
	echo "    *****"
	echo "    \"=\" = Encrypted Traffic"
	echo -e "    \"-\" = Clear Text\n" 
	echo ""
	echo "For all Topologies listed below, the following applies"
	echo "192.168.X.X will be the outside subnet with clear text"
	echo -e "172.16.X.X will be the inside subnet with encrypted traffic\n"
	sleep 1
	echo "1.) Requires 3 subnets"
	echo " _______                 ______"
	echo "|       |               |      |"
	echo "|GateWay|===============|Client|"
	echo "|_______|               |______|"
	echo "   |       _________        |"
	echo "   |______|         |_______|"
	echo "          | Traffic |"
	echo "          |Generator|"
	echo "          |_________|"
	echo " "
	echo "2.) Requires 2 subnets"
	echo " _______                 ______"
	echo "|       |               |      |"
	echo "|GateWay|===============|Client|"
	echo "|_______|               |______|"
	echo "   |       _________        "
	echo "   |______|         |"
	echo "          | Server  |"
	echo "          |_________|"
	echo " "
	echo "3.) Requires 1 subnet"
	echo " ________                 ________"
	echo "|        |               |        |"
	echo "| Host 1 |===============| Host 2 |"
	echo "|________|               |________|"
	echo " "
	echo -e "\nWhich Topology would you like? 1-3"
	
	while [ $user_topology -lt 1 ] || [ $user_topology -gt 3  ]
	do
		printf 'Enter input: '
		read -r user_topology
		
		if [ -z "$user_topology" ]; then
			user_topology=7
		fi
		if [ $user_topology -lt 1 ] || [ $user_topology -gt 3 ]; then
			echo -e "\nERROR: User Input out of bounds"
		fi 
	done
	echo "User input accepted"
	
}
function install_check()
{
	setkey_check=$(command -v setkey)
	strong_check=$(command -v ipsec)
	python_check=$(command -v python)
	if [ -z "$setkey_check" ]; then
		echo "3.) Kernel IPSec not detected"
	else
		echo "3.) Kernel IPSec detected"
	fi
	if [ -z "$strong_check" ]; then
		echo "4.) Strongswan IPSec not detected"
	else
		echo "4.) Strongswan IPSec detected"
	fi
	if [ -z "$python_check" ]; then
		echo "5.) Python not detected...aborting: Install Python"
		exit 1
	else
		echo "5.) Python detected"
	fi
}
function install_IPSEC()
{
	if [ $user_input -eq 0 ]; then
		if [ -z "$setkey_check" ]; then
			echo "Installing Setkey"
			sleep 4
			setkey_install
		else
			echo "Setkey already install"	
		fi
	elif [ $user_input -eq 1 ]; then 
		if [ -z "$strong_check" ]; then
			echo "Installing Strongswan"
			sleep 4
			strongswan_install
		else
			echo "Strongswan already installed"	
		fi
	fi 
}
function flows()
{
	echo "How many flows do you want? Between 1 - 8"
	while [ $user_flows -lt 1 ] || [ $user_flows -gt 8  ]
	do
		printf 'Enter input: '
		read -r user_flows
		
		if [ -z "$user_flows" ]; then
			user_flows=777
		fi
		if [ $user_flows -lt 1 ] || [ $user_flows -gt 8 ]; then
			echo -e "\nERROR: User Input out of bounds"
		fi 
	done
	echo "User input accepted"
}
function implement()
{
	case "$user_topology" in

	1) 	
		flows
		run_config
	;;
	2) 
		flows
		run_config
	;;
	3) 	
		flows
		run_config
	;;
	esac
}
run $1 $2
