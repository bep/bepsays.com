#!/bin/bash

# common settings and functions

function info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function err { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

die () {
    err >&2 "$@"
    exit 1
}


# Import my dev env
. $HOME/dev_settings.sh