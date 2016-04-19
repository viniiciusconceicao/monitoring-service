FROM ubuntu:14.04
MAINTAINER Vinicius Silva <viniicius.conceicao@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
    snmp \
    libperl-dev \
    libsensors4-dev \
    collectd \
  && rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/collectd/

CMD ["collectd", "-f"]
