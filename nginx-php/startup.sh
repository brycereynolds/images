#!/bin/bash

## IMPORTANT: The last service you run should use exec


#########################################
## SSH Password setting

# If env ROOT_PASS is set when running this docker container
# then we will set that as the ssh password
if [ ! -f /.root_pw_set ]; then
    PASS=${ROOT_PASS:-$(pwgen -s 12 1)}
    _word=$( [ ${ROOT_PASS} ] && echo "preset" || echo "random" )
    echo "=> Setting a ${_word} password to the root user"
    echo "root:$PASS" | chpasswd
    touch /.root_pw_set
fi



#########################################
## Set ENV variables on PHP
#
# Function to update the fpm configuration to make the service
# environment variables available - otherwise the fpm service ignores them
function setEnvironmentVariable() {

    if [ -z "$2" ]; then
            echo "Environment variable '$1' not set."
            return
    fi

    # Check whether variable already exists
    # if grep -q $1 /etc/php5/fpm/pool.d/www.conf; then
    #     # Reset variable
    #     sed -i "s/^env\[$1.*/env[$1] = $2/g" /etc/php5/fpm/pool.d/www.conf
    # else
    #     # Add variable
    #     echo "env[$1] = $2" >> /etc/php5/fpm/pool.d/www.conf
    # fi

    # echo "env[$1] = $2" >> /etc/php5/fpm/pool.d/www.conf
    echo "env[$1] = $2" >> /etc/php5/fpm/pool.d/env.conf
}

echo "=> Setting up environment variables"
# This ensures our env variables are available when we SSH
# into this box or when other services need them
env | grep _ >> /etc/environment

# Grep for variables that look like docker set them (_PORT_)
rm -rf /etc/php5/fpm/pool.d/env.conf
echo "[www]" >> /etc/php5/fpm/pool.d/env.conf

for _curVar in `env | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    setEnvironmentVariable ${_curVar} ${!_curVar}
done

env | grep -v 'HOME|PWD|PATH' | while read env; do echo "export $env" >> /home/term/.bashrc ; done

#########################################
## SSH Config
echo "=> Update ssh config"

echo "
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null

" >> /tmp/ssh_config
cat /etc/ssh/ssh_config >> /tmp/ssh_config
mv -f --backup /tmp/ssh_config /etc/ssh/ssh_config


#########################################
# Start Services
echo "=> Start php5-fpm service"
service php5-fpm start

echo "=> Start nginx service"
service nginx start

echo "=> Start ssh"
exec /usr/sbin/sshd -D
