FROM logstash:2.4 

RUN logstash-plugin install logstash-input-jmx

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-e",""]
