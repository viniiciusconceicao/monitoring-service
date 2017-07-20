FROM sstarcher/sensu:0.23.2

RUN gem install influxdb

RUN /bin/install memory-checks network-checks disk-checks process-checks io-checks cpu-checks snmp

RUN /opt/sensu/embedded/bin/gem install sensu-plugins-load-checks:0.0.4 -f

RUN apt-get clean \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

