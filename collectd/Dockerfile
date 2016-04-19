FROM ubuntu:14.04
MAINTAINER Vinicius Silva <sender@example.com>

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential snmp snmpd libperl-dev libsensors4-dev \
    && apt-get -y install collectd \
    && rm -rf /var/lib/apt/lists/* 

VOLUME /var/lib/collectd/ /var/log

CMD ["collectd", "-f"]
