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

## 2. Use cases

1. **Real-Time Security Monitoring and Threat Detection:**
   Stream logs to Kafka to identify and respond to malicious activities in real-time.
   Analyze attack vectors, rate-limit DDoS attacks, and prevent unauthorized access with real-time log insights.

2. **Enhanced Content Delivery Performance Analytics:**
   Monitor and optimize content delivery metrics such as cache hit ratios, latency, and error rates.
   Feed the data into real-time dashboards or analytics systems for actionable insights.

3. **Customer Experience Optimization:**
   Track user behavior and engagement patterns through Akamai logs.
   Use Kafka to process logs for user-specific recommendations, latency analysis, or adaptive traffic routing.

4. **Compliance and Auditing:**
   Collect and stream logs to Kafka for storage in systems that ensure compliance with regulations like GDPR, CCPA, or 
   PCI DSS. Enable seamless auditing by archiving structured logs into data lakes or warehouses.

5. **Proactive Incident Management:**
   Use Kafka streams to analyze anomalies or error patterns in CDN traffic.
   Integrate with alerting systems to notify teams of potential issues before they escalate.

6. **A/B Testing and Experimentation:**
   Utilize logs for real-time feedback in A/B testing scenarios, such as comparing performance across different regions 
   or configurations. Feed log data into machine learning models to evaluate the impact of experiments.

7. **Personalized Advertising and Content Targeting:**
   Process logs to understand content consumption trends and preferences.
   Use Kafka to deliver insights into ad-serving platforms for personalized and targeted advertising.

8. **IoT and Edge Analytics:**
   For IoT applications leveraging Akamai's edge network, analyze log data to monitor device performance and network 
   reliability. Aggregate edge data in Kafka for centralized analysis or predictive maintenance.

9. **Traffic Engineering and Load Balancing:**
    Analyze logs in Kafka to dynamically adjust traffic routing and load balancing across origins or edge servers.
    Use insights to improve network efficiency and reduce costs.

## 3. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)

If you're interested in collaborating on this project, feel free to reach out to us via email.

Since this project is open-source, you can also fork and customize it on your own. Follow the requirements below to 
set up your build environment.

### Latest build status
- [![CI/CD Pipeline](https://github.com/fvilarinho/akamai-ds2-dataflow/actions/workflows/pipeline.yml/badge.svg)](https://github.com/fvilarinho/akamai-ds2-dataflow/actions/workflows/pipeline.yml)

## 4. Architecture
Follow this [diagram](https://app.diagrams.net/?title=architecture.drawio#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%2292RJ4OFCEY1Zh97tm0ry%22%3E7Vxbc9o4FP41zHQf6MjylUcgoc32vtmdbR%2BFEeDGWKyQA%2FTXr2TLYFsCTDAXT9qH1JIlI3%2BfzkXnHGiZ%2FdnqHUXz6ScywmELgtGqZd61IDQs0%2BL%2FiZ617HEsL%2B2Z0GAk%2B7Ydj8EvLDuB7I2DEV4UBjJCQhbMi50%2BiSLss0IfopQsi8PGJCx%2B6hxNsNLx6KNQ7f03GLGp7DWczvbGexxMpvKjPeimN2YoGyzfZDFFI7LMdZn3LbNPCWHp1WzVx6FAL8MlnTfYcXezMIojVmWC56QznlEYy5eTC2Pr7G0piaMRFhOMltlbTgOGH%2BfIF3eXnGDeN2WzUN4eB2HYJyGhvB2RiA%2FqqWuSy3zGlOFVrkuu8R0mM8zomg%2FJ7nYkXnLHtB1Xdiy3%2BHtA9k1z0HeAKXmXnE82D9%2FCwi8kMnqUXK8RKJluESVomwpIlqsBybDA6SA5diNAgmZpK1nAVVByTQ1KtlkDSoalgIJHXLnIJqFsSiYkQuH9tre3hQ3w1nbMR0LmEqyfmLG11JQoZqQIJV4F7LuY%2FtaWrR%2B5O3cr%2BeSksZaNBaPkCWcEtKA5GHAJA%2FtYWJCY%2BvKtHKlZGKITLIcNxu2Y9T69t8Ew%2FvbX%2Fffoyzhqy10iUNjLH8UhYsFzUQWfJNXglVChhd1Q6ckouzwV%2B1aY0yfdJzRDQQs6aCZ0RTRczBMMnJC%2FQW8UPPPLibi8Qwxx0DCa8QfAbABfRW7MicqJRCzbKRqre7RaspyyhbNVC2dAjVpy6tBK5msWBVhRU5nXEg%2FzOkYj4svM8SOaPzJORGPLUNLaSZHD%2Fw0GdVOUWeMb0VZQ0VZfKVmtNcrpzed3D5%2B%2F%2F3EOrXQORQQ91T86myLqNEUP1SYcNegvs6L%2Bsm5KYExFYB6ioaBSJzIDPihid40RGsO9oNDY7jWlxsjJDHjr2hXFpiA0clpluQkFgO0Rok9vuAgB4PvCd%2BVAgaTpjQH44ySRsiqKlH1TImUpIvUtxvwSgp5Aj%2Bokq8vlYiqGfEDjJ9QYAbMvKF%2BGobz%2FJa1SQb5gRfkyivIFD8mXOM%2FkrBIAnQ7Q2isA%2Bn0ubKcIl91Ie6WGt%2FokSnawVq7%2BRM%2BID3%2Bc0yCa9ERAF4LufH6rAuYZ9vUETIu3Gpl%2BNNt9MpuHAeKvqUL%2BZfhTBPs55oxQEcFv4LHfsO0L6jU1rN3mTXluASwxC3z34gULSKQAx1%2BRFdFB3C5H%2FNrngHCpMHsCiMBHYVfemAWjUaod8SL4hYbJo4SamZMgYsmr2L2WfSeexRXiItWNhqKHZDhYEyEu6bHD3nV1rmyjUxQRaGhkRBc5riVw3NGSJfY63pAVkski4UxHH2BkHvhq9Ow3rUVaDQ2tUCeDddAK1bhBkVIOBged66ciu3NKfLxYJP2S1wbyuHEzKGEo2aXp59VBq6ekDFVWrXOx6l3DYyyBe991eomnpvhwmzu7ohgb73GHt1jJ94NV%2Fbza0w5y6lexa3M7AhZ3BLRKqeF0oXJWiezNMqrlQuE1%2BM%2BxCc8dsa2ZrC6laJ0bIBXOTi4Nu6i0TZnmH1Qc37ZtsHeC5XknTrDAoQmdvRP4RYrKjt0MrDICbwH0bNew0r9uEfJUMpXNfXhZpld6Un1i4jrXEJN96nDUFeVBW3u14C%2FLBoF4g%2BMV37kVmmuVgyI2qETV0dIGSqrzoLiVJxwUH9fcL6BFaXjBXoPq%2Bb3rc09L2YGLKZqLy3gWpgO2ftJHNMThV%2B73SFdlSBgjM40jxUj9J3QbFE%2Fo0FOre3SHjzpOilA9jIvDxwAzf7rHU10GTNx%2B5AsF%2FY8PCtRNcFE3yqEOCo2ijdAVaG2KHOv2Sc3rRDF3BPyPi%2FcfnUTOALvdGGO2wkK5nBLTSuL3QpT%2BedhV9lIObx0K8ScPu9UwJLSvGIY0dcWwKUxCKbREQXG2H53%2FYpIiluzM8TjflYJZjKMJAkE7B3v6yB2437xmHOExikNWD%2BtmpZoDXXlvHYrRVtNm19CUJ1YGZCX0t6vxMpIbWsV0JjquVnNp6Yra1aRKzApFGYetTcNKNSzrcgbGVktak4RLvBBucjcZm9W4AoqWG0%2B6snUI8Zhd3TbUHaCHZZ8g%2BzZInjPnXNZBPTdWOPo0zZzXnlMpHnQMDWH2uWLvqpANEnpae3JiDeRrkzupgS%2BnHK7JojGXIMzRa8VKaTCUtKNJm9%2BcJRzK1H8DCa1XZ5bqCqBaVwDPpTId1aHu%2BiJbqRyGGsjS4TjEEeeejj6sepFjj3vl73zAFxVbnz2x1azvsDlqyOIhmtBE1lTX%2FG%2BK8Dh4aoprvk09XcI59679JRv3tK19OFB9%2BdDAi7JNO9NaO3NH5Qne%2FvGbNJl%2B%2FIHE685M1dGpVmUd5W1cY6bV1fpYFRM4wstSgsi%2FEzoidHjYgEPvTAY8e26%2BIjnmDvAsOep8xmxJ6FMFiqriWJ1Knakoasq662idMhGOhohzVXt56leZ%2BiGJhRwNAoqXSIw%2BxbbWjRYsH%2FesjuY3EHRwuXXApUZUPsRDTCPMklSXH%2FJdLPbwq9i5rlHkonPJjauGgDfhx3762zmJNZC7%2BVXw4ZTquKBOpZ%2BNELXIe0NI%2BTcNko5xSJbNscLSC07OcHXzZnZKUWI3U3L5%2BpiOhrgX%2FPgNb25%2Foyl1x7Y%2FdWXe%2Fw8%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E) to check out the architecture.

### Software
Here are the software components of the stack:

- `Inbound`: Handles the reception of log streams from `Akamai Datastream 2` and pushes them to the `Queue Broker`. 
It operates using [FluentD](https://www.fluentd.org/).
- `Converter`: Converts and filters the logs sent to the `Queue Broker` by the `Inbound`. It was built using [Java Sprint Boot Aapplication](https://spring.io/projects/spring-boot).
- `Outbound`: Transfers processed logs by the `Converter` to an external storage, including S3-compatible solutions. It 
operates using`FluentD`.
- `Queue Broker`: A cluster built on `Apache Kafka` for temporary log storage.
- `Queue Broker Controller`: Responsible to manage the state of the `Queue Broker`. It operates using [Zookeeper](https://zookeeper.apache.org/).
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
- `Object Storage`: Specifies the S3-compliant storage for long-term log retention.
- `Cloud Firewall`: Specifies the firewall rules to manage the traffic to and from the stack.

### Settings and Provisioning
The settings and provisioning are handled by [Terraform](https://terraform.io/). 
If you want to customize the stack and its provisioning by yourself, just edit the following files in the `iac` 
directory:

- `variables.tf`: Defines the provisioning variables. You can also use `terraform.tfvars`.
- `main.tf`: Defines the provisioning providers. You need to create an API Token in advance. Follow how to create the 
API Token [here](#6-other-resources). 
- `compute.tf`: Defines the provisioning of the compute instances.
- `firewall.tf`: Defines the provisioning of the firewall rules.
- `kubernetes.tf`: Defines the provisioning of Kubernetes.
- `test.tf`: Defines the test script for the provisioned environment. 
- `certissues.yaml`: Defines the provisioning of the stack TLS certificate.
- `namespaces.yaml`: Defines the provisioning of the stack namespaces.
- `configmaps.yaml`: Defines the provisioning of the stack settings.
- `secrets.yaml`: Defines the provisioning of the stack secrets.
- `deployments.yaml`: Defines the provisioning of the stack containers.
- `services.yaml`: Defines the provisioning of the stack exposed ports.
- `ingress.yaml`: Defines the provisioning of the stack ingress.
- `stack.yaml`: Defines the provisioning of the stack.

## 5. Requirements

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
   kubectl get pods -A -o wide
   ```  


4. Access the stack UI:  
   Once all pods are running, retrieve the IP address of the `traefik` service:
   ```bash
   kubectl get service traefik -n kube-system -o jsonpath='{.status.loadBalancer.ingress}'
   ```  
   Depending on the number of compute instances provisioned in the Kubernetes cluster, it will show multiple IPs.


5. To test the provisioned environment, execute the following in the project directory:
   ```bash
   ./test.sh
   ```  


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

## 6. Other resources
- [Akamai Techdocs](https://techdocs.akamai.com)
- [Akamai Connected Cloud](https://www.linode.com)

And that’s it! Enjoy!