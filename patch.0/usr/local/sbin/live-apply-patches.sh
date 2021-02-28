#!/bin/bash

# Подгружаем переменные окружения при необходимости
if test -z "${LIVE_MOUNT}" || test -z "${LIVE_PREFIX}"
then
	source /etc/profile.d/livearch.sh
fi

# Выходим, если негде искать патчи
test -d ${LIVE_MOUNT}/${LIVE_PREFIX} || exit 0

# Применяем патчи в порядке сортировки (если есть)
find ${LIVE_MOUNT}/${LIVE_PREFIX} -type f -name 'patch.*.tar.gz' | sort | busybox xargs -rn1 tar -zxp -C / -f
find ${LIVE_MOUNT}/${LIVE_PREFIX} -type d -name 'patch.*'        | sort | busybox xargs -rn1 -I % /usr/bin/cp -a --reflink=auto --no-preserve=ownership %/. /

exit 0
