#!/bin/bash

CLEAN=1
IMG_POSTGRES=gp3t1/postgres-hb:dev-0.1-9.5
IMG_COMMAFEED=gp3t1/commafeed:dev-0.1-2.3.0
IMG_NGINX=gp3t1/nginx:dev-0.1-1.9

if [[ $# -eq 1 && -f $1 ]]; then
	source "$1"
else
	echo "usage: $0 <set-env.sh>"
	exit 1
fi
# normalize uri
[[ $RSS_URI =~ ^/ ]] || RSS_URI="/$RSS_URI"

docker network create "$NETWORK_NAME"

if [[ $CLEAN -eq 0 ]]; then
	docker rm -f -v "$NGINX_NAME" "$COMMAFEED_NAME" "$POSTGRES_NAME"
	docker rmi "$IMG_NGINX" "$IMG_COMMAFEED" "$IMG_POSTGRES"
	for path in "$VOL_POSTGRES_DATA" "$VOL_COMMAFEED_CONFIG" "$VOL_NGINX_CONFIG" "$VOL_NGINX_WWW" ; do
		if [[ -d "$path" ]]; then
			echo -n "remove $path? "
			sudo rm -rI "$path"
		fi
	done
fi

#Create Commafeed
docker run -d --name="$COMMAFEED_NAME" --net="$NETWORK_NAME" --net-alias="$COMMAFEED_NAME" --hostname="$COMMAFEED_NAME" \
	-e DOMAIN="${DOMAIN}" -e URI="${RSS_URI}" -e DB_URL="jdbc:postgresql://$POSTGRES_NAME:5432/$RSS_USER" -e DB_USER="$RSS_USER" -e DB_PASSWORD="$RSS_PASSWORD" \
	-v "$VOL_COMMAFEED_BACKUPS:/backups" -v "$VOL_COMMAFEED_CONFIG:/etc/commafeed" -v "$VOL_COMMAFEED_LOG:/var/log/commafeed" -v "$VOL_NGINX_CONFIG:/etc/nginx/conf.d:z" -v "$VOL_POSTGRES_INIT:/docker-entrypoint-initdb.d:z" \
	"$IMG_COMMAFEED" commafeed

#Create & Init Postgres
docker run -d --name="$POSTGRES_NAME" --net="$NETWORK_NAME" --net-alias="$POSTGRES_NAME" --hostname="$POSTGRES_NAME" \
	-e LANG="$PG_LANG" -e AREA="$PG_AREA" -e ZONE="$PG_ZONE" -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
	-v "$VOL_POSTGRES_BACKUPS:/backups" -v "$VOL_POSTGRES_DATA:/var/lib/postgresql/data" -v "$VOL_POSTGRES_INIT:/docker-entrypoint-initdb.d:z" \
	"$IMG_POSTGRES" postgres 

#Create Nginx
docker run -d --name="$NGINX_NAME" --net="$NETWORK_NAME" --net-alias="$NGINX_NAME" --hostname="$NGINX_NAME" \
	-e LETSENCRYPT_EMAIL="$LETSENCRYPT_EMAIL" \
	-v "$VOL_NGINX_LOG:/var/log/nginx" -v "$VOL_NGINX_WWW:/usr/share/nginx" -v "$VOL_NGINX_CONFIG:/etc/nginx/conf.d:z" -v "$VOL_LETSENCRYPT_SSL:/etc/letsencrypt:z" -v "$VOL_NGINX_BACKUPS:/backups" \
	-p "$HTTP_HOST_PORT:80" -p "$HTTPS_HOST_PORT:443" \
	"$IMG_NGINX" nginx

#Renew ssl
#docker run --name letsencrypt --rm -p "$HTTPS_HOST_PORT:443" -p "$HTTP_HOST_PORT:80" -v "$VOL_LETSENCRYPT_SSL:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
# 	quay.io/letsencrypt/letsencrypt:latest certonly --keep-until-expiring --agree-tos --rsa-key-size 2048 --text --email "$LETSENCRYPT_EMAIL" --domain "$DOMAIN"	