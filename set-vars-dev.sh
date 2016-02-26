#/bin/sh

# Volumes configuration
VOL_POSTGRES_BACKUPS="/tmp/naen/backups/postgres"
VOL_POSTGRES_DATA="/tmp/naen/data/postgres"
VOL_COMMAFEED_BACKUPS="/tmp/naen/backups/commafeed"
VOL_COMMAFEED_CONFIG="/tmp/naen/config/commafeed"
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
POSTGRES_PASSWORD="test"

# RSS Commafeed configuration
DOMAIN="localhost"
RSS_URI="/rss"
RSS_USER="commafeed"
RSS_PASSWORD="test"

# Docker misc
POSTGRES_NAME="naen-postgres"
COMMAFEED_NAME="naen-commafeed"
NGINX_NAME="naen-nginx"

# Test compose file
if docker-compose --verbose -f docker-compose-dev.yml -p naen config ; then
	# Create the services
	printf "Create following services :\n%s\n" "$( docker-compose -f docker-compose-dev.yml -p naen config --services )"
	#docker-compose -f docker-compose-dev.yml -p naen create
fi