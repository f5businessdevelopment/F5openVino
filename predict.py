import numpy as np
from classes import imagenet_classes
from ovmsclient import make_grpc_client

client = make_grpc_client("10.1.1.7:80")

with open("zebra.jpeg", "rb") as f:
   img = f.read()

output = client.predict({"0": img}, "resnet")
result_index = np.argmax(output[0])
print(imagenet_classes[result_index])
