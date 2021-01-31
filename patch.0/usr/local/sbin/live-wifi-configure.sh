#!/bin/bash

export ACCESSPOINTS=/usr/local/etc/accesspoints

if test -x /usr/bin/NetworkManager && test -f "${ACCESSPOINTS}" && test "$(cat ${ACCESSPOINTS} | wc -l)" -gt 0
then
	IFS=$'\n'
	for LINE in $(cat ${ACCESSPOINTS})
	do
		SSID=$(echo ${LINE} | awk '{ print $1 }')
		PASS=$(echo ${LINE} | awk '{ print $2 }')
		UUID=$(uuidgen)

		cat > /etc/NetworkManager/system-connections/${SSID}.nmconnection << EOF
[connection]
id=${SSID}
uuid=${UUID}
type=wifi

[wifi]
ssid=${SSID}

[wifi-security]
key-mgmt=wpa-psk
psk=${PASS}

[ipv4]
method=auto

[ipv6]
method=ignore

EOF
	done

	find /etc/NetworkManager/system-connections -type f -exec chmod 600 {} \;
fi

exit 0
