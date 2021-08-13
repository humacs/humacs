#!/bin/bash

if [ $_ = $0 ]; then
    echo "Usage:
    . /usr/local/bin/ssh-find-agent.sh"
    exit
fi

if [ -n "$(find /tmp /run/host/tmp -maxdepth 1 -name 'ssh-*' -print -quit)" ] ; then    
    sudo chgrp -Rf users {run/host,}/tmp/ssh-*
    sudo chmod -Rf 0770 {run/host,}/tmp/ssh-*
    export SSH_AUTH_SOCK=$(find /tmp /run/host/tmp/ \
        -type s -regex '.*/ssh-.*/agent..*$' -printf '%T@ %p\n' 2> /dev/null \
        | sort --numeric-sort | tail -n 1 | awk '{print $2}')
fi
