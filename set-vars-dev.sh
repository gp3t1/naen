#/bin/sh

# Volumes configuration
export VOL_POSTGRES_BACKUPS="/tmp/naen/backups/postgres"
export VOL_POSTGRES_DATA="/tmp/naen/data/postgres"
export VOL_COMMAFEED_BACKUPS="/tmp/naen/backups/commafeed"
export VOL_COMMAFEED_CONFIG="/tmp/naen/config/commafeed"
export VOL_NGINX_BACKUPS="/tmp/naen/backups/nginx"
export VOL_NGINX_CONFIG="/tmp/naen/config/nginx"
export VOL_NGINX_LOG="/tmp/naen/log/nginx"
export VOL_NGINX_WWW="/tmp/naen/www"
export VOL_LETSENCRYPT_SSL="/etc/letsencrypt"

# Network configuration
export NETWORK_NAME="naen"
export HTTP_HOST_PORT='80'
export HTTPS_HOST_PORT='443'
export LETSENCRYPT_EMAIL="coucou@c.moi"

# DB Postgres configuration
export PG_LANG="fr_FR.UTF-8"
export PG_AREA="Europe"
export PG_ZONE="Paris"
export POSTGRES_PASSWORD="test"

# RSS Commafeed configuration
export DOMAIN="localhost"
export RSS_URI="/rss"
export RSS_USER="commafeed"
export RSS_PASSWORD="test"

# Docker misc
export POSTGRES_NAME="naen-postgres"
export COMMAFEED_NAME="naen-commafeed"
export NGINX_NAME="naen-nginx"

# Test compose file
if docker-compose --verbose -f docker-compose-dev.yml -p naen config ; then
	# Create the services
	printf "Create following services :\n%s\n" "$( docker-compose -f docker-compose-dev.yml -p naen config --services )"
	#docker-compose -f docker-compose-dev.yml -p naen create
fi