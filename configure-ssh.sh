#!/bin/bash

# diff sshd_config sshd_config-dst
#
# < #AuthorizedKeysCommand none
# ---
# > AuthorizedKeysCommand /opt/authorized_keys_command.sh
#
sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /usr/local/bin/authorized_keys_command:g' /etc/ssh/sshd_config
sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser root:g' /etc/ssh/sshd_config

sudo service sshd restart