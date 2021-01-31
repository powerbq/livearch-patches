#!/bin/bash

# Настройка базовых параметров
ln -srf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo ${HOSTNAME} > /etc/hostname
echo 'ru_RU.UTF-8 UTF-8' > /etc/locale.gen
echo 'ru_UA.UTF-8 UTF-8' >> /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'LANG=ru_UA.UTF-8' > /etc/locale.conf
locale-gen

# Настраиваем поведение при создании пользователя
sed -ri 's|^(GROUP=.*)$|# \1|' /etc/default/useradd

# Настраиваем TRIM на LVM2
sed -ri 's|^	issue_discards = 0|	issue_discards = 1|' /etc/lvm/lvm.conf

# Другие сервисы
test -f /usr/lib/systemd/system/atd.service && systemctl enable atd
test -f /usr/lib/systemd/system/iptables.service && systemctl enable iptables
test -f /usr/lib/systemd/system/irqbalance.service && systemctl enable irqbalance

# Выключаем таймер создания БД MAN
test -f /usr/lib/systemd/system/man-db.timer && systemctl mask man-db.timer

# Выключаем сервис, вызывающий ошибку при перезагрузке и выключении
test -f /usr/lib/systemd/system/mkinitcpio-generate-shutdown-ramfs.service && systemctl mask mkinitcpio-generate-shutdown-ramfs.service

exit 0
