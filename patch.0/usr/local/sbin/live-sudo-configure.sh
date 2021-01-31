#!/bin/bash

# Проверяем наличие бинарника
test -x /usr/bin/sudo || exit 0

# Создаем группу для SUDO
groupadd -f adm

# Разрешаем этой группе использовать SUDO без пароля
echo '%adm ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/adm

exit 0
