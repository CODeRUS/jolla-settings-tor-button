#!/bin/bash

USERPREF=/home/nemo/.mozilla/mozembed/prefs.js

function clear_prefs {
	echo "Clearing proxy prefs"
	sed -i '/"network.proxy.socks"/d' $USERPREF
	sed -i '/"network.proxy.socks_port"/d' $USERPREF
	sed -i '/"network.proxy.type"/d' $USERPREF
	sed -i '/"network.proxy.socks_remote_dns"/d' $USERPREF
}

case "$1" in
	"on")
		clear_prefs
		echo "Enabling Tor proxy prefs"
		echo 'user_pref("network.proxy.socks", "127.0.0.1");' >> "$USERPREF"
		echo 'user_pref("network.proxy.socks_port", 9050);' >> "$USERPREF"
		echo 'user_pref("network.proxy.type", 1);' >> "$USERPREF"
		echo 'user_pref("network.proxy.socks_remote_dns", true);' >> "$USERPREF"
		;;
	"off")
		clear_prefs
		;;
	"kill")
		echo "Killing sailfish-browser"
		if /sbin/pidof sailfish-browser > /dev/null; then
			killall -s HUP sailfish-browser
		fi
		;;
esac

exit 0
