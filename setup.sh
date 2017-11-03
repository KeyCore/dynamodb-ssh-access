#!/bin/bash
# Setup script configure KeyCore DynamoDB SSH access setup

# download scripts from S3
echo "Creating folder /opt/ssh-dynamo/"
sudo mkdir /opt/ssh-dynamo/

# configure files
echo "Moving files"
sudo mv grant-sudo-to-user /opt/ssh-dynamo/grant-sudo-to-user
sudo mv list-ssh-keys-for-user /opt/ssh-dynamo/list-ssh-keys-for-user
sudo mv list-users-with-ssh-access /opt/ssh-dynamo/list-users-with-ssh-access
sudo mv create-machine-users.sh /opt/ssh-dynamo/create-machine-users.sh
sudo mv authorized_keys_command /opt/ssh-dynamo/authorized_keys_command
sudo mv configure-ssh.sh /opt/ssh-dynamo/configure-ssh.sh

echo "Creating symlinks and setting execute rights"
sudo ln -sf /opt/ssh-dynamo/grant-sudo-to-user /usr/local/sbin/grant-sudo-to-user
sudo ln -sf /opt/ssh-dynamo/list-ssh-keys-for-user /usr/local/bin/list-ssh-keys-for-user
sudo ln -sf /opt/ssh-dynamo/list-users-with-ssh-access /usr/local/bin/list-users-with-ssh-access
sudo ln -sf /opt/ssh-dynamo/create-machine-users.sh /usr/local/bin/create-machine-users.sh
sudo ln -sf /opt/ssh-dynamo/authorized_keys_command /usr/local/bin/authorized_keys_command
sudo ln -sf /opt/ssh-dynamo/configure-ssh.sh /usr/local/sbin/configure-ssh.sh

sudo chmod a+x /opt/ssh-dynamo/grant-sudo-to-user
sudo chmod a+x /opt/ssh-dynamo/list-ssh-keys-for-user
sudo chmod a+x /opt/ssh-dynamo/list-users-with-ssh-access
sudo chmod a+x /opt/ssh-dynamo/create-machine-users.sh
sudo chmod a+x /opt/ssh-dynamo/authorized_keys_command
sudo chmod a+x /opt/ssh-dynamo/configure-ssh.sh

# Create a backup of the SSH config
echo "Making backup of sshd_config"
sudo cp /etc/ssh/sshd_config /opt/ssh-dynamo/sshd_config.backup

# configure ssh deamon
echo "Configuring SSH Daemon"
sudo /opt/ssh-dynamo/configure-ssh.sh

echo "Importing initial users"
sudo /opt/ssh-dynamo/create-machine-users.sh

echo "Setup and configuration completed !"
