#!/bin/bash



SOURCE="$( cd "$( dirname "$0" )" && pwd )"
DESTINATION=$SOURCE/dist
LOG=$HOME/dev/log/hugobuild.log

. $SOURCE/script/common.sh

#[ "$#" -eq 1 ] || die "Commit message required."

info "Cleaning build folder $DESTINATION ... "
rm -rf $DESTINATION || die "Failed to remove destination."

info "Building static files ..."
grunt build || die "Failed to build static files"
info "Building site ..."
hugo --source="$SOURCE" --destination="$DESTINATION" --logFile="$LOG" || die "Failed to build site"

# safe guard - should never happen
find $DESTINATION -name "*.html" | xargs grep -q $DEV_DOMAIN
if [ "$?" -eq "0" ]
    then die "Site contains local settings"
fi

info "Deployment to GitHub ... "

$SOURCE/script/deploy.sh || die "Deployment failed."

# get it into dev shape again
grunt dev

info "****************** Done! *********************"



