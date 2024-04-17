# OpenVINO and NGINX Plus for Efficient Inference
This repository discusses the deployment of the NGINX Plus and OpenVINO solution for AI Inference. NGINX Plus plays a crucial role in efficiently managing incoming traffic. Renowned for its high performance as both a web server and reverse proxy server, NGINX Plus excels in load balancing and routing incoming Inference traffic across various AI model serving environments.

Here's the architecture diagram for the setup: model servers run within containers on VMs, with NGINX Plus operating as a load balancer in High Availability (HA) mode. One NGINX Plus instance is active, managing inference traffic, while the other serves as a passive backup. Health checks are configured between the model servers and NGINX Plus to ensure resilient monitoring, detecting any downtime in the model servers.

NGINX Plus offers a dashboard that displays real-time insights into the health status of the model servers, including metrics such as latency, traffic rate, and other relevant details.

![image](https://github.com/f5businessdevelopment/F5openVino/assets/13858248/447028cc-8835-42c6-bf4b-2917ae842abd)
