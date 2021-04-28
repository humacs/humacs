#!/bin/bash

if [ $_ = $0 ]; then
    echo "Usage:
    . /usr/local/bin/ssh-agent-export.sh"
    exit
fi

if [ -n "$(find /tmp -maxdepth 1 -name 'ssh-*' -print -quit)" ] ; then    
    sudo chgrp -R users /tmp/ssh-*
    sudo chmod -R 0770 /tmp/ssh-*
    export SSH_AUTH_SOCK=$(find /tmp /run/host/tmp/ -type s -regex '.*/ssh-.*/agent..*$' 2> /dev/null | tail -n 1)
fi
