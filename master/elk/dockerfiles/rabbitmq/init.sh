#!/usr/bin/env bash

(
  echo "RABBITMQ_SETUP_DELAY          = $RABBITMQ_SETUP_DELAY"
  echo "RABBITMQ_USER                 = $RABBITMQ_USER"
  echo "RABBITMQ_PASSWORD             = $RABBITMQ_PASSWORD"
  echo "RABBITMQ_CLUSTER_NODES        = $RABBITMQ_CLUSTER_NODES"
  echo "RABBITMQ_FIREHOSE_QUEUENAME   = $RABBITMQ_FIREHOSE_QUEUENAME"
  echo "RABBITMQ_FIREHOSE_ROUTINGKEY  = $RABBITMQ_FIREHOSE_ROUTINGKEY"

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
  rabbitmqctl set_policy SyncQs '.*' '{"ha-mode":"all","ha-sync-mode":"automatic"}' --priority 0 --apply-to queues

  echo "*** User '$RABBITMQ_USER' with password '$RABBITMQ_PASSWORD' completed. ***"

  if [[ "$RABBITMQ_FIREHOSE_QUEUENAME" != "" ]]; then
    echo "<< Enabling Firehose ... >>>"
    ln -s $(find -iname rabbitmqadmin | head -1) /rabbitmqadmin
    chmod +x /rabbitmqadmin
    echo -n "Declaring '$RABBITMQ_FIREHOSE_QUEUENAME' queue ... "
    ./rabbitmqadmin declare queue name=$RABBITMQ_FIREHOSE_QUEUENAME
    ./rabbitmqadmin list queues
    echo -n "Declaring binding from 'amq.rabbitmq.trace' to '$RABBITMQ_FIREHOSE_QUEUENAME' with '$RABBITMQ_FIREHOSE_ROUTINGKEY' routing key ... "
    ./rabbitmqadmin declare binding source=amq.rabbitmq.trace destination=$RABBITMQ_FIREHOSE_QUEUENAME routing_key=$RABBITMQ_FIREHOSE_ROUTINGKEY
    ./rabbitmqadmin list bindings
    rabbitmqctl trace_on
    echo "<< Enabling Firehose ... DONE >>>"
  fi

) & rabbitmq-server $@
