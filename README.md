# find_veth_docker
Simple script to find out which veth interface on the host corresponds to the eth0 interface of a container

# Usage
```
This script finds out which vethXXXX is connected to what container!
Example: sudo ./find_veth_docker.sh -n <CONTAINER_NAME> -i <INTEFACE_IN_CONTAINER>
		-n <CONTAINER_NAME>: set here the name of the container (Default: No name specified, printing all containers' data).
		-i <INTERFACE_IN_CONTAINER>: set here the name of the interace in the container (Default: eth0).
```

# Example
```bash
sudo ./find_veth_docker.sh -n google
VETH@HOST	CONTAINER
veth003b9c4	google
```

# Using output for scripts
You might want to change some setting for a particular container's `vethXXXX` device. Let's take an example for `ethtool` that disables checksumming on the interfaces.
```bash
sudo ethtool -K $(./find_veth_docker.sh -n google |grep -v @|awk '{print $1}') tx off rx off
```
