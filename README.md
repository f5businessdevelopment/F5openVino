# OpenVINO and NGINX Plus for Efficient Inference
This repository discusses the deployment of the NGINX Plus and OpenVINO solution for AI Inference. NGINX Plus plays a crucial role in efficiently managing incoming traffic. Renowned for its high performance as both a web server and reverse proxy server, NGINX Plus excels in load balancing and routing incoming Inference traffic across various AI model serving environments.

Here's the architecture diagram for the setup: model servers run within containers on VMs, with NGINX Plus operating as a load balancer in High Availability (HA) mode. One NGINX Plus instance is active, managing inference traffic, while the other serves as a passive backup. Health checks are configured between the model servers and NGINX Plus to ensure resilient monitoring, detecting any downtime in the model servers.

NGINX Plus offers a dashboard that displays real-time insights into the health status of the model servers, including metrics such as latency, traffic rate, and other relevant details.

![image](https://github.com/f5businessdevelopment/F5openVino/assets/13858248/447028cc-8835-42c6-bf4b-2917ae842abd)

## How to use this repository

```git clone https://github.com/f5businessdevelopment/F5openVino.git```

```cd terraformfiles```

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

### Download model files
```
wget https://storage.openvinotoolkit.org/repositories/open_model_zoo/2022.1/models_bin/2/resnet50-binary-0001/FP32-INT1/resnet50-binary-0001.{xml,bin} -P models/resnet50/1

```
- wget: Command-line utility for downloading files from the web.
https://storage.openvinotoolkit.org/repositories/open_model_zoo/2022.1/models_bin/2/resnet50-binary-0001/FP32-INT1/resnet50-binary-0001.{xml,bin}: URL pointing to the ResNet50 model files.

This URL provides both the XML and BIN files for the model.
-P models/resnet50/1: Option specifying the directory where the downloaded files will be saved. Adjust the path as needed.

You can refer here https://docs.openvino.ai/nightly/ovms_docs_deploying_server.html  for additional documentation if required.

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
You can also use docker-compose to deploy

```
[ec2-user@ip-10-0-0-19 dock]$ sudo docker-compose up
WARN[0000] /home/ec2-user/dock/docker-compose.yml: `version` is obsolete 
[+] Running 8/0
 ✔ Container dock-resnet3-1  Created                                                                                  0.0s 
 ✔ Container dock-resnet4-1  Created                                                                                  0.0s 
 ✔ Container dock-resnet5-1  Created                            
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

### setup venv
```
pip install virtualenv
virtualenv venv
source venv/bin/activate
pip install numpy
pip install ovmsclient
pip install urllib3==1.26.7
```

### Download input files: an image and a label mapping file
```
wget https://raw.githubusercontent.com/openvinotoolkit/model_server/main/demos/common/static/images/zebra.jpeg
wget https://raw.githubusercontent.com/openvinotoolkit/model_server/main/demos/common/python/classes.py
pip3 install ovmsclient
```

### Run Prediction
```
echo 'import numpy as np
from classes import imagenet_classes
from ovmsclient import make_grpc_client

client = make_grpc_client("10.0.0.228:9001") # Is the gRPC NGINX plus load balancer IP and port

with open("zebra.jpeg", "rb") as f:
   img = f.read()

output = client.predict({"0": img}, "resnet")
result_index = np.argmax(output[0])
print(imagenet_classes[result_index])' >> predict.py
```

```
python3 predict.py zebra.jpg

```

zebra
### NGINX Plus Dashboard
To enable the dashboard make sure you have configured the dashboard.conf, you can pick up file from https://github.com/f5businessdevelopment/F5openVino/blob/main/dashboard.conf
```
 /etc/nginx/config.d/dashboard.conf
sudo systemctl restart nginx
sudo nginx -t
```
![image](https://github.com/f5businessdevelopment/F5openVino/assets/13858248/91bb339e-5d8f-4aed-9dc5-f0398e788010)

### For NGINX PLUS HA
For NGINX PLUS HA capabilities, setup each of the instance as referred in https://www.nginx.com/products/nginx/high-availability/
### NGINX Plus proxy tests with gRPC & REST using SSL

### `wrk` Command Documentation:

```bash
wrk -t12 -c400 -d30s https://10.0.0.228
```

- `-t12`: Specifies the number of threads to use for generating load.
- `-c400`: Sets the number of HTTP connections to maintain concurrently.
- `-d30s`: Specifies the duration of the test, in this case, 30 seconds.
- `https://10.0.0.228`: The URL to target for sending HTTP requests.

### Output Documentation for Test on `https://10.0.0.228` gRPC SSL:

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

### Output Documentation for Test on `https://10.0.0.228:8443`REST SSL:

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


 
