# Defines the settings for the stack.
resource "local_file" "configmaps" {
  filename = abspath(pathexpand("./configmaps.yaml"))
  content = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: inbound-settings
  namespace: ${var.settings.cluster.identifier}
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
      @type kafka2
      brokers queue-broker:9092
      default_topic ${var.settings.dataflow.inbound.identifier}
      <format>
        @type json
      </format>
      sasl_over_ssl false
      username ${var.settings.dataflow.auth.user}
      password ${var.settings.dataflow.auth.password}
    </match>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: outbound-settings
  namespace: ${var.settings.cluster.identifier}
data:
  fluentd.conf: |
    <source>
      @type kafka
      brokers queue-broker:9092
      topics ${var.settings.dataflow.outbound.identifier}
      sasl_over_ssl false
      username ${var.settings.dataflow.auth.user}
      password ${var.settings.dataflow.auth.password}
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
        timekey_wait 1m
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
  namespace: ${var.settings.cluster.identifier}
data:
  server.properties: |
    listeners=SASL_PLAINTEXT://:9092
    security.protocol=SASL_PLAINTEXT
    security.inter.broker.protocol=SASL_PLAINTEXT
    sasl.mechanism.inter.broker.protocol=PLAIN
    sasl.enabled.mechanisms=PLAIN
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
  namespace: ${var.settings.cluster.identifier}
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

        proxy_pass http://inbound:9880/ingest;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
      }

      location ^~ /panel {
        proxy_pass http://queue-broker-ui:8080/panel;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
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
  namespace: ${var.settings.cluster.identifier}
data:
  settings.json: |
    {
      "kafka": {
        "brokers": [
          "queue-broker:9092"
        ],
        "auth": {
          "user": "${var.settings.dataflow.auth.user}",
          "password": "${var.settings.dataflow.auth.password}"
        },
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
      "workers": 10
    }
EOT
}