#!/bin/sh

cd $(dirname $0)

find . -mindepth 1 -maxdepth 1 \( -type d -or -type l \) -and -name 'patch.*' | sort | busybox xargs -rn1 sh repack.sh
