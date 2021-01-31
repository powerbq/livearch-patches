#!/bin/bash

if test -f /usr/lib/systemd/system/NetworkManager.service && test "${NETWORK_SYSTEMD}" != yes
then
	# Включаем NetworkManager
	systemctl enable NetworkManager
else
	# Выключаем NetworkManager
	test -f /usr/lib/systemd/system/NetworkManager.service && systemctl mask NetworkManager.service

	# Вычищаем автозагрузку от NetworkManager
	rm -f /etc/xdg/autostart/nm-*

	# Настройка сети
	systemctl enable systemd-networkd

	# Настройка DNS
	systemctl enable systemd-resolved
	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

exit 0
