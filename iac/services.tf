# Defines the exposed ports of the stack.
resource "local_file" "services" {
  filename = abspath(pathexpand("./services.yaml"))
  content = <<EOT
apiVersion: v1
kind: Service
metadata:
  name: inbound
  namespace: akamai-ds2-dataflow
spec:
  selector:
    app: inbound
  ports:
    - name: http
      port: 9880
      targetPort: 9880
---
apiVersion: v1
kind: Service
metadata:
  name: queue-broker-manager
  namespace: akamai-ds2-dataflow
spec:
  selector:
    app: queue-broker-manager
  ports:
    - name: backend
      port: 2181
      targetPort: 2181
---
apiVersion: v1
kind: Service
metadata:
  name: queue-broker
  namespace: akamai-ds2-dataflow
spec:
  selector:
    app: queue-broker
  ports:
    - name: backend
      port: 9092
      targetPort: 9092
---
apiVersion: v1
kind: Service
metadata:
  name: queue-broker-ui
  namespace: akamai-ds2-dataflow
spec:
  selector:
    app: queue-broker-ui
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: proxy
  namespace: akamai-ds2-dataflow
spec:
  selector:
    app: proxy
  ports:
    - name: http
      port: 80
      targetPort: 80
EOT
}