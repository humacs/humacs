#!/bin/bash

export TMATE_SOCKET="${TMATE_SOCKET:-/tmp/ii.default.target.iisocket}"
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
(. $THISDIR/simple-init.sh 2>&1 > ~/humacs.log) &
echo -n "Humacs starting:"
# Sleep a second while we wait for the client-attched hook to exist
until tmate -S $TMATE_SOCKET show-hooks -g 2>&1 | grep new-window\ osc52 2>&1 >/dev/null ; do
    echo -n "."
    sleep 1
done
echo ""
echo "Launching Humacs"
sleep 2
tmate -S $TMATE_SOCKET attach
