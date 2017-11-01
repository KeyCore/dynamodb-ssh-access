#!/bin/bash

/usr/local/bin/list-users-with-ssh-access | while read UNAME; do

	echo "Processing: $UNAME"
	echo "Adding user to machine"

	sudo useradd $UNAME

	echo "Granting sudo to user"
	sudo /usr/local/sbin/grant-sudo-to-user $UNAME

	echo ""
	echo ""
done

