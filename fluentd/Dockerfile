# Base image.
FROM bitnami/fluentd:1.18.0

# File Author / Maintainer.
LABEL maintainer="Felipe Vilarinho <fvilarin@akamai.com>"

USER root

# Installs the required plugins.
RUN fluent-gem install fluent-plugin-kafka && \
    fluent-gem install fluent-plugin-s3
