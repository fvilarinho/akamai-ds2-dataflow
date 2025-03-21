locals {
  monitoredQUeueBrokersListTabulation = join("", tolist([for index in range(10) : " "]))
  monitoredQUeueBrokersList = [
    for item in local.internalQueueBrokersEndpoints : "${local.monitoredQUeueBrokersListTabulation}- \"--kafka.server=${item}\""
  ]
}

# Defines the containers of the stack.
resource "local_file" "deployments" {
  filename = abspath(pathexpand("./deployments.yaml"))
  content = <<EOT
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: inbound
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    matchLabels:
      app: inbound
  template:
    metadata:
      labels:
        app: inbound
    spec:
      restartPolicy: Always
      containers:
        - name: inbound
          image: $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/fluentd:$BUILD_VERSION
          ports:
            - containerPort: 9880
          volumeMounts:
            - name: inbound-settings
              mountPath: /opt/bitnami/fluentd/conf/fluentd.conf
              subPath: fluentd.conf
      volumes:
        - name: inbound-settings
          configMap:
            name: inbound-settings
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: outbound
  namespace: ${var.settings.general.identifier}
spec:
  replicas: ${var.settings.dataflow.outbound.count}
  selector:
    matchLabels:
      app: outbound
  template:
    metadata:
      labels:
        app: outbound
    spec:
      restartPolicy: Always
      containers:
        - name: outbound
          image: $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/fluentd:$BUILD_VERSION
          volumeMounts:
            - name: outbound-settings
              mountPath: /opt/bitnami/fluentd/conf/fluentd.conf
              subPath: fluentd.conf
      volumes:
        - name: outbound-settings
          configMap:
            name: outbound-settings
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: converter
  namespace: ${var.settings.general.identifier}
spec:
  replicas: ${var.settings.dataflow.converter.count}
  selector:
    matchLabels:
      app: converter
  template:
    metadata:
      labels:
        app: converter
    spec:
      restartPolicy: Always
      containers:
        - name: converter
          image: $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/ds2-kafka-converter:$BUILD_VERSION
          imagePullPolicy: Always
          volumeMounts:
            - name: converter-settings
              mountPath: /home/converter/etc/settings.json
              subPath: settings.json
      volumes:
        - name: converter-settings
          configMap:
            name: converter-settings
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: queue-broker-controller
  namespace: ${var.settings.general.identifier}
spec:
  serviceName: queue-broker-controller
  replicas: 1
  selector:
    matchLabels:
      app: queue-broker-controller
  template:
    metadata:
      labels:
        app: queue-broker-controller
    spec:
      restartPolicy: Always
      containers:
        - name: queue-broker-controller
          image: bitnami/zookeeper:3.8.4
          imagePullPolicy: Always
          env:
            - name: ALLOW_ANONYMOUS_LOGIN
              value: "yes"
          ports:
            - containerPort: 2181
          volumeMounts:
            - name: queue-broker-controller-data
              mountPath: /bitnami/zookeeper/data
  volumeClaimTemplates:
    - metadata:
        name: queue-broker-controller-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: queue-broker
  namespace: ${var.settings.general.identifier}
spec:
  serviceName: queue-broker
  replicas: ${var.settings.cluster.nodes.count}
  selector:
    matchLabels:
      app: queue-broker
  template:
    metadata:
      labels:
        app: queue-broker
    spec:
      restartPolicy: Always
      containers:
        - name: queue-broker
          image: $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/kafka-broker:$BUILD_VERSION
          imagePullPolicy: Always
          env:
            - name: BROKER_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KAFKA_OPTS
              value: "-Djava.security.auth.login.config=/home/kafka-broker/security/server_jaas.conf"
          ports:
            - containerPort: 9092
            - containerPort: 9093
          volumeMounts:
            - name: queue-broker-settings
              mountPath: /home/kafka-broker/etc
            - name: queue-broker-auth
              mountPath: /home/kafka-broker/security/server_jaas.conf
              subPath: server_jaas.conf
              readOnly: true
            - name: queue-broker-data
              mountPath: /home/kafka-broker/data
      volumes:
        - name: queue-broker-settings
          configMap:
            name: queue-broker-settings
        - name: queue-broker-auth
          secret:
            secretName: queue-broker-auth
  volumeClaimTemplates:
    - metadata:
        name: queue-broker-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: ${var.settings.dataflow.inbound.storage.size}Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: queue-broker-monitoring-agent
  namespace: ${var.settings.general.identifier}
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: queue-broker-monitoring-agent
  template:
    metadata:
      labels:
        app: queue-broker-monitoring-agent
    spec:
      restartPolicy: Always
      containers:
        - name: queue-broker-monitoring-agent
          image: danielqsj/kafka-exporter:v1.9.0
          imagePullPolicy: Always
          args:
${join("\n", local.monitoredQUeueBrokersList)}
          ports:
            - containerPort: 9308
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: queue-broker-ui
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    matchLabels:
      app: queue-broker-ui
  template:
    metadata:
      labels:
        app: queue-broker-ui
    spec:
      restartPolicy: Always
      containers:
        - name: queue-broker-ui
          image: provectuslabs/kafka-ui:v0.7.2
          imagePullPolicy: Always
          env:
            - name: KAFKA_CLUSTERS_0_NAME
              value: "queue-broker-cluster"
            - name: KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS
              value: "${join(",", local.internalQueueBrokersEndpoints)}"
            - name: KAFKA_CLUSTERS_0_ZOOKEEPER
              value: "queue-broker-controller:2181"
            - name: SERVER_SERVLET_CONTEXT_PATH
              value: "/panel"
          ports:
            - containerPort: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: monitoring-database
  namespace: ${var.settings.general.identifier}
spec:
  serviceName: monitoring-database
  replicas: 1
  selector:
    matchLabels:
      app: monitoring-database
  template:
    metadata:
      labels:
        app: monitoring-database
    spec:
      restartPolicy: Always
      containers:
        - name: monitoring-database
          image: influxdb:1.11.7
          ports:
            - containerPort: 8086
          env:
            - name: INFLUXDB_DB
              value: "converter"
            - name: INFLUXDB_HTTP_AUTH_ENABLED
              value: "false"
          volumeMounts:
            - name: monitoring-database-data
              mountPath: /var/lib/influxdb
  volumeClaimTemplates:
    - metadata:
        name: monitoring-database-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: monitoring-server
  namespace: ${var.settings.general.identifier}
spec:
  serviceName: monitoring-server
  replicas: 1
  selector:
    matchLabels:
      app: monitoring-server
  template:
    metadata:
      labels:
        app: monitoring-server
    spec:
      restartPolicy: Always
      containers:
        - name: monitoring-server
          image: prom/prometheus:v3.2.1
          imagePullPolicy: Always
          args:
            - "--storage.tsdb.path=/prometheus"
            - "--config.file=/etc/prometheus/prometheus.yml"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: monitoring-server-settings
              mountPath: /etc/prometheus
            - name: monitoring-server-data
              mountPath: /prometheus
      volumes:
        - name: monitoring-server-settings
          configMap:
            name: monitoring-server-settings
  volumeClaimTemplates:
    - metadata:
        name: monitoring-server-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: monitoring-ui
  namespace: ${var.settings.general.identifier}
spec:
  serviceName: monitoring-ui
  replicas: 1
  selector:
    matchLabels:
      app: monitoring-ui
  template:
    metadata:
      labels:
        app: monitoring-ui
    spec:
      restartPolicy: Always
      containers:
      - name: monitoring-ui
        image: grafana/grafana:11.5.2
        imagePullPolicy: Always
        env:
          - name: GF_SECURITY_ADMIN_USER
            valueFrom:
              secretKeyRef:
                name: monitoring-ui-auth
                key: username
          - name: GF_SECURITY_ADMIN_PASSWORD
            valueFrom:
              secretKeyRef:
                name: monitoring-ui-auth
                key: password
          - name: GF_SERVER_ROOT_URL
            value: /dashboards
          - name: GF_SERVER_SERVE_FROM_SUB_PATH
            value: "true"
          - name: GF_USERS_HOME_PAGE
            value: /dashboards
        ports:
          - containerPort: 3000
        volumeMounts:
          - name: monitoring-ui-data
            mountPath: /var/lib/grafana
  volumeClaimTemplates:
    - metadata:
        name: monitoring-ui-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: proxy
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    matchLabels:
      app: proxy
  template:
    metadata:
      labels:
        app: proxy
    spec:
      restartPolicy: Always
      containers:
        - name: proxy
          image: nginx:alpine3.21
          imagePullPolicy: Always
          ports:
            - containerPort: 80
          volumeMounts:
            - name: proxy-settings
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
            - name: proxy-auth
              mountPath: /etc/nginx/.htpasswd
              subPath: .htpasswd
      volumes:
        - name: proxy-settings
          configMap:
            name: proxy-settings
        - name: proxy-auth
          secret:
            secretName: proxy-auth
EOT
}