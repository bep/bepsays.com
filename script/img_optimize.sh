#!/bin/bash

SOURCE="$( cd "$( dirname "$0" )" && pwd )"
IMG_PATH="$SOURCE/../static/img"

. $SOURCE/common.sh


info "Optimize images in $IMG_PATH ..."


find $IMG_PATH -name "*.jpg" -exec jpegtran -optimize -progressive -outfile "{}" "{}" \; || die "Failed for jpgs"

info "Done!"