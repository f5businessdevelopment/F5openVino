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
