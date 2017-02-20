FROM sstarcher/sensu:0.23.2

RUN gem install influxdb

RUN /bin/install memory-checks network-checks disk-checks load-checks process-checks io-checks cpu-checks
