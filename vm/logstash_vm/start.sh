groupadd `stat -c "%g" /host/var/log/`
usermod -a -G `stat -c "%g" /host/var/log/` logstash
logstash --debug -f /etc/logstash/conf.d/logstash.conf
