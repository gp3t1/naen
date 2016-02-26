FROM nginx:1.9

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

# RUN groupadd -r nginx --gid=999 && useradd -r -g nginx --uid=999 nginx
RUN  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget openssl \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove ca-certificates wget

RUN 	rm /etc/nginx/conf.d/default.conf \
	&& 	mv /etc/nginx/nginx.conf /etc/nginx/nginx_original.conf.bak \
	&&	mkdir -p 							/var/run/nginx /etc/nginx/templates \
	&&	chmod -R 600 					/var/run/nginx \
	&& 	chown -R nginx:nginx 	/var/run/nginx /var/log/nginx /usr/sbin/nginx
	
##		VOLUMES --------------------------
# 		from nginx image: ["/var/cache/nginx"]
VOLUME ["/var/log/nginx", "/usr/share/nginx", "/etc/nginx/conf.d", "/etc/letsencrypt", "/backups"]
WORKDIR /etc/nginx

##		ENV VARIABLES --------------------
#			FROM nginx : NGINX_VERSION

COPY docker-entrypoint.sh 	/
COPY templates/* 						/etc/nginx/templates/
COPY bin/*									/usr/local/bin/
RUN  chmod 700 /docker-entrypoint.sh \
	&& chmod +x /usr/local/bin/* \
	&& chown -R nginx:nginx /etc/nginx

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx"]
