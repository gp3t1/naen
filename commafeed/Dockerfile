FROM java:8-jre

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

##		ENV VARIABLES --------------------
ENV COMMAFEED_VERSION 2.2.0
ENV USER							commafeed
ENV PASSWORD					test
ENV PUBLIC_URL				"https://mydomain.xyz/rss"
ENV PG_URL						"jdbc:postgresql://localhost:5432/commafeed"

# explicitly set user/group IDs
RUN groupadd -r commafeed --gid=999 && useradd -r -g commafeed --uid=999 commafeed
#RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& mkdir -p /etc/commafeed /opt/commafeed /backups \
	&& curl -Lo /opt/commafeed/commafeed.jar "https://github.com/Athou/commafeed/releases/download/${COMMAFEED_VERSION}/commafeed.jar" \
	&& curl -Lo /opt/commafeed/templates/commafeed.yml.template "https://raw.githubusercontent.com/Athou/commafeed/${COMMAFEED_VERSION}/config.yml.example" \
	&& chmod -R 700 /opt/commafeed \
	&& chown -R commafeed.commafeed /opt/commafeed \
	&& chown -R commafeed.commafeed /etc/commafeed \
	&& apt-get purge -y --auto-remove ca-certificates wget

##		VOLUMES --------------------------
VOLUME ["/etc/commafeed", "/backups"]
WORKDIR /opt/commafeed

COPY bin/backup 					/usr/local/bin/backup
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN  chmod 700 /docker-entrypoint.sh /usr/local/bin/backup
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["commafeed"]
