#!/bin/bash

export KAFKA_HOME_DIR=/opt/kafka_$SCALA_VERSION-$KAFKA_VERSION

eval "$KAFKA_HOME_DIR/bin/kafka-server-start.sh $ETC_DIR/$BROKER_NAME.properties"