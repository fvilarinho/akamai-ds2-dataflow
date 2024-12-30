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
powered by [Akamai Connected Cloud](https://www.linode.com). It enables systems and applications to fetch logs in 
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
Follow this [diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%2292RJ4OFCEY1Zh97tm0ry%22%3E7Vxdl6I4EP01nrPz4BwIBPBR7Xamd763d8%2FOPEaNyjQSN4a2e379JhAQSFRsUeT09EtDSDDUrVupVBV0rOHy6R1Fq8UnMsVBBxjTp4510wHAtHoG%2FydanmWLDUHSMqf%2BVLZtG%2B79X1g2yoHzyJ%2FidaEjIyRg%2FqrYOCFhiCes0IYoJZtitxkJir%2B6QnOsNNxPUKC2%2FutP2UK2mk5ve%2BE99ucL%2BdMecJMLS5R2lk%2ByXqAp2eSarNuONaSEsORo%2BTTEgZBeKpdk3GjH1WxiFIesygDPSUY8oiCSDycnxp7Tp6UkCqdYDDA71mCz8Bm%2BX6GJuLrhAPO2BVsG8vLMD4IhCQjl5yEJeaeBOic5zUdMGX7KNck5vsNkiRl95l3Sq6nKSI3puoaU6GYrf8%2BQnRY50fds2Ygk5vPs5lux8AMpGb2UXK8VUrLcopQAtBQh2a5GSGYdQnJgK4QErJIq2RpVci2NlKBVg5RMWxEKnnLjIk8JZQsyJyEKbretg63YDH627fORkJUU1k%2FM2LO0lChipChK%2FOSz72L4WyjPfuSu3DzJO8cnz%2FJkzSh5wCkAHWCNRpxhxj4U1iSiE%2FlUjrQsDNE5lt1Gs27EBp%2FeQ2Mcffvr9nv4ZRZ2pZYIKezFj%2BIAMf%2BxaIJPYrXxSqDQit1U4UkhuzwU%2B2aYsyf9B7REfgc4aClsRTher2IZOAF%2FgsHUf%2BSHc3F4gxjiQsNoyW8A0g58Frk%2BJxonErJUUzSr7tFmyXZKZsnxVLNkAo1ZcuqwStZrpgKoaKmspuhhNbNohHyaOXzE6Y8UE3GyRSg%2B2wmRw%2F9Go7ohSlfjK7FWQLFWXyl5etYYpz8%2Bv7v7%2FP3NOazSOQwRuKQh6rXFDtVGjhrsl1XRftlXRRhLIcxdOBZQ6igz4p1CdtMa0pjuBUkD3SZZY%2BY4Y7x1YUXaFEgjhx3DG8MYjU7kjV2RN%2FCqeGMrvPkWYX4IjIEQEdXRp8%2BVfyG6fECzB9QaFsFLusCm8vyXXHoKJAIVSWQWSQQOkUhsWgoU6vWMHeQaDvlu8BRywVYuSmoMa0jCWIO1vPoTPSLe%2FX5F%2FXA%2BEFFbYPRXq2slmGfC5gimlbcafr63ukOyXAU%2B4o%2BpivzL%2BKeI6HOZM0JFmL6Fe3sTwgvaNTV23eWncnNisHhZ4NqL18wnoSI4%2FoisKB0U%2BPOQH0%2B4QDgrrIEQhD9BQV9eWPrTaWId8dr%2FhcbxrYSZWRE%2FZPGjwEEH3oh7cYO4TmyjqdghGfPVhIFLduywC10dK2j2ihQBpoYjuvBwLdHhnhYsoes4Aysg83WMmQ4%2Bg5GVP1FDZL9hLcJqamAFOg7WAStQgwNFSLkwuNC5fSqiu6JkgtfruF3i2kIcMzeDEoZiLU1%2Brw5YvXLUVIOqfS5UvSY8xpJwb%2FvOIPbUFB8uu7IrVJF5jzu8xUq%2BH6jq59WeW5BDvwqtzWkEKOVAbat4i2SiclQJ7Gwa1RKeoAn8d%2B2gj95AHxeV1eEMa4%2FAxkP7lKLnXAdpl3ZCbpbcK8uw8sge7N%2BFtltShWQKL1UM12lCMSoYgGP3iy%2FWDLf2XZ0eStcuQ5lW2hyg%2B9E6ZoAjlaw8oAulvahLy4C6V%2B1PuFeh6N56gVbiMFoGSYetT%2FARjXHwla%2FxclkeE8bIUuM0MFL%2FbhQaxd0o8NRyFZ2jXceuCKgbT%2BFojzCbLPZ4ZRuficv3fKLG8ONdK92xzCzUAWG6u9xTcZRV7dXtf1nNROyaWX9TgV1vPC2dYaH%2BS4nfxLFqQaV%2F7nbVcZRDOYfC2fHNrjXkBmCDITdLV92ZiEkYhY6okE310fkvIonEYs2czfJNiTCLMSMBoNHNiT255Q65X71lnOIZigJWD%2BpWpSS6rl61DsMI1RRRE5byxFS37V27xUtBbmlZzpngaKyI0NZVaasJhIgVqgwOrzYtqz2w7cstMFCt0YyTC9FauMn9uG9atGlQtMk86cqrQ4BnrPG1oe5gNCh6zV1Hl2NwzrU6qPvGClufti3ntecPipCle5o8YPBccWaVZKMYns6e%2FE8L8cryBDXg5ZSjL1bvcoA5eqtYKeWD4vNw3uUXlzGGMs3dQkDrtZmlHDpQc%2BjgXCbTUR3q%2FkRk5pTNUAtROhyHOGLf09NHSS%2By7XEbfokBvKh6GFyytv76X8py1JDFXTinMddU1%2FxvivDMf2iLa961LllL7zZb0dgGPkBNVLW5t%2BCgGkH9TKZxZS8KUDjZ1iCOaUYBWTT%2F5jRlP%2FvrbPCSBfFe0%2B9Luacp8eEUTV6J3ap17OdJyh6bSnXL7%2FKX0u%2BHB7j7%2B0O4t%2F%2Fp6X3VGzxM0zTsdGU8dcp1cRflafpbL8vCiq2Skgn6nZUV8f%2FDXjjwzuSFe%2BoiNoz4LnYZxys%2BY7Yh9KECRFXlWB1KHbWKRr92dpWBcDRAnKs80VNfsBsGJBI8GvkUb5DofU22CJRjNnZP82UOnbjcOsSlhkU%2FRGNMQ8zifPUk4FosdPhVaK5rFrHoXVJx1TxOlkMYJl90ilcDqc2vAg%2FHKxXa6Ez62QBR30rIACl%2FaSNumAVk055VWDr08cazbtwsr%2BRfZR%2Bpyhe59TTAveCTTPx0%2B%2BWwxLHdfoDNuv0f%3C%2Fdiagram%3E%3C%2Fmxfile%3E) to check out the architecture.

### Software
Here are the software components of the stack:

- `Inbound`: Handles the reception of log streams from `Akamai Datastream 2` and pushes them to the `Queue Broker`. 
It operates using [FluentD](https://www.fluentd.org/).
- `Converter`: Converts and filters the logs sent to the `Queue Broker` by the `Inbound`. It was built using [Java Sprint Boot Aapplication](https://spring.io/projects/spring-boot).
- `Outbound`: Transfers processed logs by the `Converter` to an external storage, including S3-compatible solutions. It 
operates using`FluentD`.
- `Queue Broker`: A cluster built on `Apache Kafka` for temporary log storage.
- `Queue Broker Manager`: Responsible to manage the state of the `Queue Broker`. It operates using [Zookeeper](https://zookeeper.apache.org/).
- `Queue Broker UI`: UI for `Queue Broker`. It operates using [Provectus](https://docs.kafka-ui.provectus.io/).
- `Proxy`: Routes incoming traffic to the appropriate component based on the specified path (e.g., `/ingest` routes to 
`Inbound`, and `/panel` routes to the `Queue Manager UI`). It operates using [NGINX](https://nginx.org/).
- `Cert Manager`: It automates the creation, renewal, and deployment of the TLS certificate used by the `Ingress`.
- `Ingress`: Enables external HTTPS traffic within the stack. It operates using [Traefik](https://doc.traefik.io/traefik/)
- `Kubernetes`: Container orchestration platform that automates the deployment, scaling, and management of the stack. It
operates using [K3S](https://k3s.io/).

### IaaS
Here are the IaaS components provisioned in `Akamai Connected Cloud` and used by the stack.

- `Linodes`: Compute instances (also known as Virtual Private Servers) used to run the software described above.
- `Volumes`: Offers scalable, high-performance block storage volumes attachable to compute instances.
- `Object Storage`: Specifies the S3-compliant storage for long-term log retention.
- `Node Balancers`: Manages load balancing of external traffic to compute instances.
- `Cloud Firewall`: Specifies the firewall rules to manage the traffic to and from the stack.

### Settings and Provisioning
The settings and provisioning are handled by [Terraform](https://terraform.io/). 
If you want to customize the stack and its provisioning by yourself, just edit the following files in the `iac` 
directory:

- `variables.tf`: Defines the provisioning variables. You can also use `terraform.tfvars`.
- `main.tf`: Defines the provisioning providers. You need to create an API Token in advance and add a section called 
`akamai` in the file `~/.aws/credentials`. To create the API Token, please refer the documentation [here](#5-other-resources). 
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
   Depending on the number of compute instances provisioned in the Kubernetes cluster, it will show multiple IPs.


5. You can also retrieve the inbound node balancer IP address:
   ```bash
   linode-cli nodebalancers list | grep inbound | awk -F' ' '{print $10}'
   ```  
   Please make sure that you have the [linode-cli](https://github.com/linode/linode-cli) installed and authenticated in
   your environment.


6. Open your browser and navigate to:
   ```text
   https://<ip>/panel
   ```  
   Please replace the `<ip>` placeholder, with any IP address fetched in the procedure described above.

   A login prompt will appear. Enter the credentials defined in the variables file.


7. Configure Akamai Datastream 2 in ACC:  
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

   You can also configure Akamai GTM to balance traffic within the Kubernetes cluster and/or set up an Akamai Property 
   to restrict traffic to Akamai SiteShield IPs.

## 5. Other resources
- [Akamai Techdocs](https://techdocs.akamai.com)
- [Akamai Connected Cloud](https://www.linode.com)

And that’s it! Enjoy!