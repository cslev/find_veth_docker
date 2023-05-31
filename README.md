# find_veth_docker
Simple script to find out which veth interface on the host corresponds to the eth0 interface of a container

# Changelog
## 30/05/2023
Added more inspection for each container considered. Besides `veth` information: 
 - we have the IP address of the container, which can be useful, when some service is running inside and we want to use it from the host (e.g., DNSproxy, pihole)
 - MAC address: can be useful, for instance, when crafting packets from the host and send them into the container
 - Bridge: the docker bridge on the host the container's `veth` is connected virtually

**New dependency**: `jq` for parsing JSON-output of `docker inspect` commands. Dependancy checked when running the script. If fails, please install `jq`.

## 05/05/2023
There is no requirement anymore. The script has been refactored and rethought and now does not have any dependency from the containers. 
Whatever container you are running, the `veth` interface can be identified.


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
Testing dependencies (jq)...                                                                                                                               [DONE]
VETH@HOST	VETH_MAC		CONTAINER_IP	CONTAINER_MAC		Bridge@HOST		Bridge_IP	Bridge_MAC		CONTAINER
vethf1cafc6	26:9e:b8:64:db:f8	172.30.1.3	02:42:ac:1e:01:03	br-22977ef1c283		172.30.1.1/24	02:42:1e:ba:ce:ed	pihole
vetha4867b4	62:5d:d2:59:81:1e	172.30.1.4	02:42:ac:1e:01:04	br-22977ef1c283		172.30.1.1/24	02:42:1e:ba:ce:ed	dnscrypt-proxy
veth5c15bec	b6:e6:17:5c:ef:82	172.20.1.2	02:42:ac:14:01:02	br-5399ca212f48		172.20.1.1/24	02:42:a6:fc:1a:a0	portainer
```

# Using output for scripts
You might want to change some setting for a particular container's `vethXXXX` device. Let's take an example for `ethtool` that disables checksumming on the interfaces.
```bash
sudo ethtool -K $(./find_veth_docker.sh -n google |grep -v @|awk '{print $1}') tx off rx off
```
