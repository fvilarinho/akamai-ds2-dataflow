# Base image.
FROM bitnami/fluentd:1.18.0

USER root

# Installs the required plugins.
RUN fluent-gem install fluent-plugin-kafka && \
    fluent-gem install fluent-plugin-s3
