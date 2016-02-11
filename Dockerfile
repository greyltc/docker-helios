# Arch Linux container with helios viting server
FROM greyltc/lamp:dev
MAINTAINER Grey Christoforo <grey@christoforo.net>

# install helios
ADD setup-helios.sh /usr/sbin/setup-helios
RUN setup-helios

ADD run-helios.sh /usr/bin/run-helios

EXPOSE 80
EXPOSE 443

ENV START_MYSQL false
ENV DO_SSL_SELF_GENERATION false
ENV START_APACHE true
ENV START_POSTGRESQL true

CMD start-servers; run-helios; sleep infinity
