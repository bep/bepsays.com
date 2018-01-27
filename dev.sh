#!/bin/bash

SOURCE="$( cd "$( dirname "$0" )" && pwd )"

DEV_DOMAIN="bep.local"

cd $HOME/go/src/github.com/gohugoio/hugo

go install || die "Hugo build failed!"

cd $SOURCE

nohup gulp &


hugo version && echo "-----------------------------------------------------------------------------------" &&  hugo server --navigateToChanged --i18n-warnings --baseUrl=http://$DEV_DOMAIN/ --bind=$DEV_DOMAIN -D -w
