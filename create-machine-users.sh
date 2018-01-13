#!/bin/bash

/usr/local/bin/list-users-with-ssh-access | while read UNAME; do

	echo "Processing: $UNAME"
	getent passwd $UNAME > /dev/null

	if [ $? -eq 0 ]; then
		echo "User " $UNAME " already exists"
	else
		echo "Creating new user " $UNAME
                sudo mkdir -p /home/$UNAME
                sudo useradd -d /home/$UNAME -s /bin/bash $UNAME
                sudo chown -R $UNAME:$UNAME /home/$UNAME

		# TODO: CP -> make this dependant on DynamoDB config
		echo "Granting sudo to user"
		sudo /usr/local/sbin/grant-sudo-to-user $UNAME

		echo ""
	fi
done

