#!/bin/bash

export TMATE_SOCKET="${TMATE_SOCKET:-/tmp/ii.default.target.iisocket}"
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
(. $THISDIR/simple-init.sh) &
until tmate -S $TMATE_SOCKET wait-for tmate-ready; do
    echo -n "."
    sleep 1
done
tmate -S $TMATE_SOCKET attach
