#!/bin/bash

gulp build

s3deploy -source=dist/ -region=eu-west-1 -bucket=bepsays.com