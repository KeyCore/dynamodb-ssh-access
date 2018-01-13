#!/bin/bash

/usr/local/bin/list-users-with-ssh-access | while read UNAME; do

	echo "Processing: $UNAME"
    getent passwd $UNAME > /dev/null

	if [ $? -eq 0 ]; then
		echo "User " $UNAME " already exits"
	else
		echo "Creating new user " $UNAME
		sudo useradd $UNAME

		# TODO: CP -> make this dependant on DynamoDB config
		echo "Granting sudo to user"
		sudo /usr/local/sbin/grant-sudo-to-user $UNAME

		echo ""
	fi
done

