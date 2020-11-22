#!/bin/bash

export TMATE_SOCKET="${TMATE_SOCKET:-/tmp/ii.default.target.iisocket}"

if [ ! -f "$TMATE_SOCKET" ]
then
    # wait for socket to appear
    echo "Waiting for '$TMATE_SOCKET_NAME'"
    until tmate -S $TMATE_SOCKET wait-for tmate-ready; do
        echo -n "."
        sleep 1
    done
fi
tmate -S $TMATE_SOCKET wait-for tmate-ready
echo "Socket '$TMATE_SOCKET_NAME' is ready"
