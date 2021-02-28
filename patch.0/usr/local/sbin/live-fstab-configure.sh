#!/bin/bash

# Создаем точки монтирования
cat /etc/fstab | grep -Pv '^(#|$)' | awk '{print $2}' | grep -P '^/.+' | busybox xargs -rn1 -I % sh -c 'mkdir -p %'

exit 0
