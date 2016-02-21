#!/bin/bash

CFG_DIR=/etc/commafeed
CFG_NAME=commafeed.yml
CFG_FILE=$CFG_DIR/$CFG_NAME

chmod -R 600 "$CFG_DIR"
chown -R commafeed.commafeed "$CFG_DIR"

function setConfig {
	[[ ! -f $CFG_FILE ]] && cp "/opt/commafeed/templates/$CFG_NAME.template" "$CFG_FILE" && chmod -R 600 "$CFG_DIR"
  
  rm "$CFG_DIR/*.bak"
  sed -i.bak "	s|publicUrl:(.*)|publicUrl: ${PUBLIC_URL}|
								s|driverClass:(.*)|driverClass: org.postgresql.Driver|
								s|url:(.*)|url: ${PG_URL}|
								s|user:(.*)|user: ${USER}|
								s|password:(.*)|password: ${PASSWORD}|" "$CFG_FILE"
}

case $1 in
	commafeed )
		[[ ! -f $CFG_FILE ]] && setConfig
		echo "Starting commafeed..."
		gosu commafeed java -Djava.net.preferIPv4Stack=true -jar /opt/commafeed/commafeed.jar server "$CFG_FILE"
		;;
	*)
		exit 1
		;;
esac

