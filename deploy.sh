#!/bin/bash

function info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function err { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

die () {
    err >&2 "$@"
    exit 1
}


# Import my dev env
. $HOME/dev_settings.sh

DESTINATION=$HOME/dev/bepsays.com/public
SOURCE=$HOME/dev/bepsays.com
LOG=$HOME/dev/log/hugobuild.log

[ "$#" -eq 1 ] || die "Commit message required."

info "Cleaning build folder $DESTINATION ... "
rm -rf $DESTINATION || die "Failed to remove destination."

info "Building static files ..."
grunt build || die "Failed to build static files"
info "Building site ..."
hugo --source="$SOURCE" --destination="$DESTINATION" --logFile="$LOG" || die "Failed to build site"

# safe guard - should never happen
find public -name "*.html" | xargs grep -q $DEV_DOMAIN
if [ "$?" -eq "0" ]
    then die "Site contains local settings"
fi

info "Deploy to GitHub ..."
{ git add -A && git commit -m "$1" && git push origin master && git subtree push --prefix=public origin gh-pages;} || die "Failed to push to Git. Nothing changed?"

# get it into dev shape again
grunt dev

info "****************** Done! *********************"



