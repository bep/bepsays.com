#!/bin/bash

# convenience script to add, commit, push and deploy (acpd)

SOURCE="$( cd "$( dirname "$0" )" && pwd )"

. $SOURCE/script/common.sh

info "Source is $SOURCE ..."

[ "$#" -eq 1 ] || die "Commit message required."

COMMMSG=$1

info "Commit and push to GitHub ..."

{ git add -A && git commit -m "$COMMMSG"; } || die "Git commit failed"

git push origin master || die "Git push failed"

$SOURCE/deploy.sh || die "Deploy failed!"

info "Done!"

