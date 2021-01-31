#!/bin/bash

export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin

LOGFILE=/var/log/udev-usb.log
WAVPREFIX=/usr/local/share/udev-usb/device-plug

# Проверяем входящие параметры
test -z "$2" && exit 0

# Записываем событие в лог
echo $@ >> $LOGFILE 2>&1

for INSTANCE in $(find /run/user -mindepth 1 -maxdepth 1 | awk '{ print $0"/pulse" }') /var/run/pulse
do
	SOCKET=$INSTANCE/native

	# Проверяем, что сокет существует
	test -S $SOCKET || continue

	# Определяем владельца сокета
	OWNER=$(stat -c '%U' $SOCKET)

	# Проигрывание звукового файла
	test $1 = add    && echo "env PULSE_RUNTIME_PATH=$INSTANCE paplay $WAVPREFIX-in.wav"  | sudo -u $OWNER at now
	test $1 = remove && echo "env PULSE_RUNTIME_PATH=$INSTANCE paplay $WAVPREFIX-out.wav" | sudo -u $OWNER at now
done

exit 0
