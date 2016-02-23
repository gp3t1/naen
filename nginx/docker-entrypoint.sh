#!/bin/bash

PID=/var/run/nginx/pid

CFG_DIR=/etc/nginx/conf.d
CFG_FILE=$CFG_DIR/nginx.conf
DHPARAM_FILE=$CFG_DIR/dhparam.pem

function check_dhparam {
	if [[ ! -f $DHPARAM_FILE ]]; then
		echo "$DHPARAM_FILE not found : Generating..."
		openssl dhparam -out "$DHPARAM_FILE" 2048
		[[ -f "$DHPARAM_FILE" ]]
	fi
}

function check_mime {
	if [[ ! -f ${CFG_DIR}/mime.types ]]; then
		cp "/etc/nginx/mime.types" "${CFG_DIR}/mime.types"
	fi
}

function test_nginx {
	echo "Testing nginx configuration"
	gosu nginx nginx -t -c ${CFG_FILE} -g "daemon off;pid $PID;"
	exit $?
}

function run_nginx {
	echo "Starting nginx..."
	exec gosu nginx nginx -c ${CFG_FILE} -g "daemon off;pid $PID;"
	exit $?
}

function main {
	if ! check_dhparam; then
		echo "Error generating dhparam ($DHPARAM_FILE) !"
		exit 1
	fi
	if ! check_mime; then
		echo "Error retrieving mime.types !"
		exit 1
	fi

	chmod 600				 	$CFG_DIR/*
	chown nginx:nginx $CFG_DIR/*

	if ! test_nginx; then
		echo "Error in configuration ($CFG_FILE) !"
		exit 1
	fi

	case $1 in
		nginx )
			run_nginx
			;;
		*)
			exit 1
			;;
	esac
}

main "$@"

