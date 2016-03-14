#/bin/sh

# Volumes configuration
VOL_POSTGRES_BACKUPS="/tmp/naen/backups/postgres"
VOL_POSTGRES_DATA="/tmp/naen/data/postgres"
VOL_POSTGRES_INIT="/tmp/naen/init/postgres"

VOL_COMMAFEED_BACKUPS="/tmp/naen/backups/commafeed"
VOL_COMMAFEED_CONFIG="/tmp/naen/config/commafeed"
VOL_COMMAFEED_LOG="/tmp/naen/log/commafeed"

VOL_NGINX_BACKUPS="/tmp/naen/backups/nginx"
VOL_NGINX_CONFIG="/tmp/naen/config/nginx"
VOL_NGINX_LOG="/tmp/naen/log/nginx"
VOL_NGINX_WWW="/tmp/naen/www"

VOL_LETSENCRYPT_SSL="/etc/letsencrypt"

# Network configuration
NETWORK_NAME="naen"
HTTP_HOST_PORT='80'
HTTPS_HOST_PORT='443'
LETSENCRYPT_EMAIL="coucou@c.moi"

# DB Postgres configuration
PG_LANG="fr_FR.UTF-8"
PG_AREA="Europe"
PG_ZONE="Paris"

# RSS Commafeed configuration
DOMAIN="localhost"
RSS_URI="/rss"
RSS_USER="commafeed"


# Docker misc
POSTGRES_NAME="naen-postgres"
COMMAFEED_NAME="naen-commafeed"
NGINX_NAME="naen-nginx"

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

POSTGRES_PASSWORD=$(askPasswordTwice "postgres")
RSS_PASSWORD=$(askPasswordTwice "$RSS_USER")

# Test compose file
if docker-compose --verbose -f docker-compose-dev.yml -p naen config ; then
	# Create the services
	printf "Create following services :\n%s\n" "$( docker-compose -f docker-compose-dev.yml -p naen config --services )"
	docker-compose -f docker-compose-dev.yml -p naen create
fi