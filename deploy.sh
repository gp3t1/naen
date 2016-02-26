#!/bin/bash

if [[ $# -eq 1 && -f $1 ]]; then
	source "$1"
else
	echo "usage: $0 <set-env.sh>"
	exit 1
fi

#Create & Init Postgres
docker run --name="$POSTGRES_NAME" --net="$NETWORK_NAME" --net-alias="$POSTGRES_NAME" --hostname="$POSTGRES_NAME" \
	-e LANG="$PG_LANG" -e AREA="$PG_AREA" -e ZONE="$PG_ZONE" -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
	-v "$VOL_POSTGRES_BACKUPS":"/backups" -v "$VOL_POSTGRES_DATA":"/var/lib/postgresql/data" \
	gp3t1/postgres-hb:0.1-9.5 postgres
sleep 10 && docker exec "$POSTGRES_NAME" create_db "$RSS_USER" "$RSS_PASSWORD"

#Create Commafeed
# normalize uris
[[ $RSS_URI =~ ^/ ]] || RSS_URI="/$RSS_URI"
docker run --name="$COMMAFEED_NAME" --net="$NETWORK_NAME" --net-alias="$COMMAFEED_NAME" --hostname="$COMMAFEED_NAME" \
	-e PUBLIC_URL="https://${DOMAIN}${RSS_URI}" -e DB_URL="jdbc:postgresql://$POSTGRES_NAME:5432/$RSS_USER" -e USER="$RSS_USER" -e PASSWORD="$RSS_PASSWORD" \
	-v "$VOL_COMMAFEED_BACKUPS":"/backups" -v "$VOL_COMMAFEED_CONFIG":"/etc/commafeed" \
	gp3t1/commafeed:0.1-2.2.0 commafeed

#Renew ssl
docker run --name letsencrypt --rm -p "$HTTPS_HOST_PORT":"443" -p "$HTTP_HOST_PORT":"80" -v "$VOL_LETSENCRYPT_SSL":"/etc/letsencrypt" -v "/var/lib/letsencrypt":"/var/lib/letsencrypt" \
 	quay.io/letsencrypt/letsencrypt:latest certonly --keep-until-expiring --agree-tos --rsa-key-size 2048 --text --email "$LETSENCRYPT_EMAIL" --domain "$DOMAIN"

#Create Nginx
docker run --name="$NGINX_NAME" --net="$NETWORK_NAME" --net-alias="$NGINX_NAME" --hostname="$NGINX_NAME" \
	-v "$VOL_NGINX_LOG":"/var/log/nginx" -v "$VOL_NGINX_WWW":"/usr/share/nginx" -v "$VOL_NGINX_CONFIG":"/etc/nginx/conf.d" -v "$VOL_LETSENCRYPT_SSL":"/etc/letsencrypt" -v "$VOL_NGINX_BACKUPS":"/backups" \
	-p "$HTTP_HOST_PORT":"80" -p "HTTPS_HOST_PORT":"443" \
	gp3t1/nginx:0.1-1.9 nginx
docker exec "$NGINX_NAME" addHttpsDomain "$DOMAIN" "$COMMAFEED_NAME=$RSS_URI>$COMMAFEED_NAME:8082/"
