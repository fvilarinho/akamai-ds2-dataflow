```text
    ___    __                         _
   /   |  / /______ _____ ___  ____ _(_)
  / /| | / //_/ __ `/ __ `__ \/ __ `/ /
 / ___ |/ ,< / /_/ / / / / / / /_/ / /
/_/  |_/_/|_|\__,_/_/ /_/ /_/\__,_/_/
    ____  ________
   / __ \/ ___/__ \
  / / / /\__ \__/ /
 / /_/ /___/ / __/
/_____//____/____/        ______
   / __ \____ _/ /_____ _/ __/ /___ _      __
  / / / / __ `/ __/ __ `/ /_/ / __ \ | /| / /
 / /_/ / /_/ / /_/ /_/ / __/ / /_/ / |/ |/ /
/_____/\__,_/\__/\__,_/_/ /_/\____/|__/|__/
```

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
Follow this [diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&layers=1&nav=1&title=architecture.drawio#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%2292RJ4OFCEY1Zh97tm0ry%22%3E7Vpbd5s4EP41Pmf3ITmAwJdHG8dpdtM2XZ%2BeTR9lIxs1gDhCxHZ%2F%2FUogzEVgky527N3mwUHDIEvzzXwzGtMDtr%2B9pzB0PxIHeT1Dc7Y9MO0Zxsgy%2BacQ7FKBDvpaKllT7EhZLpjjH0gKM7UYOygqKTJCPIbDsnBJggAtWUkGKSWbstqKeOVvDeEaKYL5Enqq9G%2FsMFdK9f4ov%2FEB4bUrv3poDNIbPsyU5U4iFzpkUxCBux6wKSEsvfK3NvKE8TK7pM%2FNGu7uF0ZRwFo9IKGI2C7bHHL4XuWQUOaSNQmgd5dLJ5TEgYPEDBof5TqPhIRcqHPhd8TYTgIHY0a4yGW%2BJ%2B%2BiLWbP4vFbS46%2BFe5Mt3LmZLCTg4hR8oJs4hGarBPMZkNNE3fUPUszRCSmS7mr2eomZpOPHyxtEX%2F56%2B45%2BLwKbjLfgXSN2AE9I9UTlil8gbToPSI%2BYnTHFSjyIMOvZS%2BB0tnWe70cD34hIamH59CqX6EXy28av0Af4p7Rhz4HYBIsojCxS9%2Fju5o4%2BJVfrsXlFDLIDYmgzycwMgW%2BioKO4hA53AKhjYsZmocwMeyGx3cZ2kYwXhFlaHvQfPKuOZLBIenhJguWTSHWMplbCLOMRf6NxXXwfw4Io2VAgPcKCPA%2BfBXwZRbwEcNvGSZikCOUjBoh4vhos1nXEAHtovjJUPjpiZLtroaOfvt0%2F%2FDp%2Bfcr4aHRGWlodC0s1FlodMBeoCV7mRcVLkAJl4dgIaCsC5gZVwrY9FpCRh%2BeMWYGB7Z%2F5XnZbOnZ%2Fa49O3l0TCncFRRCggMWFWZ%2BEoLcCyyr7AUW0Co4pjPmqO6X1q5GM96THfWCJ2i3A6slPZbIUT52gB9XJGClwmE00hpKCtvu98%2FiXdZF8aap8OaXGMUoqqPNMSc9F3HtP%2BHqBV4Le5614tB1Zf%2FnLDlKQWW0DCq9HFTGJQWVdZXFiKUElU2CxINpXVz9AV8hV5%2BHFAfriehaGdo4DC81wAbmOwbYoYRdsPcc3NjEDz0MRUpVTP558V10NLnNGaGiTXmZlq5SmXnOQlAfKla94UN5CtVYkgm4w6KIYRIotuJbZGWDQA%2BvA3695AbhgQAmwhB4Cb2xvOFjx0kJEUX4B1wkUwlmkaUSn9ea9KypmItzYJTSoa5QT0ACMcsKe15VVKau4zVle6yq5Zpu1WAFarACXWA1qsVqRugGUqcOLY3nEJnIe6J3T4UI%2BSEPh2RXURYYv2Atk52pwgr0E8G6X24O6wx7SRb5T8TfvnToAKi%2BbpWAAsBox5WdAKV260RmEQiRwBOrXCW4IRGLHllHv%2BDSynAZA%2BPWUgEzTwXYUEHgDHV6xZ62rWn1lfP%2BTlNjcF%2BzN9TojQgVK26jbXV9mobI8Y7HqIJ0ulD5VAXstzU%2FzPc5p%2F1sH6P5J5D6ox%2Bo%2FB0%2BCPLBE6KYm0%2FwzAn8xziJ%2F7y1oWZW3KuvVX7VP6KvA6vidYUGnPp00%2B%2Bv3TuzoZ43x0smSrqKi0cuDMVl7HupQp5UHuECeU88SSTFBJguCGPEr8k6jHR%2FzrFAORlYNeecutK5i2OOoR4eZ4gt3X2JpWRuviombs8B%2F7AfH64yl%2B8zTBfwVXm75uhjaCfK5OCimPznibwV42YGu9x%2BWLbCQjjV9F%2ByHrP29aHpfZtqK%2BZYOzqZ7FJbZsawcoo8Z8sMqAynNnK%2BXieNHQ%2Bf9iCBSl9TrwPpZDTW0G2LI5Fqxolu9oKaRuHm7edID63YJUDWaXemX4aspjmj90%2BEmKkiVtdpjlnpNYTjtHZlLyeAwRmpzKzvc8ooaajXUjMuaGbCpPO5wjzd8%2F%2BOaJ8F8GpbaKfsdZp14VTXkTHfDi0f5u9np2ee%2FC13cPcP%3C%2Fdiagram%3E%3C%2Fmxfile%3E) to check out the architecture.

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
- `main.tf`: Defines the provisioning providers. You need to create an API Token in advance and add a section called 
`akamai` in the file `~/.aws/credentials`. To create the API Token, please refer the documentation [here](#6-other-resources). 
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