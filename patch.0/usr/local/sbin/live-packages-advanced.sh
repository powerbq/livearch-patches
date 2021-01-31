#!/bin/bash

# Устанавливаем дополнительные пакеты
LIST=$(find /var/cache/pacman/pkg -mindepth 1 -maxdepth 1 -type f -name '*.pkg.*')
test -n "${LIST}" && yes | pacman -U ${LIST} && rm -f ${LIST}

exit 0
