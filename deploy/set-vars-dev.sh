#/bin/sh

function user_settings {
	#You can safely edit yout configuration in this function

	# Postgres Volumes
	VOL_POSTGRES_BACKUPS="/tmp/naen/backups/postgres"
	VOL_POSTGRES_DATA="/tmp/naen/data/postgres"
	VOL_POSTGRES_INIT="/tmp/naen/init/postgres"
	# Commafeed Volumes
	VOL_COMMAFEED_BACKUPS="/tmp/naen/backups/commafeed"
	VOL_COMMAFEED_CONFIG="/tmp/naen/config/commafeed"
	VOL_COMMAFEED_LOG="/tmp/naen/log/commafeed"
	# Nginx Volumes
	VOL_NGINX_BACKUPS="/tmp/naen/backups/nginx"
	VOL_NGINX_CONFIG="/tmp/naen/config/nginx"
	VOL_NGINX_LOG="/tmp/naen/log/nginx"
	VOL_NGINX_WWW="/tmp/naen/www"
	# SSL Certificates Volume
	VOL_LETSENCRYPT_SSL="/etc/letsencrypt"

	# Network configuration
	NETWORK_NAME="naen"
	HTTP_HOST_PORT='80'
	HTTPS_HOST_PORT='443'

	# DB Postgres configuration
	PG_LANG="fr_FR.UTF-8"
	PG_AREA="Europe"
	PG_ZONE="Paris"
	# RSS Commafeed configuration
	DOMAIN="localhost"
	RSS_URI="/rss"
	RSS_USER="commafeed"
	RSS_ADMIN_EMAIL="changeme@toto.com"
	# SSL Configuration
	LETSENCRYPT_EMAIL="changeme@toto.com"

	# Docker Containers Names
	POSTGRES_NAME="naen-postgres"
	COMMAFEED_NAME="naen-commafeed"
	NGINX_NAME="naen-nginx"
}

function askPasswords {
	# Postgres Configuration
	POSTGRES_PASSWORD=$(askPasswordTwice "postgres (postgres user)")
	RSS_PASSWORD=$(askPasswordTwice "$RSS_USER (postgres user)")
	# Commafeed Configuration
	RSS_ADMIN_PASSWORD=$(askPasswordTwice "admin (commafeed usser)")	
}


function askPasswordTwice {
	local tmp_pass1=""
	local tmp_pass2=""
  local retry=0
	if [[ $# -lt 1 ]]; then
		echo ""
		return 1
	fi

	stty -echo
	while [[ -z "$tmp_pass1" || -z "$tmp_pass2" || "$tmp_pass1" != "$tmp_pass2" ]]; do
		if [[ $retry -gt 0 ]]; then
			printf "WARNING : passwords don't match. Please type again...\n" 1>&2
		fi
		printf "Password for %s : " "$1" 1>&2
		read tmp_pass1
		printf "\n" 1>&2
		printf "Password for %s (verification) : " "$1" 1>&2
		read tmp_pass2
		printf "\n" 1>&2
		retry=$(( retry + 1 ))
	done
	stty echo
	echo "$tmp_pass1"
	return 0
}

function simpleCheck {
	POSTGRES_PATHS="\"$VOL_POSTGRES_BACKUPS\" \"$VOL_POSTGRES_DATA\" \"$VOL_POSTGRES_INIT\""
	COMMAFEED_PATHS="\"$VOL_COMMAFEED_BACKUPS\" \"$VOL_COMMAFEED_CONFIG\" \"$VOL_COMMAFEED_LOG\""
	NGINX_PATHS="\"$VOL_NGINX_BACKUPS\" \"$VOL_NGINX_CONFIG\" \"$VOL_NGINX_LOG\" \"$VOL_NGINX_WWW\""
	OTHER_PATHS="\"$VOL_LETSENCRYPT_SSL\""
	STRINGS="\"$NETWORK_NAME\" \"$HTTP_HOST_PORT\" \"$HTTPS_HOST_PORT\" \"$PG_LANG\" \"$PG_AREA\" \"$PG_ZONE\" \"$DOMAIN\" \"$RSS_URI\" \"$RSS_USER\" \"$POSTGRES_NAME\" \"$COMMAFEED_NAME\" \"$NGINX_NAME\""
	EMAILS="\"$RSS_ADMIN_EMAIL\" \"$LETSENCRYPT_EMAIL\""
	PASSWORDS="\"$POSTGRES_PASSWORD\" \"$RSS_PASSWORD\" \"$RSS_ADMIN_PASSWORD\""
	for path in $POSTGRES_PATHS $COMMAFEED_PATHS $NGINX_PATHS $OTHER_PATHS; do
		if [[ -z "$path" || "$path" == "\"\"" ]]; then
			echo "found volume with empty path!"
			exit 1
		fi
		[[ ! -e "$path" ]] && mkdir -m 700 -v -p "$path"
		if [[ ! -d "$path" || ! -w "$path" ]]; then
			echo "$path not writeable!"
			exit 1
		fi
	done
	for string in $STRINGS $EMAILS $PASSWORDS; do
		if [[ -z "$string" || "$string" == "\"\"" ]]; then
			echo "found an empty config variable!"
			exit 1
		fi
	done
}

function main {
	user_settings
	askPasswords
	# Test compose file
	if docker-compose --verbose -f docker-compose-dev.yml -p naen config ; then
		# Create the services
		printf "Create following services :\n%s\n" "$( docker-compose -f docker-compose-dev.yml -p naen config --services )"
		docker-compose -f docker-compose-dev.yml -p naen create
	fi	
}


