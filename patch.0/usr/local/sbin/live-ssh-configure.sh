#!/bin/bash

# Проверяем наличие бинарника
test -f /usr/lib/systemd/system/sshd.service || exit 0

# Включение и настройка SSH
systemctl enable sshd

# Настройка параметров SSH
sed -i 's/^#X11Forwarding .*/X11Forwarding yes/' /etc/ssh/sshd_config

exit 0
