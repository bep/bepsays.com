#!/bin/sh

# Import my dev env
. $HOME/dev_settings.sh

nohup grunt &

hugo version && echo "--------------------------------------------------\n" &&  hugo server --baseUrl=http://$DEV_DOMAIN/ -D -w -d dev
