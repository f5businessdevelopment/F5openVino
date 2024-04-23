# OpenVINO and NGINX Plus for Efficient Inference
This repository discusses the deployment of the NGINX Plus and OpenVINO solution for AI Inference. NGINX Plus plays a crucial role in efficiently managing incoming traffic. Renowned for its high performance as both a web server and reverse proxy server, NGINX Plus excels in load balancing and routing incoming Inference traffic across various AI model serving environments.

Here's the architecture diagram for the setup: model servers run within containers on VMs, with NGINX Plus operating as a load balancer in High Availability (HA) mode. One NGINX Plus instance is active, managing inference traffic, while the other serves as a passive backup. Health checks are configured between the model servers and NGINX Plus to ensure resilient monitoring, detecting any downtime in the model servers.

NGINX Plus offers a dashboard that displays real-time insights into the health status of the model servers, including metrics such as latency, traffic rate, and other relevant details.

![image](https://github.com/f5businessdevelopment/F5openVino/assets/13858248/447028cc-8835-42c6-bf4b-2917ae842abd)

## How to use this repository

```git clone https://github.com/f5businessdevelopment/F5openVino.git```

```cd F5openVino/terraformfiles```

Check the ```variables.tf``` file adjust the values as per your requirements, Let the region be default ```us-west-2``` as the AMI is tied to that region.

```
terraform init
terraform plan
terraform apply --auto-approve
```
You will see update like as shown below ....
```
Outputs:

To_SSH_nginx-plus = [
  "ssh -i terraform-20240418005151594500000001.pem ec2-user@PUBLIC_IP_ADDRESS0"
  "ssh -i terraform-20240418005151594500000001.pem ec2-user@PUBLIC_IP_ADDRESS1"
]
```
NEXT ssh into the VM 
```
ssh -i terraform-20240418005151594500000001.pem ec2-user@PUBLIC_IP_ADDRESS0
```
### Download Docker on the EC2

```
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
```
 
### Compose script to deploy model servers
```
cat <<'EOF' > deploy.sh
#!/bin/bash

echo "Starting deployment script..."

# Define models and ports
models=("resnet" "yolo" "ssd")
ports=(9001 9002 9003)

# Create containers
for ((i = 0; i < ${#models[@]}; i++)); do
    model_name="${models[$i]}"
    port="${ports[$i]}"
    echo "Creating container for model: $model_name, port: $port"
    docker run -d -u 1000 --rm -v /home/ec2-user/model:/model -p $port:$port openvino/model_server:latest --model_name $model_name --model_path /model --port $port
done

echo "Deployment complete."
EOF

```

### In case you want to clean up, follow this script
```
cat <<EOF > s.sh
#!/bin/bash

# Stop and remove containers
docker ps -q | xargs docker stop
docker ps -a -q | xargs docker rm
docker ps
EOF
```

### Nginx proxy tests with gRPC & REST using SSL

Sure, here's a documentation of the `wrk` command and its output:

### `wrk` Command Documentation:

```bash
wrk -t12 -c400 -d30s https://10.0.0.228
```

- `-t12`: Specifies the number of threads to use for generating load.
- `-c400`: Sets the number of HTTP connections to maintain concurrently.
- `-d30s`: Specifies the duration of the test, in this case, 30 seconds.
- `https://10.0.0.228`: The URL to target for sending HTTP requests.

### Output Documentation for Test on `https://10.0.0.228`:

```
Running 30s test @ https://10.0.0.228
  12 threads and 400 connections

Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    27.90ms   26.34ms   1.12s    96.21%
    Req/Sec   315.77     92.88     1.26k    79.75%

106848 requests in 30.10s, 39.64MB read
Non-2xx or 3xx responses: 106848

Requests/sec:   3550.21
Transfer/sec:      1.32MB
```

- **Thread Stats**: Statistics for each thread's performance during the test.
  - `Avg`: Average latency or response time.
  - `Stdev`: Standard deviation of the latency.
  - `Max`: Maximum latency observed.
  - `+/- Stdev`: Percentage of requests within one standard deviation of the average latency.
- **Requests**: Total number of requests made during the test.
- **Non-2xx or 3xx responses**: Number of responses that were not successful (i.e., not in the 200-300 range).
- **Requests/sec**: Average number of requests processed per second.
- **Transfer/sec**: Average data transfer rate per second.

### Output Documentation for Test on `https://10.0.0.228:8443`:

```
Running 30s test @ https://10.0.0.228:8443
  12 threads and 400 connections

Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   155.30ms  260.59ms   1.27s    85.87%
    Req/Sec   575.23    136.30     1.37k    79.44%

196507 requests in 30.08s, 124.44MB read
Socket errors: connect 0, read 0, write 0, timeout 7

Requests/sec:   6532.90
Transfer/sec:      4.14MB
```

- The output structure is similar to the previous one but specific to the test conducted on `https://10.0.0.228:8443`.
- Additionally, it reports any socket errors encountered during the test, including connect, read, write, and timeout errors.

These outputs provide insights into the performance of the server under load, including response times, throughput, and error rates. Adjusting the parameters of the `wrk` command can help optimize performance testing for your specific use case.


 
