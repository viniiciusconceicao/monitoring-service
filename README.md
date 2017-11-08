# monitoring-service
A distributed Monitoring Service build as a Docker Swarm service for Hadoop and Spark monitoring as well as general monitoring. Containers: Sensu, InfluxDB, Grafana, Collectd, ElasticSearch, Logstash, Kibana, Riemann and also RabbitMQ as a transport layer. Additionally, an event engine called Riemann for stream process.
If you are interested in using this tool email me :)
![monitoring_estructured_swarm](https://user-images.githubusercontent.com/5986103/28787647-ad22d140-75e2-11e7-9fc1-4029854336e9.png)

## Setup
### on all nodes
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

### on swarm manager
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

