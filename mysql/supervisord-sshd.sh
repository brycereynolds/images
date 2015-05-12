#!/bin/bash

# Password can initially be set by passing
# an environment variable of ROOT_PASS when
# building this docker container - it will
# always run the set_root_pw.sh the one time
if [ ! -f /.root_pw_set ]; then
    /set_root_pw.sh
fi

exec /usr/sbin/sshd -D