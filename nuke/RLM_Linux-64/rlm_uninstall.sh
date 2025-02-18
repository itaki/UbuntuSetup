#! /bin/bash
#
# RLM Service UnInstaller
#
# Ultimate RLM floating license server Uninstaller
# Developed by Ahad Mohebbi

clear
echo "======== Uninstalling the License Server in Linux ========"
echo "Stop the RLM license server"

#stop rlm server service...
service rlmd stop

#remove rlm and licese files...
if [ -d /opt/rlm ]; then
	sudo rm -rf /opt/rlm
fi

#remove rlmd from startup bash files...
if [ -f /etc/init.d/rlmd ]; then
	sudo rm /etc/init.d/rlmd
fi
if [ -f /etc/rc.d/init.d/rlmd ]; then
	sudo rm /etc/rc.d/init.d/rlmd
fi

#backup and remove license environment setting
if [ -f ~/.bashrc ]; then
	sudo sed -i '/rlmenvset.sh/d' ~/.bashrc
fi
if [ -f ~/.bash_profile ]; then
	sudo sed -i '/rlmenvset.sh/d' ~/.bash_profile
fi

#backup your licenses...
if [ -d /usr/local/foundry ] && [ -d /usr/local/foundry.bak ] ; then
	sudo rm -rf /usr/local/foundry
elif [ -d /usr/local/foundry ]; then
	sudo mv /usr/local/foundry{,.bak}
fi

if [ -d /usr/genarts/rlm ] && [ -d /usr/genarts/rlm.bak ]; then
	sudo rm -rf /usr/genarts/rlm
elif [ -d /usr/genarts/rlm ]; then
	sudo mv /usr/genarts/rlm{,.bak}
fi

if [ -d /var/PeregrineLabs/rlm ] && [ -d /var/PeregrineLabs/rlm.bak ]; then
	sudo rm -rf /var/PeregrineLabs/rlm
elif [ -d /var/PeregrineLabs/rlm ]; then
	sudo mv /var/PeregrineLabs/rlm{,.bak}
fi

if [ -d $HOME/Maxwell ] && [ -d $HOME/Maxwell.bak ]; then
	sudo rm -rf $HOME/Maxwell
elif [ -d $HOME/Maxwell ]; then
	sudo mv $HOME/Maxwell{,.bak}
fi

echo "The RLM License Server successfully removed."
cd $HOME