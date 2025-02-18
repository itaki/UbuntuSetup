#! /bin/bash
#
# RLM Service Installer for Ubuntu
# Modified from original script by Ahad Mohebbi

clear
echo "======== Installing the License Server on Linux ========"
echo "Starting the RLM license server"

#extract license files...
sudo tar -xf ./rlm.tar -C /opt/

#setting the execute permission...
sudo chmod +x /opt/rlm/rlm
sudo chmod +x /opt/rlm/rlmutil
sudo chmod +x /opt/rlm/rlmenvset.sh

#setup license environment in startup bash files...
if [ -f ~/.bashrc ]; then
	echo "source /opt/rlm/rlmenvset.sh" >> ~/.bashrc
fi

if [ -f ~/.bash_profile ]; then
	echo "source /opt/rlm/rlmenvset.sh" >> ~/.bash_profile
fi

#setup foundry license files...
FOUNDRY_LIC_PATH="/usr/local/foundry/RLM"
if [ -e $FOUNDRY_LIC_PATH ];
then
	cd /opt/rlm	
	sudo cp ./foundry.lic /usr/local/foundry/RLM
	sudo cp ./foundry.set /usr/local/foundry/RLM
	sudo chmod -R 777 /usr/local/foundry
else
	cd /opt/rlm	
	sudo mkdir -p /usr/local/foundry/RLM
	sudo mkdir -p /usr/local/foundry/RLM/log
	sudo cp ./foundry.lic /usr/local/foundry/RLM
	sudo cp ./foundry.set /usr/local/foundry/RLM
	sudo chmod -R 777 /usr/local/foundry
fi

#setup genarts license files...
GENARTS_LIC_PATH="/usr/genarts/rlm/"
if [ -e $GENARTS_LIC_PATH ];
then
	cd /opt/rlm	
	sudo rm /usr/genarts/rlm/*
	sudo cp genarts.lic /usr/genarts/rlm
	sudo cp genarts.set /usr/genarts/rlm
	sudo chmod -R 777 /usr/genarts/rlm/
else
	cd /opt/rlm	
	sudo mkdir -p /usr/genarts/rlm/
	sudo cp genarts.lic /usr/genarts/rlm
	sudo cp genarts.set /usr/genarts/rlm
	sudo chmod -R 777 /usr/genarts/rlm/
fi

#setup peregrineLabs license files...
PEREGRINELABS_LIC_PATH="/var/PeregrineLabs/rlm/"
if [ -e $PEREGRINELABS_LIC_PATH ];
then
	cd /opt/rlm
	sudo cp peregrinel.set /var/PeregrineLabs/rlm/
	sudo cp peregrinel.lic /var/PeregrineLabs/rlm/
	sudo chmod -R 777 /var/PeregrineLabs/rlm/
else
	sudo mkdir -p /var/PeregrineLabs/rlm/
	cd /opt/rlm
	sudo cp peregrinel.set /var/PeregrineLabs/rlm/
	sudo cp peregrinel.lic /var/PeregrineLabs/rlm/
	sudo chmod -R 777 /var/PeregrineLabs/rlm/
fi

#setup maxwell license files...
MAXWELL_LIC_PATH="$HOME/Maxwell"
if [ -e $MAXWELL_LIC_PATH ];
then
	cd /opt/rlm
	sudo cp nextlimit.set $HOME/Maxwell
	sudo cp nextlimit.lic $HOME/Maxwell
	sudo chmod -R 777 $HOME/Maxwell
else
	sudo mkdir -p $HOME/Maxwell
	cd /opt/rlm
	sudo cp nextlimit.set $HOME/Maxwell
	sudo cp nextlimit.lic $HOME/Maxwell
	sudo chmod -R 777 $HOME/Maxwell
fi

# Create systemd service file
echo "Creating systemd service file..."
sudo bash -c 'cat > /etc/systemd/system/rlmd.service << EOL
[Unit]
Description=RLM License Server
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/rlm
ExecStart=/opt/rlm/rlm -dlog rlm_lic.dlog -c /usr/local/foundry/RLM/foundry.lic
ExecStop=/bin/kill -s QUIT \$MAINPID
User=root
Group=root
Restart=always
PIDFile=/var/run/rlmd.pid

[Install]
WantedBy=multi-user.target
EOL'

# Set proper permissions for service file
sudo chmod 644 /etc/systemd/system/rlmd.service

# Create symbolic link for autostart
sudo mkdir -p /etc/systemd/system/multi-user.target.wants/
sudo ln -sf /etc/systemd/system/rlmd.service /etc/systemd/system/multi-user.target.wants/rlmd.service

# Reload systemd, enable and start service
echo "Setting up systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable rlmd
sudo systemctl start rlmd

echo "RLM License Server installation complete."
echo "Checking service status..."
sudo systemctl status rlmd
echo "You can check the service status anytime with: sudo systemctl status rlmd"
echo "You can check license status with: sudo /opt/rlm/rlmutil rlmstat -a"
cd $HOME