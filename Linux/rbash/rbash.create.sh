#!/bin/bash

# In advance of running this script, copy the below 3 files to the desired server.
# (They will be deleted upon completion)
#
# rbash.create.sh (this script)
# rbash.authorized_keys
# rbash.profile
#

USERTOADD='logrdr'

sudo pwd

sudo useradd -m -s /bin/rbash $USERTOADD

# Echo out the pw here so we can cut/paste into the 'passwd' command
# and another window when prompted.
# LIz3Jyy8lC)z
echo 'LIz3Jyy8lC)z'

sudo passwd $USERTOADD

sudo mkdir /home/$USERTOADD/bin

sudo chmod 755 /home/$USERTOADD/bin

read -p "Open another window and login as $USERTOADD to get the .profie file created. <press a key when done...> "

sudo chown root:root /home/$USERTOADD/.profile

sudo chmod 755 /home/$USERTOADD/.profile

sudo ln -s /bin/cat /home/$USERTOADD/bin
sudo ln -s /bin/grep /home/$USERTOADD/bin
sudo ln -s /bin/less /home/$USERTOADD/bin
sudo ln -s /bin/ls /home/$USERTOADD/bin
sudo ln -s /usr/bin/tail /home/$USERTOADD/bin

sudo chmod a+r /var/log/apache2
sudo chmod a+x /var/log/apache2
sudo chmod a+r /var/log/apache2/*

sudo cp -f -p rbash.profile /home/$USERTOADD/.profile

sudo mkdir /home/$USERTOADD/.ssh
sudo chmod 700 /home/$USERTOADD/.ssh
sudo chown logrdr:logrdr /home/$USERTOADD/.ssh

sudo cp -f -p rbash.authorized_keys /home/$USERTOADD/.ssh/authorized_keys
sudo chmod 600 /home/$USERTOADD/.ssh/authorized_keys
sudo chown logrdr:logrdr /home/$USERTOADD/.ssh/authorized_keys

sudo chmod 644 /home/$USERTOADD/.profile
sudo chown root:root /home/$USERTOADD/.profile

sudo rm rbash.profile
sudo rm rbash.create.sh
sudo rm rbash.authorized_keys
