# RabbitMQ cluster

## Setting up RabbitMQ cluster in Docker Swarm (Mode)

Official [clustering guidelines](https://www.rabbitmq.com/clustering.html)
suggest that there are a few ways to create RabbitMQ cluster. There are also
options that will allow creating clusters that could discover its nodes
automatically through some discovery service like Etcs or Consul.

> Due to the fact that our runtime environment is Docker Swarm where we will
  need to mount volumes to ensure that data is getting persisted and not lost
  over the course of RabbitMQ upgrade or a restart. For us it was proven to be
  highly problemmatic to make sure that new instances of RabbitMQ cluster get
  mounted to the same mount points and in the same time recognize new cluster
  configuration (since after restart all RabbitMQ nodes will have new
  hostnames while e.g. Consul still have an understanding of a cluster with old
  hostnames). There might be a solution to this which we would like to know
  about. So, if you are willing to contribute, please send us your pull request.

What this project attempts to do is to create a declarative approach to defining
RabbitMQ cluster i.e. define nodes that needs to be descovered on startup of
docker image.

Parameters that can control how exactly RabbitMQ is going to be configured are
here:

* `RABBITMQ_USER` - new user name
* `RABBITMQ_PASSWORD` - password for new user
* `RABBITMQ_CLUSTER_NODES` - a space delimited list of RabbitMQ
  nodes that it needs to connect to (`join_cluster`), e.g.
  `"rabbit@rabbit-1 rabbit@rabbit-2 rabbit@rabbit-3"`.
* `RABBITMQ_FIREHOSE_QUEUENAME` - queue name for
  **Firehose** tracing (if it is left blank **Firehose** will not be
  enabled)
* `RABBITMQ_FIREHOSE_ROUTINGKEY` - routing key that will be
  used to mount `amq.rabbitmq.trace` exchange with queue (name for
  which can be defined with `RABBITMQ_FIREHOSE_QUEUENAME`
  environment variable). The default value for it is `publish.#`.

Here is how we will do this (`Dockerfile`):

```{.Dockerfile}
FROM rabbitmq:management

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config
RUN chmod 777 /etc/rabbitmq/rabbitmq.config

ENV RABBITMQ_SETUP_DELAY=10
ENV RABBITMQ_USER user
ENV RABBITMQ_PASSWORD user
ENV RABBITMQ_CLUSTER_NODES=
ENV RABBITMQ_FIREHOSE_QUEUENAME=
ENV RABBITMQ_FIREHOSE_ROUTINGKEY=publish.#

RUN apt-get update -y && apt-get install -y python

ADD init.sh /init.sh
EXPOSE 15672

CMD ["/init.sh"]
```

We are taking our own `rabbitmq.config` file that has only one
important bit to it - cluster recovery mode:

```{.erlang}
%% -*- mode: erlang -*-
[
 {rabbit,
  [
   {cluster_partition_handling, autoheal}
  ]}
].
```

And we change our entry point to our own script where we can pre-configure a lot
of things (for that reason we needed to have `python` installed as
part of our image):

```{.bash}
#!/usr/bin/env bash

(
  sleep $RABBITMQ_SETUP_DELAY

  rabbitmqctl stop_app
  IFS=' '; read -ra xs <<< "$RABBITMQ_CLUSTER_NODES"
  for i in "${xs[@]}"; do
    echo "<< Joining cluster with [$i] ... >>"
    rabbitmqctl join_cluster "$i"
    echo "<< Joining cluster with [$i] DONE >>"
  done
  rabbitmqctl start_app

  rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASSWORD 2>/dev/null
  rabbitmqctl set_user_tags $RABBITMQ_USER administrator management
  rabbitmqctl set_permissions -p / $RABBITMQ_USER  ".*" ".*" ".*"
  rabbitmqctl set_policy \
    SyncQs \
    '.*' \
    '{"ha-mode":"all","ha-sync-mode":"automatic"}' \
    --priority 0 \
    --apply-to queues

  echo "*** User '$RABBITMQ_USER' with password '$RABBITMQ_PASSWORD' completed. ***"
  echo "*** Log in the WebUI at port 15672 (example: http:/localhost:15672) ***"

  if [[ "$RABBITMQ_FIREHOSE_QUEUENAME" -ne "" ]]; then
    echo "<< Enabling Firehose ... >>>"
    ln -s $(find -iname rabbitmqadmin ` head -1) /rabbitmqadmin
    chmod +x /rabbitmqadmin
    echo -n "Declaring '$RABBITMQ_FIREHOSE_QUEUENAME' queue ... "
    ./rabbitmqadmin declare queue name=$RABBITMQ_FIREHOSE_QUEUENAME
    ./rabbitmqadmin list queues
    echo -n "Declaring binding from 'amq.rabbitmq.trace' to '$RABBITMQ_FIREHOSE_QUEUENAME' ... "
    ./rabbitmqadmin declare binding \
      source=amq.rabbitmq.trace \
      destination=$RABBITMQ_FIREHOSE_QUEUENAME \
      routing_key=$RABBITMQ_FIREHOSE_ROUTINGKEY
    ./rabbitmqadmin list bindings
    rabbitmqctl trace_on
    echo "<< Enabling Firehose ... DONE >>>"
  fi

) & rabbitmq-server $@
```

> Notice that by default we create `SyncQs` policy that will
  automatically synchronize queues across all cluster nodes.

> `RABBITMQ_SETUP_DELAY` is used here to make sure different nodes are
  trying to join cluster and setup other things in different times.

## Configuring persistence layer

Let's now setup persistence layer such that after RabbitMQ restart data stays
intact. Since we are currently running 3 instances of RabbitMQ, we will need to
also create target folder for mount point that is going to be used by RabbitMQ
server (let's say on `SERVER1`, `SERVER3` and
`SERVER5`):

* On `SERVER1`: `$ mkdir -p /data/rabbitmq-1`
* On `SERVER3`: `$ mkdir -p /data/rabbitmq-2`
* On `SERVER5`: `$ mkdir -p /data/rabbitmq-3`

Then, we need to label our swarm cluster nodes appropriately.

```{.bash}
$ docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER
6so183185g8qd11aoix21rea1    SERVER5    Ready   Active        Reachable
920kij34jhrz76lprdthz2utz    SERVER3    Ready   Active        Reachable
9zlzpsto6m4f9h0inilgy2hkr    SERVER4    Ready   Active        Reachable
au00yheo9dvstjwvk3lo4l2oe *  SERVER1    Ready   Active        Reachable
c7n1elqonzsidncwlyg62d90v    SERVER2    Ready   Active        Leader

$ docker node update -label-add rabbitmq=1 au00yheo9dvstjwvk3lo4l2oe
$ docker node update -label-add rabbitmq=2 920kij34jhrz76lprdthz2utz
$ docker node update -label-add rabbitmq=3 6so183185g8qd11aoix21rea1
```

It is possible to see that label has been correctly set by invoking following
command:

```{.bash}
$ docker node inspect au00yheo9dvstjwvk3lo4l2oe
$ docker node inspect 920kij34jhrz76lprdthz2utz
$ docker node inspect 6so183185g8qd11aoix21rea1
```

> This will produce relatively big output, you will need to inspect
  `Spec > Labels` part of it.

And now, after we have configured our labels and created folder for mount point,
we can revisit service creation instructions for e.g. 3-noded RabbitMQ cluster:

```{.bash}
$ docker service create \
    -name rabbit-1 \
    -network net \
    -e RABBITMQ_SETUP_DELAY=120 \
    -e RABBITMQ_USER=admin \
    -e RABBITMQ_PASSWORD=adminpwd \
    -e RABBITMQ_CLUSTER_NODES='rabbit@rabbit-2 rabbit@rabbit' \
    -constraint node.labels.rabbitmq==1 \
    -mount type=bind,source=/data/rabbitmq-1,target=/var/lib/rabbitmq \
    -e RABBITMQ_NODENAME=rabbit@rabbit-1 \
    -e RABBITMQ_ERLANG_COOKIE=a-little-secret \
    -e RABBITMQ_FIREHOSE_QUEUENAME=trace \
    -e RABBITMQ_FIREHOSE_ROUTINGKEY=publish.# \
    kuznero/rabbitmq:3.6.6-cluster

$ docker service create \
    -name rabbit-2 \
    -network net \
    -e RABBITMQ_SETUP_DELAY=60 \
    -e RABBITMQ_USER=admin \
    -e RABBITMQ_PASSWORD=adminpwd \
    -e RABBITMQ_CLUSTER_NODES='rabbit@rabbit-1 rabbit@rabbit' \
    -constraint node.labels.rabbitmq==2 \
    -mount type=bind,source=/data/rabbitmq-2,target=/var/lib/rabbitmq \
    -e RABBITMQ_NODENAME=rabbit@rabbit-2 \
    -e RABBITMQ_ERLANG_COOKIE=a-little-secret \
    -e RABBITMQ_FIREHOSE_QUEUENAME=trace \
    -e RABBITMQ_FIREHOSE_ROUTINGKEY=publish.# \
    kuznero/rabbitmq:3.6.6-cluster

$ docker service create \
    -name rabbit \
    -network net \
    -p #{HTTP_UI_PORT}:15672 \
    -e RABBITMQ_SETUP_DELAY=20 \
    -e RABBITMQ_USER=admin \
    -e RABBITMQ_PASSWORD=adminpwd \
    -e RABBITMQ_CLUSTER_NODES='rabbit@rabbit-1 rabbit@rabbit-2' \
    -constraint node.labels.rabbitmq==3 \
    -mount type=bind,source=/data/rabbitmq-3,target=/var/lib/rabbitmq \
    -e RABBITMQ_NODENAME=rabbit@rabbit \
    -e RABBITMQ_ERLANG_COOKIE=a-little-secret \
    -e RABBITMQ_FIREHOSE_QUEUENAME=trace \
    -e RABBITMQ_FIREHOSE_ROUTINGKEY=publish.# \
    kuznero/rabbitmq:3.6.6-cluster
```

> This will start 3 different services (single replica services).

## Considerations for delivery pipeline for RabbitMQ cluster

All nodes of RabbitMQ cluster must run same version of RabbitMQ and OTP. That
enforces some limitations onto how it is possible to perform upgrades.
The only option for RabbitMQ cluster upgrade is during non-working hours when
there is no activity such that it is possible to bring whole cluster down and
upgrade it.
