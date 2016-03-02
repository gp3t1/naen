FROM java:8-jre

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

##		ENV VARIABLES --------------------
ENV COMMAFEED_VERSION 2.2.0
ENV USER							commafeed
ENV PASSWORD					test
ENV PUBLIC_URL				"https://mydomain.xyz/rss"
ENV DB_URL						"jdbc:postgresql://naen-postgres:5432/commafeed"

##		VOLUMES --------------------------
VOLUME ["/etc/commafeed", "/backups"]
WORKDIR /opt/commafeed

# explicitly set user/group IDs
RUN groupadd -r commafeed --gid=999 && useradd -r -g commafeed --uid=999 commafeed

# install gosu
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates \
	&& rm -rf 				/var/lib/apt/lists/* \
	&& wget -O 				/usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O 				/usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify 	/usr/local/bin/gosu.asc \
	&& rm 						/usr/local/bin/gosu.asc \
	&& chmod +x 			/usr/local/bin/gosu \
	&& mkdir -p 			/home/commafeed \
	&& chmod 700			/home/commafeed \
	&& chown commafeed:commafeed /home/commafeed
	
# install commafeed
RUN  mkdir -p /etc/commafeed /opt/commafeed/templates /backups \
	&& curl -Lo /opt/commafeed/commafeed.jar "https://github.com/Athou/commafeed/releases/download/${COMMAFEED_VERSION}/commafeed.jar" \
	&& curl -Lo /opt/commafeed/templates/commafeed.yml.template "https://raw.githubusercontent.com/Athou/commafeed/${COMMAFEED_VERSION}/config.yml.example" \
	&& chmod 770 /opt/commafeed/commafeed.jar \
	&& chown -R commafeed:commafeed /opt/commafeed

COPY bin/* 								/usr/local/bin/
COPY docker-entrypoint.sh /
RUN  chmod 700 /docker-entrypoint.sh /usr/local/bin/backup

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["commafeed"]
