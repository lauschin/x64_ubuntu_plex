#!/bin/bash

#Potential add-on ideas to main x64_ubuntu-plex script,
#giving users option to reset msmtp inputs if an error is noticed before
#moving on to cleanup steps.  Updates script from Shell (Dash) to Bash.

msmtp() {
while true; do
	echo "Confirm email address:"
	read -p 'Email: ' varmail
	echo "Confirm username:"
	read -p 'Username: ' varuser
	msmtp-check
done
}
smtp-check() {
while true; do
	echo "
$varmail
$varuser"
	echo "Is this correct?"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) cleanup;;
			No ) msmtp;;
		esac
	done
done
}
cleanup() {
while true; do
	echo "Setup is finished."
	exit 1
done
}
msmtp
