#groupadd `stat -c "%g" /host/var/log/`
#usermod -a -G `stat -c "%g" /host/var/log/` root
#filebeat -e -d "*" -c filebeat.yml
beaver -c /app/beaver.conf -t rabbitmq
