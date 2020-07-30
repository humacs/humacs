#!/bin/bash

if [ ! -n "$SSH_AUTH_SOCK" ] && [ -n "$(find /tmp -maxdepth 1 -name 'ssh-*' -print -quit)" ] ; then
    sudo chgrp -R users /tmp/ssh-*
    sudo chmod -R 0770 /tmp/ssh-*
    export SSH_AUTH_SOCK=$(find /tmp /run/host/tmp/ -type s -regex '.*/ssh-.*/agent..*$' 2> /dev/null | tail -n 1)
fi
