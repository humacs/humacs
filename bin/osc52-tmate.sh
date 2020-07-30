#!/bin/bash
# xtermcontrol --title k8s@iimacs.org
tmate display -p "#{tmate_ssh} # #{tmate_web} $(date) #{client_tty}@#{host}" | osc52.sh
