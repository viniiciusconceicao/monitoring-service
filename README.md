# Distributed Monitoring Service (Seshat)
This repo presents the monitoring tool derived from Seshat, a layered cloud monitoring architecture which is scalable, elastic, responsive and extensible. Such architecture has been tested through this implementation based on open-source tools to monitor a massive data processing environment in which its scalability has been confirmed on this paper(http://portaldeconteudo.sbc.org.br/index.php/wperformance/article/view/3336). 
The monitoring service was built on top of Docker Swarm for Hadoop and Spark monitoring as well as general monitoring. Containers include: [Sensu, Collectd, Log4j, Python-Beaver](Data collection), [RabbitMQ, Logstash](Distributed transport), [InfluxDB,ElasticSearch](Distributed storage), [Grafana, Kibana](Visualization), [Riemann](Event correlation).

If you are interested in using this tool email me :)

Fun fact: Seshat is the name of an Egyptian goddess considered the keeper of records, responsible for recording the passage of time - https://en.wikipedia.org/wiki/Seshat

Also, there is another study (http://portaldeconteudo.sbc.org.br/index.php/wperformance/article/view/3338) about energy consumption on massive data processing environments in which this tool has been used.

![monitoring_estructured_swarm](https://user-images.githubusercontent.com/5986103/28787647-ad22d140-75e2-11e7-9fc1-4029854336e9.png)

## Setup
### On all nodes
* [Install Docker](https://docs.docker.com/engine/installation/)
* [Create Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)


```
# sysctl -w vm.max_map_count=262144
# git clone <THIS_REPO_URL>
```

#### Creating containers
```
# cd ~/monitoring-service/master/elk/dockerfiles/influxdb/1.0
# docker build -t influxdb:cluster .

# cd ~/monitoring-service/master/elk/dockerfiles/rabbitmq
# docker build -t rabbitmq:cluster .

# cd ~/monitoring-service/master/collectd
# docker build -t collectd:cluster .

# cd ~/monitoring-service/master/elk/logstash_shipper
# docker build -t logstash:shipper .

# cd ~/monitoring-service/master/elk/logstash_indexer
# docker build -t logstash:indexer .

```

### On swarm manager - ElasticSearch Network
```
# docker network create --driver overlay --subnet 10.0.10.0/24 \
 --opt encrypted elastic_cluste

# cd ~/monitoring-service/master/elk
# docker stack deploy -c docker-compose-stack.yml monitor
```

Check the service
` # docker service ls`

# TODO
* Separate containers in its own repo with automatic build on hub
* Use environment variables to fill sensitive data

