# Defines the exposed ports of the stack.
resource "local_file" "services" {
  filename = abspath(pathexpand("./services.yaml"))
  content = <<EOT
apiVersion: v1
kind: Service
metadata:
  name: inbound
  namespace: ${var.settings.general.identifier}
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
  name: queue-broker-controller
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    app: queue-broker-controller
  ports:
    - name: backend
      port: 2181
      targetPort: 2181
---
apiVersion: v1
kind: Service
metadata:
  name: queue-broker
  namespace: ${var.settings.general.identifier}
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
  name: external-queue-broker
  namespace: ${var.settings.general.identifier}
spec:
  type: NodePort
  selector:
    app: queue-broker
  ports:
    - name: backend
      port: 9093
      targetPort: 9093
      nodePort: 30093
---
apiVersion: v1
kind: Service
metadata:
  name: queue-broker-ui
  namespace: ${var.settings.general.identifier}
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
  namespace: ${var.settings.general.identifier}
spec:
  selector:
    app: proxy
  ports:
    - name: http
      port: 80
      targetPort: 80
EOT
}