#!/bin/bash

USERHOME=/home/$1
USERNAME=$1
GROUPNAME=$1
USERID=$2
GROUPID=$2
SUPPLEMENTARY_GROUPS=$3

function requested_groups() {
	echo -n 'users'
	echo -n ',audio,video'
	echo -n ',disk,optical,storage,rfkill,sys'
	echo -n ',lp,uucp'
	test -n "${SUPPLEMENTARY_GROUPS}" && echo -n ','${SUPPLEMENTARY_GROUPS}
}

function present_groups() {
	requested_groups | tr ',' '\n' | xargs -rn1 -I % grep -o '^%:' /etc/group | tr -d '\n' | tr ':' ',' | sed 's/.$//'
}

# Группа для пользователя
groupadd -g ${GROUPID} ${GROUPNAME}

# Создание пользователя
useradd -u ${USERID} -g ${GROUPID} -G $(present_groups) -d ${USERHOME} -s /bin/bash ${USERNAME}

# Работа с домашней директорией
mkdir -p ${USERHOME}
cp -an --no-preserve=ownership /etc/skel/. ${USERHOME}/
chown -R ${USERID}:${GROUPID} ${USERHOME}

# Делаем папки пользователя на английском языке
test -x /usr/bin/xdg-user-dirs-update && sudo -u ${USERNAME} env LC_ALL=C xdg-user-dirs-update --force

exit 0
