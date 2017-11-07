# SSH Access controlled from DynamoDB
This repo holds scripts that can be used to configure the SSH Deamon on a Linux instance to look for public keys in DynamoDB before the _.ssh/.authorized_keys_ file in users homedir.

## Installation
### DynamoDB Table
The current version of the scripts assume a table with the name **ssh-access** is created in _eu-west-1_

* The table must be readable by the EC2 instances using the solution
* The table should not be writable from said instances

#### Table structure
  * The table must have primary key string named userid
  * Public keys must be stored in a String Array attribute named **public_keys**
  * Public key entries must be in OpenSSH format (ie. just like they are in an authorized_keys file)

Example item:

```javascript
{
  "email": "cp@keycore.dk",
  "name": "Christian Petersen",
  "public-keys": [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtz0Ltu6BS+qVF0kygolgix++vR3R/ll+H07iYkpsIdOA4ByVDQdQ8Gvt7xqzZMAjo1UVP0g4g+i7bq5QbdzHcauHS0nISqr2pyrEkjkvJG3byZ1JINUW6AjZKVQSBNgArVFpmMFsQjN5MEAXSfaK9ZeiA57QO+DGvcC4Wm1JSBJnK+rqsloaLt3ucFE3Kxs65H5WWAAxTCrQHvL/siGQNkpO/F8zoFBIkyyvlt6eQC3CPPId4dPWswranneQopBlH07j19HOZcpqrWF+uuaRi1FODikAoL2O6/PuyHnW985SBcFO/GPU8pCUhMEt5Z7Cxhc80nmoOpMgDJqcRkged imported-openssh-key"
  ],
  "userid": "cp"
}
``` 

**Note:**
  * email attributes is **_NOT_** used by current version of scripts - and thus pretty optional


### General installation
To install run the setup.sh script - which performs these steps:

**_Note:_**
  * setup.sh assumes remaining files from this repo is present
  * setup.sh executes all commands with sudo

#### Setup steps
1. Create folder **/opt/ssh-dynanmo/**
1. Move script files to **/opt/ssh-dynamo/**
1. Create symlinks to scripts in **/usr/local/bin** and **/usr/local/sbin/**
1. Grant execution rights to scripts _chmod a+x ..._
1. Make a backup of the existing sshd config **_/etc/ssh/sshd_config_** (this backup is used for uninstallation)
1. Run the script **_configure-ssh.sh_** which replaces 2 lines inside **_/etc/ssh/sshd_config_**
1. Run the script **_create-machine-users.sh_** which reads all items from the dynamodb table and creates local users

**_Note: SSH service will be restarted for changes to take effect - this is done by configure-ssh.sh_**

#### File: **configure-ssh.sh**
Used to change configuration of SSH Deamon to call our scripts on login.

Changes SSH configuration by setting 2 options

* [AuthorizedKeysCommand][ssh_auth_command] => authorized_keys_command
* [AuthorizedKeysCommandUser][ssh_auth_user] => root

Restarts SSH Service after changing config

**Note:** From the SSH manual:
> "If the AuthorizedKeysCommand does not successfully authorize the user, authorization falls through to the AuthorizedKeysFile."

### Installation on AWS
The scripts can be installed using [AWS EC2 Simple System Manager][ssm_main] by following theese steps:

1. Create a SSM Document using the json files in the ec2_ssm folder
1. Execute a [SSM Run Command][ssm_run_command]
   * A Run Command is executed on a selection of EC2 instances (could be all with a specific tag value)

The [ec2_ssm](ec2_ssm) folder contains ready made document definitions to install and uninstall the scripts

_TODO: Insert aws cli command to create document and run command here_

## Authorizing users during login
During the login process the following scripts are used
### Overview of scripts
The solution is comprised for 6 different scripts (each just a few lines)


#### File: authorized_keys_command
This is the main script executed by SSH Deamon for each login - it has two basic steps:

 * Input validation and sanitation of usernames (ssh is more picky than others)
 * Call the _**list-ssh-keys-for-user**_ command and loop through each line of response to echo it

#### File: **list-ssh-keys-for-user**
Called by the authorized_keys_command script for each login - has only one step:
 * Use AWS CLI to call dynamodb get-item for given userid
    * Fetch only attribute named **public-keys**
    * Print each array entry on a separate line using pipe / awk

**Note:**
  * This script is hardcoded to use eu_west_1 - change if needed
  * This script is hardcoded to use a table named: **ssh-access** - future versions might move this to tag or something similar. For now - change if needed


## Creating local users based on DynamoDB content
During installation this is done once - but based on you user change frequency this should be done regularly - suggested methods:
 * Schedule a call to create-machine-users.sh using CRON at whatever schedule seems right to you
 * Use AWS SSM to schedule a recurrent task

**Note:** Future versions might allow for auto-creation of users at login time - but currently this is not supported!

#### File: **create-machine-users.sh**
Called without parameters and will use **list-users-with-ssh-access** script to loop through all users in DynamoDB and create local users where needed

**Note** 
  * Currently this script calls grant-sudo-to-user for each created user - this will be more configurable in the future

#### File: **list-users-with-ssh-access**
Called by **create-machine-users.sh** script - has just one step:
* Use AWS CLI to scan DynamoDB table for _userid_'s and output each result on separate line using pipe / awk

**Note:**
  * This script is hardcoded to use eu_west_1 - change if needed
  * This script is hardcoded to use a table named: **ssh-access** - future versions might move this to tag or something similar. For now - change if needed

#### File: **grant-sudo-to-user**
Called by **create-machine-users.sh** script - has just one step:
* Update **_/etc/sudoers.d/_** with a new entry for specified user

## Currently unhandled use-cases
* User deletion
* Automatic user creation on login
* Configurable group membership / sudo access


[ssm_main]: https://aws.amazon.com/ec2/systems-manager/
[ssm_run_command]: http://docs.aws.amazon.com/systems-manager/latest/userguide/execute-remote-commands.html
[ssh_auth_command]: https://linux.die.net/man/5/sshd_config
[ssh_auth_user]: https://linux.die.net/man/5/sshd_config









