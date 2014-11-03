#!/bin/bash

# this only works with my patched (PoC) Hugo server and is very experimental
CURR_PATH=`cat /tmp/hugopath.txt`
CONTENT_PATH=/home/bep/dev/bepsays.com/content
MY_EDITOR=/opt/extras.ubuntu.com/uberwriter/bin/uberwriter

# fetch some chars at the end
MATCH_AGAINST=${CURR_PATH:${#str} - 15}

echo "Searching for $MATCH_AGAINST"

find $CONTENT_PATH . -iname "*.markdown" -exec grep -q "$MATCH_AGAINST" {} \; -exec $MY_EDITOR {} \;