#!/bin/bash

APP_DIR="/opt/commafeed"
APP_FILE="$APP_DIR/commafeed.jar"
CFG_DIR="/etc/commafeed"
CFG_NAME="commafeed.yml"
CFG_FILE="$CFG_DIR/$CFG_NAME"


function setConfig {
  if [[ ! -f $CFG_FILE ]] ;then
  	rm "$CFG_DIR/*.bak"
  	sed "	s|publicUrl:.*$|publicUrl: ${PUBLIC_URL}|
					s|driverClass:.*$|driverClass: org.postgresql.Driver|
					s|url:.*$|url: ${DB_URL}|
					s|user:.*$|user: ${USER}|
					s|password:.*$|password: ${PASSWORD}|" "/opt/commafeed/templates/$CFG_NAME.template" > "$CFG_FILE"
		echo "Configuration generated in $CFG_FILE"
	fi
}

function setRights {
	chmod 600 "$CFG_FILE"
	chmod 700 "$APP_FILE"
	chown commafeed:commafeed "$CFG_FILE" "$APP_FILE"
}

case $1 in
	commafeed )
		setConfig
		setRights
		echo "Starting commafeed..."
		exec gosu commafeed java -Djava.net.preferIPv4Stack=true -jar "$APP_FILE" server "$CFG_FILE"
		;;
	*)
		exit 1
		;;
esac

