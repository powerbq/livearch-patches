#!/bin/bash

for SOURCE in $(find /usr/local/etc/x-started.d -maxdepth 1 -type f | sort)
do
	source $SOURCE >> /var/log/x-started.log 2>&1
done

exit 0
