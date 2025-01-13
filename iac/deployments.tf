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
kind: DaemonSet
metadata:
  name: outbound
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    matchLabels:
      app: outbound
  template:
    metadata:
      labels:
        app: outbound
    spec:
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
kind: StatefulSet
metadata:
  name: queue-broker-manager
  namespace: ${var.settings.general.identifier}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: queue-broker-manager
  template:
    metadata:
      labels:
        app: queue-broker-manager
    spec:
      restartPolicy: Always
      containers:
        - name: queue-broker-manager
          image: bitnami/zookeeper:3.8.4
          imagePullPolicy: Always
          env:
            - name: ALLOW_ANONYMOUS_LOGIN
              value: "yes"
          ports:
            - containerPort: 2181
          volumeMounts:
            - name: queue-broker-manager-data
              mountPath: /bitnami/zookeeper/data
  volumeClaimTemplates:
    - metadata:
        name: queue-broker-manager-data
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
  replicas: 1
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
          image: bitnami/kafka:3.9.0
          imagePullPolicy: Always
          env:
            - name: BROKER_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KAFKA_OPTS
              value: "-Djava.security.auth.login.config=/opt/bitnami/kafka/config/server_jaas.conf"
          ports:
            - containerPort: 9092
            - containerPort: 9093
          volumeMounts:
            - name: queue-broker-settings
              mountPath: /bitnami/kafka/config/server.properties
              subPath: server.properties
            - name: queue-broker-auth
              mountPath: /opt/bitnami/kafka/config/server_jaas.conf
              subPath: server_jaas.conf
              readOnly: true
            - name: queue-broker-data
              mountPath: /bitnami/kafka/data
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
  name: queue-broker-ui
  namespace: ${var.settings.general.identifier}
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
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
          image: provectuslabs/kafka-ui:master
          imagePullPolicy: Always
          env:
            - name: KAFKA_CLUSTERS_0_NAME
              value: "queue-cluster"
            - name: KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS
              value: "queue-broker:9092"
            - name: "KAFKA_CLUSTERS_0_ZOOKEEPER"
              value: "zookeeper:2181"
            - name: SERVER_SERVLET_CONTEXT_PATH
              value: "/panel"
          ports:
            - containerPort: 8080
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
          image: nginx:alpine3.20
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: converter
  namespace: ${var.settings.general.identifier}
spec:
  replicas: 1
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
EOT

  depends_on = [
    linode_instance.clusterManager,
    linode_nodebalancer.outbound
  ]
}