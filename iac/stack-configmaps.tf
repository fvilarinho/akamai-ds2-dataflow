locals {
  # Creates all queue brokers endpoints. It is used in the config maps and deployments.
  internalQueueBrokersEndpoints = [
    for index in range(0, var.settings.cluster.nodes.count) : "queue-broker-${index}.queue-broker.${var.settings.general.identifier}.svc.cluster.local:9092"
  ]

  # Creates a indented list with all queue brokers endpoints. It is used in the config maps.
  internalQueueBrokersListTabulation = join("", tolist([for index in range(10) : " "]))
  internalQueueBrokersList = [
    for item in local.internalQueueBrokersEndpoints : "${local.internalQueueBrokersListTabulation}\"${item}\""
  ]

  # Defines the credentials and endpoint of the outbound storage.
  outboundStorageAccessKey = (length(var.settings.dataflow.outbound.storage.accessKey) > 0 ? var.settings.dataflow.outbound.storage.accessKey : linode_object_storage_key.outbound[0].access_key)
  outboundStorageSecretKey = (length(var.settings.dataflow.outbound.storage.secretKey) > 0 ? var.settings.dataflow.outbound.storage.secretKey : linode_object_storage_key.outbound[0].secret_key)
  outboundStorageEndpoint = (length(var.settings.dataflow.outbound.storage.endpoint) > 0 ? var.settings.dataflow.outbound.storage.endpoint : "https://${var.settings.dataflow.outbound.storage.region}-1.linodeobjects.com")

  # Defines the queue broker manager settings.
  queueBrokerManagerSettings = [ <<EOT
  queue-broker-0.properties: |
    broker.id=0
    listeners=INTERNAL://:9092,EXTERNAL://:9093
    listener.security.protocol.map=INTERNAL:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
    listener.name.external.sasl.enabled.mechanisms=PLAIN
    inter.broker.listener.name=INTERNAL
    sasl.enabled.mechanisms=PLAIN
    sasl.mechanism.inter.broker.protocol=PLAIN
    advertised.listeners=INTERNAL://queue-broker-0.queue-broker.${var.settings.general.identifier}.svc.cluster.local:9092,EXTERNAL://${linode_instance.clusterManager.ip_address}:30093

    zookeeper.connect=queue-broker-controller:2181
    log.dir=/home/kafka-broker/data
    log.retention.minutes=10
    message.max.bytes=16777216
    replica.fetch.max.bytes=16777216
    default.replication.factor=${var.settings.cluster.nodes.count}
    offsets.topic.replication.factor=${var.settings.cluster.nodes.count}
    transaction.state.log.replication.factor=${var.settings.cluster.nodes.count}
EOT
  ]

  # Defines the queue broker worker settings.
  queueBrokerWorkerSettings = [ for index in range(1, var.settings.cluster.nodes.count) : <<EOT
  queue-broker-${index}.properties: |
    broker.id=${index}
    listeners=INTERNAL://:9092,EXTERNAL://:9093
    listener.security.protocol.map=INTERNAL:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
    listener.name.external.sasl.enabled.mechanisms=PLAIN
    inter.broker.listener.name=INTERNAL
    sasl.enabled.mechanisms=PLAIN
    sasl.mechanism.inter.broker.protocol=PLAIN
    advertised.listeners=INTERNAL://queue-broker-${index}.queue-broker.${var.settings.general.identifier}.svc.cluster.local:9092,EXTERNAL://${linode_instance.clusterWorker[index - 1].ip_address}:30093

    zookeeper.connect=queue-broker-controller:2181
    log.dir=/home/kafka-broker/data
    log.retention.minutes=10
    message.max.bytes=16777216
    replica.fetch.max.bytes=16777216
    default.replication.factor=${var.settings.cluster.nodes.count}
    offsets.topic.replication.factor=${var.settings.cluster.nodes.count}
    transaction.state.log.replication.factor=${var.settings.cluster.nodes.count}
EOT
  ]
}

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
      brokers ${join(",", local.internalQueueBrokersEndpoints)}
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
      brokers ${join(",", local.internalQueueBrokersEndpoints)}
      topics ${var.settings.dataflow.outbound.identifier}
      consumer_group outbound
    </source>

    <match ${var.settings.dataflow.outbound.identifier}>
      @type s3
      aws_key_id ${local.outboundStorageAccessKey}
      aws_sec_key ${local.outboundStorageSecretKey}
      s3_endpoint ${local.outboundStorageEndpoint}
      s3_bucket ${var.settings.dataflow.outbound.storage.bucket}
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
${join("\n", local.queueBrokerManagerSettings)}
${join("\n", local.queueBrokerWorkerSettings)}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: monitoring-server-settings
  namespace: ${var.settings.general.identifier}
data:
  prometheus.yml: |
    scrape_configs:
    - job_name: 'queue-broker-monitoring'
      scrape_interval: 5s
      static_configs:
      - targets: ['queue-broker-monitoring-agent:9308']
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
${join(",\n", local.internalQueueBrokersList)}
        ],
        "inboundTopic": "${var.settings.dataflow.inbound.identifier}",
        "outboundTopic": "${var.settings.dataflow.outbound.identifier}"
      },
      "count": ${var.settings.dataflow.converter.count},
      "filters": ${jsonencode(var.settings.dataflow.converter.filters)},
      "workers": ${var.settings.dataflow.converter.workers}
    }
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

      location / {
        return 403;
      }

      location = /ingest {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;

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
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_pass http://queue-broker-ui:8080/panel;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      }

      location ^~ /dashboards {
        proxy_pass http://grafana:3000/dashboards;
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
EOT

  depends_on = [
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    linode_object_storage_bucket.outbound,
    linode_object_storage_key.outbound
  ]
}