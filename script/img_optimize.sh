#!/bin/bash

SOURCE="$( cd "$( dirname "$0" )" && pwd )"
IMG_PATH="$SOURCE/../static/assets/img"

. $SOURCE/common.sh

info "Optimize images in $IMG_PATH ..."

# Handle jpgs
# you will need the libjpeg-progs package to run this - note the -progressive option added
find $IMG_PATH -name "*.jpg" -exec jpegtran -optimize -progressive -outfile "{}" "{}" \; || die "Failed for jpgs"

# handle pngs
find $IMG_PATH -name "*.png" -exec pngcrush -ow "{}"  \; || die "Failed for pngs"

info "Done!"
