### nuke setup
@https://learn.foundry.com/nuke/content/getting_started/installation/installing_nuke_linux.html

I need help setting up nuke. We should make one script that does all this.
- looks in the ~/UbuntuSetup/nuke folder for the most recent version of nuke (in this case it's Nuke15.1v5-linux-x86_64.run)
- it's a run file
- running the file with "sudo ./Nuke<version number>-linux-x86_64.run --accept-foundry-eula" will install it skipping the license agreement.
- it will extract the folder, we should then move the folder to the appropriate place
- the icons are located at  ~/UbuntuSetup/nuke
- nuke_folder_icon.png incase we need to put it in a folder
- nuke_icon.png for running the basic nuke
- a nukex_icon.png for a nuke instance run with the "-nukex" tag
- we should make a couple desktop entries, one for each version nuke and nukex
- write a script that will install nuke and then create the desktop entries