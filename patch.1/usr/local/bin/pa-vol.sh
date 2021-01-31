#!/bin/bash

export LC_ALL=C
export STEPS=5

function notify() {
	test -z "$DISPLAY" && return

	local TYPE='выходы'
	local ACTION='включены'
	local SUFFIX='high'

	test $1 = 'sources' && TYPE='входы'
	test $2 = 'reset'   && ACTION='сброшены'
	test $2 = '1'       && SUFFIX=muted ACTION='заглушены'

	notify-send -i audio-volume-$SUFFIX "Звуковые $TYPE $ACTION" "Это действие повлияло на все звуковые устройства в системе";
}

function sinks() {
	pactl list short sinks   | awk '{ print $1 }'
}

function sources() {
	pactl list short sources | awk '{ print $1 }'
}

function sinkstate() {
	pactl list sinks   | grep -iP '^\smute: yes' > /dev/null && echo 0 && return

	echo 1
}

function sourcestate() {
	pactl list sources | grep -iP '^\smute: yes' > /dev/null && echo 0 && return

	echo 1
}

function plus() {
	pactl set-sink-volume @DEFAULT_SINK@ +$STEPS%
}

function minus() {
	pactl set-sink-volume @DEFAULT_SINK@ -$STEPS%
}

function mutesinks() {
	local SINKSTATE=$(sinkstate)

	notify sinks $SINKSTATE

	sinks   | xargs -rn1 --replace=? pactl set-sink-mute     ? $SINKSTATE
}

function mutesources() {
	local SINKSTATE=$(sinkstate)
	local SOURCESTATE=$(sourcestate)
	test $SINKSTATE -eq 1 || SOURCESTATE=1

	notify sources $SOURCESTATE

	sources | xargs -rn1 --replace=? pactl set-source-mute   ? $SOURCESTATE
}

function resetsinks() {
	notify sinks reset

	sinks   | xargs -rn1 --replace=? pactl set-sink-mute     ? 0
	sinks   | xargs -rn1 --replace=? pactl set-sink-volume   ? 90%
}

function resetsources() {
	notify sources reset

	sources | xargs -rn1 --replace=? pactl set-source-mute   ? 0
	sources | xargs -rn1 --replace=? pactl set-source-volume ? 90%
}

case "$1" in
	mute)
		mutesinks
		mutesources
	;;
	reset)
		resetsinks
		resetsources
	;;
	plus|minus|mutesinks|mutesources|resetsinks|resetsources)
		$1
	;;
esac
