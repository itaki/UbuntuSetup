#! /bin/bash
#
# RLM Service Installer
#
# Ultimate RLM floating license server Uninstaller
# Developed by Ahad Mohebbi

#setup licens environment in stratup bash files...
if [ "$1" = "--help" ]; then

	echo "RLM License Manager for Client[s]..."
	echo "developed by Ahad Mohebbi"
	echo ""
	echo "Usage: rlm_client.sh [ARGUMENT] [OPTION]"
	echo "Add and Remove License environment for client[s]"
	echo ""
	echo "[ARGUMENTS]"
	echo "--add          add license environment to the client[s]."
	echo "--remove       remove license environment to the client[s]."
	echo "--help         display how to use this script."
	echo ""
	echo "[OPTION]"
	echo "YOUR_SERVER_HOST_NAME   [OR]   YOUR_SERVER_IP" 
	echo ""
	echo "Examples:"
	echo "add license environment..."
	echo "	sudo rlm_client.sh --add VFX_SERVER"
	echo "	sudo rlm_client.sh -add 192.168.1.50"
	echo ""
	echo "remove license environment..."
	echo "	sudo rlm_client.sh --remove"
	echo ""
	exit 0
fi

if [ "$1" = "" ]; then
	echo "RLM License Manager for Client[s]..."
	echo "developed by Ahad Mohebbi"
	echo ""
	echo "Usage:  rlm_client.sh [ARGUMENT] [OPTION]"
	echo "Add and Remove License environment for client[s]"
	echo ""
	echo "[ARGUMENTS]"
	echo "--add          add license environment to the client[s]."
	echo "--remove       remove license environment to the client[s]."
	echo "--help         display how to use this script."
	echo ""
	echo "[OPTION]"
	echo "YOUR_SERVER_HOST_NAME  .......... the HOST name of your server that RLM License Manager Installed on it."
	echo "YOUR_SERVER_IP" 
	echo ""
	echo "Examples:"
	echo "add license environment..."
	echo "	sudo rlm_client.sh --add VFX_SERVER"
	echo "	sudo rlm_client.sh -add 192.168.1.50"
	echo ""
	echo "remove license environment..."
	echo "	sudo rlm_client.sh --remove"
	echo ""
	exit 0
fi

if [ "$1" = "--add" ] && [ "$2" != "" ]; then
	if [ -f ~/.bashrc ]; then
		if [ -f ~/.rlmrc ]; then
			echo "RLM License Manager has been installed on your client[s]."
			exit
		else
			sudo touch ~/.rlmrc
			sudo chmod 777 ~/.rlmrc
			echo export fabricinc_LICENSE=5053@$2 >> ~/.rlmrc
			echo export foundry_LICENSE=5053@$2 >> ~/.rlmrc
			echo export genarts_LICENSE=5053@$2 >> ~/.rlmrc
			echo export golaem_LICENSE=5053@$2 >> ~/.rlmrc
			echo export innobright_LICENSE=5053@$2 >> ~/.rlmrc
			echo export mootzoid_LICENSE=5053@$2 >> ~/.rlmrc
			echo export nextlimit_LICENSE=5053@$2 >> ~/.rlmrc
			echo export peregrinel_LICENSE=5053@$2 >> ~/.rlmrc
			echo export redshift_LICENSE=5053@$2 >> ~/.rlmrc
			echo export solidangle_LICENSE=5053@$2 >> ~/.rlmrc
			echo export SFX_LICENSE_SERVER=5053@$2 >> ~/.rlmrc
			echo export PATH=$PATH:fabricinc_LICENSE:foundry_LICENSE:genarts_LICENSE:golaem_LICENSE:innobright_LICENSE:mootzoid_LICENSE:nextlimit_LICENSE:peregrinel_LICENSE:redshift_LICENSE:solidangle_LICENSE:SFX_LICENSE_SERVER >> ~/.rlmrc
			echo source ~/.rlmrc >> ~/.bashrc
			
			echo "Successfull Install fabricinc_LICENSE=5053@$2"
			echo "Successfull Install foundry_LICENSE=5053@$2"
			echo "Successfull Install genarts_LICENSE=5053@$2"
			echo "Successfull Install golaem_LICENSE=5053@$2"
			echo "Successfull Install innobright_LICENSE=5053@$2"
			echo "Successfull Install mootzoid_LICENSE=5053@$2"
			echo "Successfull Install nextlimit_LICENSE=5053@$2"
			echo "Successfull Install peregrinel_LICENSE=5053@$2"
			echo "Successfull Install redshift_LICENSE=5053@$2"
			echo "Successfull Install solidangle_LICENSE=5053@$2"
			echo "Successfull Install SFX_LICENSE_SERVER=5053@$2"
			echo "======================================================="
			echo "License environment successfully add to your client[s]."
			exit 0
		fi
	fi

	if [ -f ~/.bash_profile ] ; then
		if [ -f ~/.rlmrc ]; then
			echo "RLM License Manager has been installed on your client[s]."
			exit
		else
			echo export fabricinc_LICENSE=5053@$2 >> ~/.rlmrc
			echo export foundry_LICENSE=5053@$2 >> ~/.rlmrc
			echo export genarts_LICENSE=5053@$2 >> ~/.rlmrc
			echo export golaem_LICENSE=5053@$2 >> ~/.rlmrc
			echo export innobright_LICENSE=5053@$2 >> ~/.rlmrc
			echo export mootzoid_LICENSE=5053@$2 >> ~/.rlmrc
			echo export nextlimit_LICENSE=5053@$2 >> ~/.rlmrc
			echo export peregrinel_LICENSE=5053@$2 >> ~/.rlmrc
			echo export redshift_LICENSE=5053@$2 >> ~/.rlmrc
			echo export solidangle_LICENSE=5053@$2 >> ~/.rlmrc
			echo export SFX_LICENSE_SERVER=5053@$2 >> ~/.rlmrc
			echo export PATH=$PATH:fabricinc_LICENSE:foundry_LICENSE:genarts_LICENSE:golaem_LICENSE:innobright_LICENSE:mootzoid_LICENSE:nextlimit_LICENSE:peregrinel_LICENSE:redshift_LICENSE:solidangle_LICENSE:SFX_LICENSE_SERVER >> ~/.rlmrc
			echo source ~/.rlmrc >> ~/.bash_profile
			
			echo "Successfull Install fabricinc_LICENSE=5053@$2"
			echo "Successfull Install foundry_LICENSE=5053@$2"
			echo "Successfull Install genarts_LICENSE=5053@$2"
			echo "Successfull Install golaem_LICENSE=5053@$2"
			echo "Successfull Install innobright_LICENSE=5053@$2"
			echo "Successfull Install mootzoid_LICENSE=5053@$2"
			echo "Successfull Install nextlimit_LICENSE=5053@$2"
			echo "Successfull Install peregrinel_LICENSE=5053@$2"
			echo "Successfull Install redshift_LICENSE=5053@$2"
			echo "Successfull Install solidangle_LICENSE=5053@$2"
			echo "Successfull Install SFX_LICENSE_SERVER=5053@$2"
			echo "======================================================="
			echo "License environment successfully add to your client[s]."	
			exit 0
		fi
	fi
fi

if [ "$1" = "--remove" ]; then
	
	if [ -f ~/.bashrc ] && [ -f ~/.rlmrc ]; then
		sudo rm ~/.rlmrc
		sudo sed -i '/rlmrc/d' ~/.bashrc
		echo "Successfull Remove fabricinc_LICENSE"
		echo "Successfull Remove foundry_LICENSE"
		echo "Successfull Remove genarts_LICENSE"
		echo "Successfull Remove golaem_LICENSE"
		echo "Successfull Remove innobright_LICENSE"
		echo "Successfull Remove mootzoid_LICENSE="
		echo "Successfull Remove nextlimit_LICENSE"
		echo "Successfull Remove peregrinel_LICENSE"
		echo "Successfull Remove redshift_LICENSE"
		echo "Successfull Remove solidangle_LICENSE"
		echo "Successfull Remove SFX_LICENSE_SERVER"
		echo "==========================================================="
		echo "License environment successfully removed on your client[s]."
		exit 0
	else
		echo "The RLM License Manager doesn't install on this client."
		exit 0
	fi	
	
	if [ -f ~/.bash_profile ] && [ -f ~/.rlmrc ]; then
		sudo rm ~/.rlmrc
		sudo sed -i '/rlmrc/d' ~/.bash_profile
		echo "Successfull Remove fabricinc_LICENSE"
		echo "Successfull Remove foundry_LICENSE"
		echo "Successfull Remove genarts_LICENSE"
		echo "Successfull Remove golaem_LICENSE"
		echo "Successfull Remove innobright_LICENSE"
		echo "Successfull Remove mootzoid_LICENSE="
		echo "Successfull Remove nextlimit_LICENSE"
		echo "Successfull Remove peregrinel_LICENSE"
		echo "Successfull Remove redshift_LICENSE"
		echo "Successfull Remove solidangle_LICENSE"
		echo "Successfull Remove SFX_LICENSE_SERVER"
		echo "==========================================================="
		echo "License environment successfully removed on your client[s]."
		exit 0
	else
		echo "The RLM License Manager doesn't install on this client."
		exit 0
	fi	
fi
exit 0