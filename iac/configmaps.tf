# Defines the settings for the stack.
resource "local_file" "configmaps" {
  filename = abspath(pathexpand("./configmaps.yaml"))
  content = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: inbound-settings
  namespace: ${var.settings.general.identifier}
data:
  fluentd.conf: |
    <source>
      @type http
      port 9880
      bind 0.0.0.0
      <parse>
        @type none
      </parse>
    </source>

    <match ingest>
      @type kafka
      brokers queue-broker:9092
      default_topic ${var.settings.dataflow.inbound.identifier}
    </match>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: outbound-settings
  namespace: ${var.settings.general.identifier}
data:
  fluentd.conf: |
    <source>
      @type kafka_group
      brokers queue-broker:9092
      topics ${var.settings.dataflow.outbound.identifier}
      consumer_group outbound
    </source>

    <match ${var.settings.dataflow.outbound.identifier}>
      @type s3
      aws_key_id ${var.settings.dataflow.outbound.storage.accessKey}
      aws_sec_key ${var.settings.dataflow.outbound.storage.secretKey}
      s3_bucket ${var.settings.dataflow.outbound.storage.bucket}
      s3_endpoint ${var.settings.dataflow.outbound.storage.endpoint}
      s3_region us-east-1
      path ${var.settings.dataflow.outbound.storage.path}
      time_slice_format %Y%m%d%H%M
      store_as ${var.settings.dataflow.outbound.storage.format}

      <buffer time>
        @type file
        path /opt/bitnami/fluentd/logs
        timekey ${var.settings.dataflow.outbound.storage.aggregationPeriod}
        timekey_wait 10m
        timekey_use_utc true
        chunk_limit_size 256m
        flush_mode interval
        flush_interval 10s
      </buffer>
    </match>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: queue-broker-settings
  namespace: ${var.settings.general.identifier}
data:
  server.properties: |
    listeners=INTERNAL://:9092,EXTERNAL://:9093
    listener.security.protocol.map=INTERNAL:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
    inter.broker.listener.name=INTERNAL
    sasl.enabled.mechanisms=PLAIN
    sasl.mechanism.inter.broker.protocol=PLAIN
    listener.name.external.sasl.enabled.mechanisms=PLAIN
    listener.name.sasl_plaintext.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
      username="${var.settings.dataflow.auth.user}" \
      password="${var.settings.dataflow.auth.password}" \
      user_${var.settings.dataflow.auth.user}="${var.settings.dataflow.auth.password}";

    zookeeper.connect=queue-broker-manager:2181
    log.dir=/bitnami/kafka/data
    log.retention.minutes=10
    message.max.bytes=16777216
    replica.fetch.max.bytes=16777216
    default.replication.factor=${var.settings.cluster.nodes.count}
    offsets.topic.replication.factor=${var.settings.cluster.nodes.count}
    transaction.state.log.replication.factor=${var.settings.cluster.nodes.count}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: proxy-settings
  namespace: ${var.settings.general.identifier}
data:
  default.conf: |
    server {
      listen 80;

      auth_basic "Restricted Area";
      auth_basic_user_file /etc/nginx/.htpasswd;

      location / {
        return 403;
      }

      location = /ingest {
        limit_except POST {
          deny all;
        }

        client_max_body_size 10M;

        proxy_pass http://inbound:9880/ingest;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      }

      location ^~ /panel {
        proxy_pass http://queue-broker-ui:8080/panel;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      }

      location = /404.html {
        internal;
      }
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: converter-settings
  namespace: ${var.settings.general.identifier}
data:
  settings.json: |
    {
      "kafka": {
        "brokers": [
          "queue-broker:9092"
        ],
        "inboundTopic": "${var.settings.dataflow.inbound.identifier}",
        "outboundTopic": "${var.settings.dataflow.outbound.identifier}"
      },
      "filters": [
        {
          "fieldName": "UA",
          "regex": "Googlebot|AdsBot-Google|Google-Structured-Data-Testing-Tool",
          "include": false
        }
      ],
      "workers": 100
    }
EOT
}