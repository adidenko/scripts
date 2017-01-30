FROM alpine:3.4
MAINTAINER Alex Didenko <adidenko@mirantis.com>

LABEL Name="dbox" Version="0.1"

ADD netchk.sh /usr/local/bin/netchk.sh

RUN apk update \
    && apk add wget iproute2 curl bash tcpdump vim screen

CMD ["/usr/local/bin/netchk.sh"]
