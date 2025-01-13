FROM alpine:3.20

ENV KAFKA_VERSION=3.9.0
ENV SCALA_VERSION=2.13

ENV HOME_DIR=/home/kafka-broker
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV SECURITY_DIR=${HOME_DIR}/security
ENV DATA_DIR=${HOME_DIR}/data

RUN mkdir -p ${HOME_DIR} \
             ${BIN_DIR} \
             ${ETC_DIR} \
             ${DATA_DIR} \
             ${SECURITY_DIR}

RUN apk update && \
    apk add --no-cache bash \
                       ca-certificates \
                       curl \
                       unzip \
                       nss \
                       net-tools \
                       bind-tools \
                       openjdk21-jre

RUN cd /opt && \
    curl https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -o kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar xvzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    rm -f kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

COPY bin/startup.sh ${BIN_DIR}/

RUN ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
