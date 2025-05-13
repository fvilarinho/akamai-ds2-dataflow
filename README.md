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
Follow this [diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=architecture.drawio&dark=auto#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%2292RJ4OFCEY1Zh97tm0ry%22%3E7V1bk9q4Ev41VG0eSMnylUdghtnZXHb2zNlK8ihAgDPGYm0xwP76I9kyvkgYM9gYMiepSmFZsuX%2B%2BqbultLRh8vtQ4BWiy9kir0OBNNtR7%2FrQNgzDfYvb9jFDZpugbhlHrhT0ZY2PLv%2FYtGYdFu7UxzmOlJCPOqu8o0T4vt4QnNtKAjIJt9tRrz8W1dojqWG5wny5NZv7pQuRKtm9dIbv2N3vhCvdqAd31iipLP4knCBpmSTadLvO%2FowIITGv5bbIfY48RK6xONGB%2B7uJxZgn1YZ4FjxiFfkrcXHiYnRXfK1AVn7U8wHaB19sFm4FD%2Bv0ITf3TB8WduCLj1xe%2BZ63pB4JGDXPvFZp4E8JzHNVxxQvM00iTk%2BYLLENNixLsndnqCX4JiubYuGTUp%2FB4i2RYb0GgC6AF6APt8%2FPaUL%2ByFIoyaT7dwEmXQ7TyZo6hKVDFtFJQOcTyTLbJ5IIQ3IC04aPf4F3SkKXn7rQH02A4CzAJso%2B1fHU%2F73Qz2UhXqBAQ1gS6S1dQVpTb0G0mqGREk8ZSpJXJKALsic%2BMi7T1sHKa0Bu0r7fCZkJSj8E1O6E%2FoVrSnJ0x9vXfqdD%2F9oiqsfmTt3W%2FHk6GInLvIAMRhGI4ejUoJCSNbBRHyVJfQRRcEci26jWXdNB19%2BN8F4%2Fdd%2F7r%2F7f878rmAtToVS%2FALsIeq%2B5hX3WaoAvBMoEpWbhSKB5%2FJkVzJBIsapwum%2FoCVyO9BCS65M%2FHG4ir7X8tgXDKbuK%2Fs55z%2FvEEWMQBgt2QNg0oHNItPnTO1FfJpwhcIun6yCDKtoA03ZBmpQoYKsOjSQ%2Fk7YvkzbHNVKelvi0ZNN7SXg8dk0v2cvfkRgQTO5TiGKrtQY5c24xf7MZgozvmeGDCukjKFmhlohTyx5ffCKoU%2FEZdM7LOnQgPlnxLMXw1Iu6QcB2mW6rXiHsORFoPgi084%2B7%2FgAzYIFNo3nkDLtniyV%2BNjZgZ%2F3f%2F%2FzbbFzHib3f3zqeuNv3V473k%2FC3CDP3Ofwts3%2BKHlbyVi1Ma6aqnqbphtKpvspINudwlL%2F9vXh8ev3D02Y6CasMnTkhUFjVrl3K0Y5FaZUfn7kxKeKMNVjzPWKxty4Kl9XlwTm0R9zKFUiM2KdfHp3M0Kj2RcUGmHjWpIarZP1Xuxy9%2BWQDbLPMUIATCZ8ISeMEADODIDSOMlRkTIqipR5VSJlSCL11xqznxAMOPUClWT1mVwseJdPaPaCbkbAzAvKl6ZJ339Jq5STL1hRvk5dwPDFfcYqAdDrAaW9AmA4ZMJ2jnCZ126vlO6lBloJlJ0RIK7F%2B1aApfa%2BzTY1nxypHxI%2FUi9KpfcHekWs%2B%2FMqcP35gCenIOivVteq%2FRzNbE%2F7KektZ9me9e6QLFeei%2Fj6WiL5n%2BOfPHHJaE5JwLORNxig1EzzgkZHztCJBSWgkb1mnItD6hJfIhr7PJqnDGJ6w2e%2FJ4wYTCL0ASeCO0FeX9xYutNprK9w6P6LxtGjuMYSERf2XHPQMe%2F4s5iKCmNtJesnkdVSJLoKBub4sueELGFPz4sH1HoyUKpcVi2prJ4sC4zH8R4oj8zDCK8KUXwJWrWUSOOKj6Zk5U4Ove%2BIzL039jG0AvtomkK9ag3JOZQDR3n2YcRgRGc6MMdJYBWQCQ7DqF2gfYM47v3MgFAUcfyRMHd1WE2nmF7SJFSh0ZBSgE4bvmKBuPd9axC56pITv79zKIy1Xz4cWC5U8idhVUe%2F9iSsOthvwjxHQKNQSRNPVMpCvCHsL7IIrUX4Mwu%2BN0Ulec5qNCoDumawTs30aGYvh6UuqqIOJXqK%2FbuWAUoHGI5z5oAkt3R4QK90QD73JHMzMIoU%2BAigY9qaEf9r50l%2BIMV2fFq6U3hSfWJiW22ISZk6nPZ5OSW3kR4KQ2ZVeXcU0JHLP6IY%2BreYp5ARsy74CNKWA7IWXT3hwGV04kZYCCB7R%2FJqYSrZZMRbS5eRKo0rrfyrxVpq17i2UQzbmaASL52sDkBBtx%2FVB8UBR%2BXbLoYgTx6QlPseGmBJ2etTB2hHVI6pG6UDzk53QzkQ058wd1YS83CBVvzneunFHVJn9DMaY%2B%2BJOZfCHxwTSslS4a1SUn%2BoxQT5UAt05IpT1UqylqWAHFUZYTpZlCwFNi7lt5%2FZJMHw86NE5ltYA%2By1bx3wwfxaTlUwDFVl1XU4%2FXo7eYJayjoq%2BXxZU5MQ7PJR%2FHoqgxL%2FqHJlELQLvHCepkzolysul%2BI6xfwd%2BPuxalTnWKoveti1Rrxhqwl1XbWJJKYT110dvhEnERvrnzWJSbYv9EubYmrm47ZqSBMQ4uffamRuimdo7dGaeKC4RwY69kdFBF61%2F6MOdZ7s6irb%2FtHGauW0iiHDaUtPV95m084GhHYKuCrD0drGBEO1NUzO561prljruPW5sRIuw7icvTHlfR9P65A79v2oX7IJBARos%2Ff9b8021Jy1MZMh%2B%2BW4o7ANVlO2QV7nHlmqvXO49EI2RpGgbSwXI0vXKEKno0il%2Fwq5tBrgsgrr6K4hJ880syHALBmwSilRFF378y67uYzwE6UmNwhmnbJXXExpUBEUaUpTWrIX3Z%2FwzPUeTb7%2BAd2bROl4yOSUKhZ1BDsnck2FruyWd0PCN%2B28aDzJeVs7uS05bPHoz4NI1mR%2F%2FL8BwjP35Vb88TQNeQmPPIk2nR6K50ZICrT9PzTPwyn5zIpKv8GmYjmOHG0drpl%2FsIy8wK%2BYbkjwUgGiqnSsDqVKkvKKte6yVquQlNUtBRBNOeOOvO3rK5lG8VDkIX%2FC8ThH89RNLCkIaSaFgNkjaFTFgXYd1JKXmZ%2FWYxz4mGKucyYeY2IFyX5NxrW1whryknwrR8X2UZlhfCpXZAyGHllP3wkeVqHiCao0emOAyGXXe0CKZ6FEDTOPbG7HCAufOfJw68ZNL1Z47Y9zyxY59BTA1XGqVk9e3UuwXOmm7yY2bysKtBLKX7oetmv1CvhWrRmUntRgzWBP4crFSheM3ABvEO99VS5E8ag1S%2BFCKI9aq8WFUO9lbLlU5ZycW6MnkJScLHJNmyAPoNqyJn1bFOcXZQWrTVboycss5Zlx4WJMUDANq6dxHwI0Q36TBwVImlWB1EFl60hlW5cMG5UohWNYfCG%2BSwnfjyz81TEKD%2B6SlWF59Gfeens3uFpcCie5djVHYQRNBSw1nHZbIqA5WHIYPOPgVb17%2FCngU1jgdXit1LaLe99U1HZUQtAUtTXQaoYhf0hN1UM0ChW1Z50CWPNZDWqW7t2EcdKSnUvXwAtVWSFzRNEby8RAdqnYGN7N7e45teTaTvL4acm1k%2BWd4wOcI7tZTFDW%2F%2BwS7VKaH64NTrk6KQTmN7pxIKjPOmhgtY3NeKFQWH1ak1QVrNr9X88Esgaw9OVVDiSoZ0r9OU4PFGl9Nhnbz7rdb1eEHzHz4cT5tewdSMU9Ku9ASw4guZB7cNhJPr%2FkPufX%2FcLl9mdxhXRegnLlVFPNF7tM%2F0%2BQWDWn%2F7OKfv8%2F%3C%2Fdiagram%3E%3C%2Fmxfile%3E) to check out the architecture.

### Stack
Here are the software components of the stack:

- `Inbound`: Handles the reception of logs from `Akamai Datastream 2` and pushes them to the `Queue Broker`. It operates 
using [FluentD](https://www.fluentd.org/).
- `Queue Broker`: Responsible for temporary log storage. It operates using [Apache Kafka](https://kafka.apache.org/).
- `Queue Broker Controller`: Responsible to manage the state of the `Queue Broker`. It operates using [Zookeeper](https://zookeeper.apache.org/).
- `Queue Broker Monitoring Agent`: Responsible to monitor the health of the `Queue Broker`. It operates using 
[Prometheus Kafka Exporter](https://github.com/danielqsj/kafka_exporter/).
- `Queue Broker UI`: UI for `Queue Broker`. It operates using [Redpanda Console](https://www.redpanda.com/redpanda-console-kafka-ui).
- `Monitoring Server`: Responsible to centralize the metrics collected. It operates using [Prometheus](https://prometheus.io/).
- `Monitoring Database`: Responsible to store the metrics collected. It operates using [InfluxDB](https://www.influxdata.com/).
- `Converter`: Responsible to process and filter the logs sent to the `Queue Broker` by the `Inbound`. It operates using
[Java Sprint Boot Aapplication](https://spring.io/projects/spring-boot/).
- `Outbound`: Responsible to push the processed logs by the `Converter` to an external storage 
(e.g S3-compatible storage). It operates using [FluentD](https://www.fluentd.org/). 
- `Proxy`: Routes incoming traffic to the appropriate component based on the specified path (e.g., `/ingest` routes to 
`Inbound`, and `/panel` routes to the `Queue Broker UI` and so on). It operates using [NGINX](https://nginx.org/).
- `Cert Manager`: It automates the creation, renewal, and deployment of the TLS certificate used by the `Ingress`.
- `Ingress`: Enables external HTTPS traffic within the stack. It operates using [Traefik](https://doc.traefik.io/traefik/)

### IaaS
Here are the IaaS components provisioned in `Akamai Connected Cloud` and used by the stack.

- `Linodes`: Compute instances (also known as Virtual Private Servers) used to run the stack using Kubernetes ([K3S](https://k3s.io/)).
- `Object Storage`: Specifies the S3-compliant storage for long-term log retention.
- `Cloud Firewall`: Specifies the firewall rules to manage the in/out traffic of the stack.
- `Node Balancer`: Specify the load balancing strategy for the stack.
- `Property` and `CP Code`: CDN configurations.

### Settings and Provisioning
The settings and provisioning are handled by [Terraform](https://terraform.io/). 
If you want to customize the stack and its provisioning by yourself, just edit the following files `iac/variables.tf` or
`iac/terraform.tfvars`.

## 5. Requirements

### Build, packaging and publishing
The Inbound, Outbound, and Converter components require compilation and packaging before deployment. Below are the necessary requirements:
 
- [JDK 21 or later](https://www.oracle.com/java/technologies/downloads)
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


4. Access the stack:  
   Once the deployment completes, you can retrieve the IP address of the `ingress` service by:
   ```bash
   kubectl get service traefik -n kube-system -o jsonpath='{.status.loadBalancer.ingress}'
   ```  
   Depending on the number of compute instances provisioned in the Kubernetes cluster, it will show multiple IPs. 
   
   Alternatively, you can use the Node Balancer IP/Hostname or even the CDN hostname. Please check the settings defined 
   in variables file. Follow below the URLs of the stack:

   - Logs Ingestion: /ingest
   - Queue Broker UI: /panel
   - Monitoring UI: /dashboards


5. To test the provisioned environment, execute the following in the project directory:
   ```bash
   ./test.sh
   ```  


6. Configure Akamai Datastream 2 in Akamai Control Center:  
   In the destination section, use the following settings:
   ```text
   Destination Type: Custom HTTPs
   Endpoint: https://<ip>/ingest
   Authentication type: BASIC
   User: Type the user defined in the variables file.
   Password: Type the password defined in the variables file.
   Content-Type: application/json
   ```  
   Please replace the `<ip>` placeholder, with the IP/Hostname in the procedure 4 described above.


## 6. Other resources
- [Akamai Techdocs](https://techdocs.akamai.com)
- [Akamai Connected Cloud](https://www.linode.com)

And that’s it! Enjoy!