#!/bin/bash

if [ $DEBUG = true ]; then
    set -x
fi
cd "$HOME"

# Generate an ssh-key if one doesn't exist
if [ ! -f ".ssh/id_rsa" ]
then
    ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi

# If we are in cluster, set our default namespace
SERVICE_ACCOUNT_DIR=/var/run/secrets/kubernetes.io/serviceaccount
if [ -d $SERVICE_ACCOUNT_DIR ]; then
    export IN_CLUSTER=true
    kubectl config set-context $(kubectl config current-context) \
            --namespace=$(cat $SERVICE_ACCOUNT_DIR/namespace)
else
    export IN_CLUSTER=false
fi

if [ -z "$GIT_AUTHOR_EMAIL" ]; then
    echo "ERROR: GIT_AUTHOR_EMAIL env Must be set"
    exit 1
fi
if [ -z "$GIT_AUTHOR_NAME" ]; then
    echo "ERROR: GIT_AUTHOR_NAME env Must be set"
    exit 1
fi

export ALTERNATE_EDITOR=""
export TMATE_SOCKET="${TMATE_SOCKET:-/tmp/ii.default.target.iisocket}"
export TMATE_SOCKET_NAME=`basename ${TMATE_SOCKET}`
export INIT_ORG_FILE="${INIT_ORG_FILE:-~/}"
export INIT_DEFAULT_DIR="${INIT_DEFAULT_DIR:-~/}"
export INIT_DEFAULT_REPOS="${INIT_DEFAULT_REPOS}"
export INIT_DEFAULT_REPOS_FOLDER="${INIT_DEFAULT_REPOS_FOLDER}"
export INIT_PREFINISH_BLOCK="${INIT_PREFINISH_BLOCK}"
export HUMACS_PROFILE="${HUMACS_PROFILE:-ii}"

echo "$HUMACS_PROFILE" > ~/.emacs-profile

. /usr/local/bin/ssh-agent-export.sh

(
    if [ ! -z "$INIT_DEFAULT_REPOS" ]; then
        mkdir -p $INIT_DEFAULT_REPOS_FOLDER
        cd $INIT_DEFAULT_REPOS_FOLDER
        for repo in $INIT_DEFAULT_REPOS; do
            git clone -v --recursive "$repo"
        done
    fi
    cd
    eval "$INIT_PREFINISH_BLOCK"
)

# This background process will ensure tmate attach commands
# call osc52-tmate.sh to set the ssh/web uri for this session via osc52
# We need to wait's until the socket exists, and tmate is ready for commands
# before doing so. (Would be easier if this were a config option for .tmate.conf)
cd $INIT_DEFAULT_DIR
(
    if [ ! -f "$TMATE_SOCKET" ]
    then
        # wait for socket to appear
        echo -n "Waiting for $TMATE_SOCKET_NAME:"
        while read i; do
            if [ "$i" = $TMATE_SOCKET_NAME ]; then break; fi
            echo -n "."
        done \
            < <(inotifywait  -e create,open --format '%f' --quiet /tmp --monitor)
    fi
    tmate -S $TMATE_SOCKET wait-for tmate-ready
    tmate -S $TMATE_SOCKET set-hook -ug client-attached # unset
    tmate -S $TMATE_SOCKET set-hook -g client-attached 'run-shell "tmate new-window osc52-tmate.sh"'
)&

# This is our primary background process for humacs
# a tmate session in foreground mode, respawning if it dies
# A default directory and org file are used to start emacsclient as the main window
tmate -F -v -S $TMATE_SOCKET new-session -d -c $INIT_DEFAULT_DIR emacsclient --tty $INIT_ORG_FILE
