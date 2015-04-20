#!/bin/bash

HUGOPORT=1313

function LaunchBrowser() {
  sleep 2
  xdg-open http://localhost:$HUGOPORT
}

hugo server -p $HUGOPORT -w & LaunchBrowser 

