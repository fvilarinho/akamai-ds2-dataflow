#!/bin/bash

# Home directory.
export KAFKA_HOME_DIR=/opt/kafka_$SCALA_VERSION-$KAFKA_VERSION

# Check if the broker name is present and start the broker with the correspondent settings.
if [ -z "$BROKER_NAME" ]; then
  eval "$KAFKA_HOME_DIR/bin/kafka-server-start.sh $KAFKA_HOME_DIR/server.properties"
else
  eval "$KAFKA_HOME_DIR/bin/kafka-server-start.sh $ETC_DIR/$BROKER_NAME.properties"
fi