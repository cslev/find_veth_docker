# find_veth_docker
Simple script to find out which veth interface on the host corresponds to the eth0 interface of a container

# Changelog
## 12/11/2024
Add image info to the output as a new column
## 30/05/2023
Added more inspections for each container considered. Besides `veth` information: 
 - we have the IP address of the container, which can be useful when some service is running inside and we want to use it from the host (e.g., DNSproxy, pihole)
 - MAC address: can be useful, for instance, when crafting packets from the host and sending them into the container
 - Bridge: the docker bridge on the host the container's `veth` is connected virtually

**New dependency**: `jq` for parsing JSON-output of `docker inspect` commands. Dependency checked when running the script. If it fails, please install `jq`.
## 05/05/2023
There is no requirement anymore. The script has been refactored and rethought and now does not have any dependency from the containers. 
Whatever container you are running, the `veth` interface can be identified.

## 18/08/2023
When defining your own network stack, do not use dashes ('-') in the network name. Use only underscores ('_').
For instance, in your `docker-compose.yml`, follow this approach
```
networks:
  internal:
    name: adguard_proxy_network
    ipam:
      config:
        - subnet: 172.22.1.0/24
```
Mind the '_' in the `name` field.

# Usage
```
This script finds out which vethXXXX is connected to what container!
Example: sudo ./find_veth_docker.sh -n <CONTAINER_NAME> -i <INTEFACE_IN_CONTAINER>
		-n <CONTAINER_NAME>: set here the name of the container (Default: No name specified, printing all containers' data).
		-i <INTERFACE_IN_CONTAINER>: set here the name of the interface in the container (Default: eth0).
```

# Example
```bash
sudo ./find_veth_docker.sh
Testing dependencies (jq)...                                                                                                                                                                [DONE]
VETH@HOST	VETH_MAC		CONTAINER_IP	CONTAINER_MAC		Bridge@HOST		Bridge_IP	Bridge_MAC		CONTAINER		Image
veth760591f	3e:1c:6e:95:85:8b	172.30.1.3	02:42:ac:1e:01:03	br-d1b495712e0c		172.30.1.1/24	02:42:e6:48:e9:64	pihole		pihole/pihole:latest
veth8d60e9b	6a:29:dc:42:85:77	172.30.1.4	02:42:ac:1e:01:04	br-d1b495712e0c		172.30.1.1/24	02:42:e6:48:e9:64	dnscrypt-proxy	klutchell/dnscrypt-proxy
veth41b3b1f	16:7e:62:95:b4:b5	172.19.1.2	02:42:ac:13:01:02	br-d9a1a1f4fb28		172.19.1.1/24	02:42:83:ac:7e:dd	portainer	cr.portainer.io/portainer/portainer-ce:latest

```
Or, if you know the container name, you can filter on it immediately.
```bash
sudo ./find_veth_docker.sh -n pihole
Testing dependencies (jq)...                                                                                                                                                                [DONE]
VETH@HOST	VETH_MAC		CONTAINER_IP	CONTAINER_MAC		Bridge@HOST		Bridge_IP	Bridge_MAC		CONTAINER		Image
veth760591f	3e:1c:6e:95:85:8b	172.30.1.3	02:42:ac:1e:01:03	br-d1b495712e0c		172.30.1.1/24	02:42:e6:48:e9:64	pihole		pihole/pihole:latest
```

# Using output for scripts
You might want to change some settings for a particular container's `vethXXXX` device. Let's take an example of `ethtool` that disables checksumming on the interfaces.
```bash
sudo ethtool -K $(./find_veth_docker.sh -n google |grep -v @|awk '{print $1}') tx off rx off
```
