#!/bin/bash

# Launches the steambox image with direct connections to the specified
# user's X session, ALSA, and PulseAudio.
#
# Author: rsharo <rsharo@users.noreply.github.com>

### functions

function disclaimer() {
	cat << EOF
$0: WARNING: This script launches a steambox Docker container with
unrestricted access to your X session and audio drivers.

There are no provisions stopping the container from:
   1) Showing you spoofed windows, including prompts to enter your password.
   2) Accessing your microphone
   3) Capturing mouse gestures and/or keystrokes
   4) Playing polka music or even worse... Justin Bieber.

EOF

	read -n 1 -t 20 -p "Are you sure you want to continue? [N/y] " response
	echo
	if [[ "${response}" != "y" ]]; then
		echo "Exiting." >&2
		exit 1
	fi
}


### Main script

disclaimer $0

STEAMUSER_DISPLAY=${STEAMUSER_DISPLAY:-":0"}

echo STEAMUSER_UID=${STEAMUSER_UID:?"$0: you must set the environment variable STEAMUSER_UID"}
echo STEAMUSER_HOME=${STEAMUSER_UID:?"$0: you must set the environment variable STEAMUSER_HOME"}
echo STEAMUSER_DISPLAY=${STEAMUSER_DISPLAY}

STEAMHOME="${STEAMUSER_HOME}/steamhome"

declare -a HOMEDIR_ARGS=( -v "${STEAMHOME}:/home/steamuser" )

declare -a DRIDEVS=(/dev/dri/*)
declare -a X11_ARGS=(
	-v /tmp/.X11-unix:/tmp/.X11-unix
	${DRIDEVS[@]/#/--device }
	--env "DISPLAY=${STEAMUSER_DISPLAY}"
)

declare -a ALSA_ARGS=( --device /dev/snd )

declare -a PULSE_ARGS=(
	-v /dev/shm:/dev/shm
	-v /etc/machine-id:/etc/machine-id:ro
	-v "/run/user/${STEAMUSER_UID}/pulse:/run/user/${STEAMUSER_UID}/pulse"
	-v /var/lib/dbus:/var/lib/dbus
	-v "${STEAMUSER_HOME}/.pulse:${STEAMHOME}/.pulse"
)

echo $0: Using args: "${HOMEDIR_ARGS[@]}" "${X11_ARGS[@]}" "${ALSA_ARGS[@]}" "${PULSE_ARGS[@]}"

if [[ ! -d "${STEAMHOME}" ]] ; then
	echo "$0: The steam home directory '${STEAMHOME}' does not exist or is not a directory. Please create it with the appropriate user permissions." 2>&1
	exit 1
fi


${DOCKER:-docker} run -ti --rm --name steambox \
	"${HOMEDIR_ARGS[@]}" "${X11_ARGS[@]}" "${ALSA_ARGS[@]}" "${PULSE_ARGS[@]}" \
	steambox "$@"

