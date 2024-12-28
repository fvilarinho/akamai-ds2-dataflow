# Akamai DS2 Dataflow

## 1. Introduction
Customers often need to access, analyze, and process their logs in real-time to gain insights and make swift decisions. 
However, achieving this typically requires significant infrastructure and team effort, leading to higher operational 
costs, especially during peak traffic periods like Black Friday.

What if there was a cost-effective way to streamline log collection?

That’s exactly what you will get here!

This solution integrates [Akamai Datastream 2](https://techdocs.akamai.com/datastream2/docs/welcome-datastream2) with
[Apache Kafka](https://kafka.apache.org/), a distributed and scalable queue system, deployed in a Kubernetes cluster 
powered by [Akamai Cloud Computing](https://www.linode.com). It enables systems and applications to fetch logs in 
real-time by simply subscribing to relevant topics.

The system is designed to scale seamlessly, ensuring reliable performance even during traffic spikes, and offers easy 
configuration and customization, allowing users to adapt it to their specific needs with minimal effort. 

Additionally, it supports advanced filtering capabilities, enabling users to apply multiple regular expressions on any 
available field in the JSON-formatted log lines.

## 2. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)

If you're interested in collaborating on this project, feel free to reach out to us via email.

Since this project is open-source, you can also fork and customize it on your own. Follow the requirements below to 
set up your build environment.

### Latest build status
- [![CI/CD Pipeline](https://github.com/fvilarinho/akamai-ds2-dataflow/actions/workflows/pipeline.yml/badge.svg)](https://github.com/fvilarinho/akamai-ds2-dataflow/actions/workflows/pipeline.yml)

## 3. Architecture
Follow this [diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&layers=1&nav=1&title=software_architecture.drawio#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%2292RJ4OFCEY1Zh97tm0ry%22%3E7Vxbc5s6EP41nmkfnAEEOH60nTjNadKmJ6dz2kfZlm0aQFSI2O6vr4SFuUi2yRSISZ2HDLoA0n7ab1e7wh0w8tY3BAbLezxDbsfQZusOuOoYRt8y2X9esdlW6MDWtjUL4sxEXVrx6PxCojLpFjkzFOY6Uoxd6gT5yin2fTSluTpICF7lu82xm39rABdIqnicQleu%2Fd%2BZ0aWo1e1%2B2vABOYulePWl0ds2eDDpLGYSLuEMrzJV4LoDRgRjur3y1iPkcuElctneN97TuhsYQT4tc4MpxvEM3UhMTgyMbpLZEhz5M8Rv0DtguFo6FD0GcMpbVwxfVrekniua5QGIMT0jQtE6UyUGdIOwhyjZsC6i1bDEoMTy6IniKhW1nYx7mZGymQgVCngXu0enEmAXQgh7JGhK80czBr4oYkKXeIF96F6ntcNUQhorpX3uMA6EXH4gSjdiJcOI4rzU0Nqh3%2FjtF5Yofc%2B0XK3Fk%2BPCRhRCSvATGmEXk3icYDy%2B1DTtEAYhjshUzGo870Z0eP%2FB0ibRl3%2Bvv%2Fmf5343USZIFoge6CcWCZfMQUQJciF1nvNq8yfwHBp1Zg0PnqAHnY5hQ4%2BvT38SBrFcbJfNajhzntnlgl9eQQqZIBH02AOMpAMbRabPqyuE2c8rRNcAskrohkIl7Co0AvzNGmGU1AjwWhoBXoewfDbMDD68%2BD3BhBdShOLSXogYPtp4XDVEiX6cCEEZEkE9ELzeKPjo3aeb20%2Ff3reEiPoN0lC%2FLSxUmWpUwF6gJHuZJ6UuQFKXW3%2FCoVQpzJh18ulVW1RGv2xQZ3oHpt9yu2yWXNl21Ss7vnVACNxkOgTY8WmYefIDr0hXgVXY0lhAK%2BC4fWKK6m5o5Xw0edfWIDvqmZWgXfSskvSYI0dx2wF%2BnGOf5hyHfl%2Fb41KMRrbdyOqyToo3TYk3v0QoQqGKNgeM9JaI9f4I50%2BwLezZqMeh69L8m3Q5ckpllFQqPa9UxikpldVKZ8SSlGqE%2FXgFE5Ve%2FQOfIev%2BGBDHXwx5HM%2FQBkFwqgrWM19RwQ4Z7Iy8H0F3hL3AdSA3qZLIP09%2B8BgvkznFhAduT1PSRSqz9CapTF7FS0qDUJIKmwzNTx26zsJn11M2dbbkwZBP2ZlCdyAaPGc221IfCp1fcBI%2FinOIcIrYc61hx7riz2JsF26JT5dIxsc%2Bf8rccd1iVZ6kjnuP5VGxtML6tyRQLAUmoApM5JXeZUUmcOhPuWWmsX2mBM7nzjRZ1ROSrGjeeRCxTj6HgyJ1j6GLp0%2F8rT57D3s1p82fzCegL8HeRXP65pC3CxszhTqqoK9EHXtndSyljjsEmtDHS6U%2Bikid0EZm1JnuONg%2FQ2Udh0oHdWHVV2I1xmQFyUyFlsb8bLHZ6fCML%2BFVyAuYyxDPKkychzOseYNoyrACvSZYE%2FcnAyudnmlR9lIUoNRFi7vRppiMHTfe%2FbwJTtxteSvAyU78bIETAIbMiSofvxKgDAkoviPiCGHf5aOcx7ghzo8uXrRTrSqFS8vDZfSMC9n%2F11VnTSoB7FJCoIH4UkGeo5GmqSM%2Bu5Z9Ca1drGlPbGkvQtlIkVE2KlRPIP94pL5fQHo7UHFXAeyXBe3N14kv7om%2FH4sU7s%2FcqyOWoPDXORi%2FZIUHRBwmPU4zf7Z8QK%2BWpfLSnI9ZWEnJmbVxyf7d%2FNG9P84RGXIMaDCl3BEuLMJwCQN%2BGXnutkNK%2B3dwgtwHRuOxuQdXE0wp9hR2geLqI2gWyNO1bShc05p27IYcrBkjOl3unCDJtrJRUd78CNi%2F0d1tK63tzgZUAV%2BRWRWZcEOry9bKG8b2RlwqRUU7jkpdWwvwRgxgKUuVCOx0019A3n0r0i1JSln7ervvfG0x83Is%2Bxw%2F7FQzZMZlYe%2FdZIYMyEeh2ktbx%2FXlBdm0YqC4QdZ6S7m0KjExikfdFJpSGyjqZFo%2BeP%2B1nU5YlRgB8zhGel1OGJDTXncYcpdZJD2JnMN8d%2FPf%2FftXNwLSFxiqZEdtRmBPYioK%2Bf5iEPdNPnjRCFx1Xhze%2Bxvyu11d8R2Zbte11N%2FSfqPOVIYSlrqshGlIqOwUh5mKgM1ic3pcoyuyPbWRjSl7nGeyeTnZqE7518U1pnzu98w1Sq5pMLZhyruEnXOTQ8X%2BGfGPvWM5dLfyG7AOuhmst5tn0Z44RB%2BjCSI%2BovEefORGYeYgKhvUZO%2FGWUa%2FLETlV4mKHfMBGz5NEZrRzWpgtgs79EZ1T%2FbNVEdUI5r7ful4gKRlXzUBlW9Vm4lSH%2F4RJmpPOL64r4iPA80dH8a%2FTMHPL%2FiwtWcY6jwAZKq8D%2BXPL1QAbfLusyk7YspUqFRkylgx%2Ff2RbZ4x%2FRUXcP0b%3C%2Fdiagram%3E%3C%2Fmxfile%3E) to check out the architecture.

### Software
Here are the software components of the stack:

- `Inbound`: Handles the reception of log streams from `Akamai Datastream 2` and pushes them to the `Queue Broker`. 
It operates using [FluentD](https://www.fluentd.org/).
- `Converter`: Converts and filters logs pushed to the `Queue Broker` by the `Inbound`. It was built using [Java Sprint Boot Aapplication](https://spring.io/projects/spring-boot).
- `Outbound`: Transfers logs from the `Queue Broker` to external storage, such as S3-compliant storage. It operates 
- using `FluentD`.
- `Queue Broker Cluster`: Cluster built on top of `Apache Kafka`.
- `Queue Broker Manager`: Responsible to manage the state of the `Queue Broker Cluster`. It operates using [Zookeeper](https://zookeeper.apache.org/).
- `Queue Broker UI`: UI for `Apache Kafka`. It operates using [Provectus](https://docs.kafka-ui.provectus.io/).
- `Proxy`: Routes incoming traffic to the appropriate component based on the specified path (e.g., `/ingest` routes to 
`Inbound`, and `/panel` routes to the `Queue Manager UI`). It operates using [NGINX](https://nginx.org/).
- `Cert Manager`: It automates the creation, renewal, and deployment of the TLS certificate used by the stack.
- `Ingress`: Enables external traffic to access the stack. It operates using [Traefik](https://doc.traefik.io/traefik/)
- `Kubernetes`: Container orchestration platform that automates the deployment, scaling, and management of the stack. It
operates using [K3S](https://k3s.io/).

### IaaS
Here are the IaaS components provisioned in `Akamai Cloud Computing` and used by the stack.

- `Linodes`: Compute Instance or Virtual Private Server (VPS).
- `Volumes`: It provides scalable, high-performance block storage volumes that can be attached to a compute instance.
- `Object Storage`: S3-Compliant Storage.
- `Cloud Firewall`: Defines the firewall rules that permit traffic to and from the stack.

### Settings and Provisioning
The settings and provisioning are handled by [Terraform](https://terraform.io/). 
If you want to customize the stack and its provisioning by yourself, just edit the following files in the `iac` 
directory:

- `variables.tf`: Defines the provisioning variables. You can also use `terraform.tfvars`.
- `main.tf`: Defines the provisioning providers.
- `compute.tf`: Defines the provisioning of the compute instances.
- `firewall.tf`: Defines the provisioning of the firewall rules.
- `kubernetes.tf`: Defines the provisioning of Kubernetes.
- `certissues.yaml`: Defines the provisioning of the stack TLS certificate.
- `namespaces.yaml`: Defines the provisioning of the stack namespaces.
- `configmaps.yaml`: Defines the provisioning of the stack settings.
- `secrets.yaml`: Defines the provisioning of the stack secrets.
- `deployments.yaml`: Defines the provisioning of the stack containers.
- `services.yaml`: Defines the provisioning of the stack exposed ports.
- `ingress.yaml`: Defines the provisioning of the stack ingress.
- `stack.yaml`: Defines the provisioning of the stack.

## 4. Requirements

### Build, packaging and publishing
The Inbound, Outbound, and Converter components require compilation and packaging before deployment. Below are the necessary requirements:
 
- [JDK 17 or later](https://www.oracle.com/java/technologies/downloads)
- [Docker 24.x or later](https://www.docker.com)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS Catalina or later` or
- `MS-Windows 10 or later with WSL2`
- `Dedicated machine with at least 4 CPU cores and 8 GB of RAM`

Simply run the `build.sh` script to compile and build the binaries and libraries. Next, execute `package.sh` to package 
the container images, and finally, use `publish.sh` to upload them to the repository.

The following variables must be defined in the `.env` file, located in the project's root directory, before starting the
procedure described above.

- `DOCKER_REGISTRY_URL`: Specifies the URL of the Docker registry repository to store container images. For example:
    - Use `docker.io` for [Docker Hub](https://hub.docker.com).
    - Use `ghcr.io` for [GitHub Packages](https://github.com).  
      Refer to your Docker registry's documentation for the correct value.
- `DOCKER_REGISTRY_ID`: Specifies the identifier for the Docker registry repository (commonly your username, but verify 
with your registry's documentation).
- `BUILD_VERSION`: Specifies the version of the container images.

The following environment variables must be defined in your operating system or in your CI/CD pipeline secrets.
- `DOCKER_REGISTRY_PASSWORD`: Define the Docker registry repository password.

### Deployment
Here are the requirements for the deployment:
- [terraform 1.5.7](https://terraform.io/)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS Catalina or later` or
- `MS-Windows 10 or later with WSL2`
- `Dedicated machine with at least 4 CPU cores and 8 GB of RAM`

After completing the procedure described above, run the `deploy.sh` script to start provisioning. To de-provision, 
execute the `undeploy.sh` script.

### Post-deployment
After provisioning, execute the following commands:

1. Set the Kubernetes configuration:
   ```bash
   export KUBECONFIG=iac/.kubeconfig
   ```  
   This specifies the configuration for connecting to the Kubernetes cluster.


2. List cluster nodes:
   ```bash
   kubectl get nodes -o wide
   ```  
   This ensures that the compute instances have been successfully provisioned and joined the Kubernetes cluster.


3. View stack pods details and state:
   ```bash
   kubectl get pods -n <identifier> -o wide
   ```  
   Please replace the `<identifier>` placeholder with the value defined in the variables file.


4. Access the stack UI:  
   Once all pods are running, retrieve the IP address of the `traefik` service:
   ```bash
   kubectl get service traefik -n kube-system -o jsonpath='{.status.loadBalancer.ingress}'
   ```  
   Open your browser and navigate to:
   ```text
   https://<ip>/panel
   ```  
   Please replace the `<ip>` placeholder, with the IP address fetched in the procedure described above.

   A login prompt will appear. Enter the credentials defined in the variables file.


5. Configure Akamai Datastream 2 in ACC:  
   In the destination section, use the following settings:
   ```text
   Destination Type: Custom HTTPs
   Endpoint: https://<ip>/ingest
   Authentication type: BASIC
   User: Type the user defined in the variables file.
   Password: Type the password defined in the variables file.
   Content-Type: application/json
   ```  
   Please replace the `<ip>` placeholder, with the IP address fetched in the procedure described above.

## 6. Other resources
- [Akamai Techdocs](https://techdocs.akamai.com)
- [Akamai Cloud Computing](https://www.linode.com)

And that’s it! Enjoy!