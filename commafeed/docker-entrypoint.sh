#!/bin/bash

APP_DIR="/opt/commafeed"
APP_FILE="$APP_DIR/commafeed.jar"
CFG_DIR="/etc/commafeed"
CFG_NAME="commafeed.yml"
CFG_FILE="$CFG_DIR/$CFG_NAME"
NGINX_TMP="/templates/nginx.conf"
NGINX_CFG_DIR="/etc/nginx/conf.d/sites-enabled"
NGINX_CFG_FILE="$NGINX_CFG_DIR/commafeed.conf"
HOST=$(hostname)
PG_INIT_TMP="/templates/01_commafeed.sql"
PG_INIT_DIR=/docker-entrypoint-initdb.d
PG_INIT_FILE="$PG_INIT_DIR/01_commafeed.sql"

function setRights {
	chmod 		660 "$CFG_FILE"
	chmod 		770 "$APP_FILE" "/var/log/commafeed"
	chown 		commafeed:commafeed "$CFG_FILE" "$APP_FILE" "/var/log/commafeed"
}

function setConfig {
  if [[ ! -f $CFG_FILE ]] ;then
  	rm "$CFG_DIR/*.bak"
  	sed "	s|publicUrl:.*$|publicUrl: https://${DOMAIN}${URI}|
  				s|currentLogFilename:.*$|currentLogFilename: /var/log/commafeed/commafeed.log|
  				s|archivedLogFilenamePattern:.*$|archivedLogFilenamePattern: /var/log/commafeed/commafeed-%d.log|
					s|driverClass:.*$|driverClass: org.postgresql.Driver|
					s|url:.*$|url: ${DB_URL}|
					s|user:.*$|user: ${DB_USER}|
					s|password:.*$|password: ${DB_PASSWORD}|" "/opt/commafeed/templates/$CFG_NAME.template" > "$CFG_FILE" \
			&& echo "Commafeed Configuration generated in $CFG_FILE"
		if [[ ! -f "$CFG_FILE" ]]; then
			echo "Error generating config file for commafeed!"
			exit 1
		fi
	fi
	return 0
}

function set_nginx_server {
	if [[ ! -f "$NGINX_CFG_FILE" ]] ; then
		mkdir -p "$NGINX_CFG_DIR"
		sed -e "s|<HOST>|${HOST}|g
						s|<DOMAIN>|${DOMAIN}|g
						s|<URI>|${URI}|g" "$NGINX_TMP" > "$NGINX_CFG_FILE" \
			&& chmod 660 "$NGINX_CFG_FILE" \
			&& echo "Nginx Configuration generated in $NGINX_CFG_FILE"
		if [[ ! -f "$NGINX_CFG_FILE" ]]; then
			echo "Error generating config file for nginx!"
			exit 1
		fi
	fi
	return 0
}

function postgres_status {
	local tmp=$(  echo "$DB_URL" | awk -F "/*" '{ print $2 }' )
	local DB_HOST=$( echo "$tmp" | awk -F ':' '{ print $1 }' )
	local DB_PORT=$( echo "$tmp" | awk -F ':' '{ print $2 }' )

	timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DB_HOST/$DB_PORT" &>/dev/null
	local res1=$?
	
	sleep 3
	timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DB_HOST/$DB_PORT" &>/dev/null
	local res2=$?
	
	sleep 3
	timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DB_HOST/$DB_PORT" &>/dev/null
	local res3=$?

	if [[ $res1 -eq 0 && $res2 -eq 0 && $res3 -eq 0 ]] ; then
		printf "Postgres UP!\n" && return 0
	else
		printf "." && return 1
	fi
}

function set_postgres_db {
	sed -e "s|<USER>|${DB_USER}|g
					s|<PASSWORD>|${DB_PASSWORD}|g" "$PG_INIT_TMP" > "$PG_INIT_FILE" \
		&& chmod 660 "$PG_INIT_FILE" \
		&& echo "Postres database creation script generated in $PG_INIT_FILE"
	if [[ ! -f "$PG_INIT_FILE" ]]; then
		echo "Error generating database creation script for postgres!"
		exit 1
	fi
	return 0
}

function wait_postgres {
	local start=$(date +%s)
	printf "Waiting for Postgres instance(timeout=%s)" "$DB_TIMEOUT"
	while ! postgres_status ; do
		sleep 1
		local tstamp=$(date +%s)
		if [[ $(( tstamp - start )) -gt $DB_TIMEOUT ]]; then
			printf "\nCan't connect to postgres instance(>%ss)" "$DB_TIMEOUT"
			exit 1
		fi
	done
	return 0
}

case $1 in
	commafeed )
		[[ $URI =~ ^/ ]] || URI="/$URI" && export URI
		setConfig && set_nginx_server && set_postgres_db && setRights
		wait_postgres
		echo "Starting commafeed..."
		exec gosu commafeed java -Djava.net.preferIPv4Stack=true -jar "$APP_FILE" server "$CFG_FILE"
		;;
	*)
		exit 1
		;;
esac

