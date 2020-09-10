#!/bin/bash

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $THISDIR/simple-init.sh
tmate -S $TMATE_SOCKET wait-for tmate-ready
tmate -S $TMATE_SOCKET attach
