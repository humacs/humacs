#!/bin/bash

if [ "$HUMACS_DEBUG" = true ]; then
    set -x
fi
cd "$HOME"

export TMATE_SOCKET="${TMATE_SOCKET:-/tmp/ii.default.target.iisocket}"
export TMATE_SOCKET_NAME=`basename ${TMATE_SOCKET}`
if tmate -S $TMATE_SOCKET wait-for tmate-ready 2> /dev/null; then
    set +x
    echo "Already initialised with tmate ready."
    echo "Use: attach"
    exit 0
fi

# Generate an ssh-key if one doesn't exist
if [ ! -f ".ssh/id_rsa" ]
then
    ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi

chmod 0600 $HOME/.kube/config
# If we are in cluster, set our default namespace
SERVICE_ACCOUNT_DIR=/var/run/secrets/kubernetes.io/serviceaccount
if [ -d $SERVICE_ACCOUNT_DIR ]; then
    export IN_CLUSTER=true
    kubectl config set-context $(kubectl config current-context) \
            --namespace=$(cat $SERVICE_ACCOUNT_DIR/namespace)

    /usr/local/bin/k8s-service-ingress-port-bind-reconciler.sh &
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
export INIT_ORG_FILE="${INIT_ORG_FILE:-$HOME}"
export INIT_DEFAULT_DIR="${INIT_DEFAULT_DIR:-$HOME}"
export INIT_DEFAULT_REPOS="${INIT_DEFAULT_REPOS}"
export INIT_DEFAULT_REPOS_FOLDER="${INIT_DEFAULT_REPOS_FOLDER:-$INIT_DEFAULT_DIR}"
export INIT_PREFINISH_BLOCK="${INIT_PREFINISH_BLOCK}"
export HUMACS_PROFILE="${HUMACS_PROFILE:-doom}"

echo "$HUMACS_PROFILE" > ~/.emacs-profile

. /usr/local/bin/ssh-agent-export.sh

if [ "$REINIT_HOME_FOLDER" = "true" ]; then
    (
        cd /etc/skel
        cp -r . /home/ii
        chmod 0600 $HOME/.kube/config
    )
fi

if [ "$HUMACS_PROFILE" = "doom" ]; then
    # ensure that the user and default configs are loaded, based on if the Humacs profile is doom
    (
        cd /var/local/humacs
        rm -f config.el init.el packages.el
        # More logic needed her to have per person config.org
       /var/local/humacs/doom-emacs/bin/org-tangle /var/local/humacs/config.org
       /var/local/humacs/doom-emacs/bin/doom sync
    )
fi

(
    if [ ! -z "$INIT_DEFAULT_REPOS" ]; then
        mkdir -p $INIT_DEFAULT_REPOS_FOLDER
        for repo in $INIT_DEFAULT_REPOS; do
            cd $INIT_DEFAULT_REPOS_FOLDER
            re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(.git|)$"

            if [[ $repo =~ $re ]]; then    
                protocol=${BASH_REMATCH[1]}
                separator=${BASH_REMATCH[2]}
                hostname=${BASH_REMATCH[3]}
                org=${BASH_REMATCH[4]}
                reponame=${BASH_REMATCH[5]%.git}
            fi

            mkdir -p ${org}/${reponame}
            git clone -v --recursive $repo "${org}/${reponame}"
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
    /usr/local/bin/tmate-wait-for-socket.sh
    tmate -S $TMATE_SOCKET set-hook -ug client-attached # unset
    tmate -S $TMATE_SOCKET set-hook -g client-attached 'run-shell "tmate new-window osc52-tmate.sh"'
)&

# This is our primary background process for humacs
# a tmate session in foreground mode, respawning if it dies
# A default directory and org file are used to start emacsclient as the main window
tmate -F -v -S $TMATE_SOCKET new-session -d -c $INIT_DEFAULT_DIR emacsclient --tty $INIT_ORG_FILE
