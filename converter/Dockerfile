# Base image.
FROM alpine:3.21

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

# Environment variables.
ENV BASE_DIR=/home
ENV HOME_DIR=${BASE_DIR}/converter
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV LIBS_DIR=${HOME_DIR}/lib
ENV LOGS_DIR=${HOME_DIR}/logs
ENV MONITORING_HOSTNAME=monitoring-database
ENV MONITORING_PORT=8086

# Installs the dependencies.
RUN apk update && \
    apk add --no-cache bash \
                       ca-certificates \
                       curl \
                       unzip \
                       nss \
                       net-tools \
                       bind-tools \
                       openjdk21-jre

# Creates the default directory structure.
RUN mkdir -p ${HOME_DIR} \
             ${BIN_DIR} \
             ${ETC_DIR} \
             ${LIBS_DIR} \
             ${LOGS_DIR}

# Copies the required files.
COPY src/main/resources/bin ${BIN_DIR}
COPY src/main/resources/etc/banner.txt ${ETC_DIR}/
COPY src/main/resources/etc/settings.json ${ETC_DIR}/settings.json
COPY build/distributions/converter.zip ${BASE_DIR}/

# Installs the converter.
RUN cd ${BASE_DIR} && \
    unzip converter.zip && \
    rm -f converter.zip && \
    rm ${BIN_DIR}/converter.bat && \
    mv ${BIN_DIR}/converter ${BIN_DIR}/run.sh

# Define the permissions and entrypoint file.
RUN addgroup -S converter && \
    adduser -S converter -G converter && \
    chown -R converter:converter ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Default user.
USER converter

# Default work directory.
WORKDIR ${HOME_DIR}

ENTRYPOINT ["/entrypoint.sh"]