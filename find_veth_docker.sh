#!/bin/bash
ROOT="$(dirname "$0")"

source $ROOT/sources/extra.sh


function show_help
 {
 	c_print "Green" "This script finds out which vethXXXX is connected to what container!"
 	c_print "Bold" "Example: sudo ./find_veth_docker.sh -n <CONTAINER_NAME> -i <INTEFACE_IN_CONTAINER>"
 	c_print "Bold" "\t\t-n <CONTAINER_NAME>: set here the name of the container (Default: No name specified, printing all containers' data)."
  c_print "Bold" "\t\t-i <INTERFACE_IN_CONTAINER>: set here the name of the interace in the container (Default: eth0)."
 	exit
 }

NAME=""
INTF=""

while getopts "h?n:i:" opt
 do
 	case "$opt" in
 	h|\?)
 		show_help
 		;;
 	n)
 		NAME=$OPTARG
 		;;
  i)
    INTF=$OPTARG
    ;;
  *)
    show_help
 		;;
 	esac
 done

c_print "White" "Testing dependencies (jq)..." 1
which jq >> /dev/null
retval=$(echo $?)
check_retval $retval



if [ -z $NAME ]
then
  # c_print "Yellow" "No container name specified...looking for all veths...!"
  cmd="sudo docker ps --format {{.Names}}"
  # testing cmd
  cmd_test=$($cmd)
  if [[ -z $cmd_test ]]
  then
    c_print "Red" "There is no container running on the system..."
    exit
  fi

else
  cmd="sudo docker ps --format {{.Names}} -f name=$NAME"
  # testing cmd
  cmd_test=$($cmd)
  if [[ -z $cmd_test ]]
  then
    c_print "Red" "There is no container running on the system with the name ${NAME}.."
    exit
  fi
fi

if [ -z $INTF ]
then
  # c_print "Yellow" "No interface name specified in the container...Using default: ${INTF}!"
  INTF="eth0"
fi



#getting the container names and interface data
c_print "BBlue" "VETH@HOST\tVETH_MAC\t\tCONTAINER_IP\tCONTAINER_MAC\t\tBridge@HOST\t\tBridge_IP\tBridge_MAC\t\tCONTAINER\t\tImage"
for i in $($cmd)
do
  # c_print "BWhite" "${i}"
  #getting the PIDs of the containers
  PID=$(sudo docker inspect $i --format "{{.State.Pid}}")
  #using the PID, we can get the interface index of the eth0 interfae inside the container
  INDEX=$(sudo cat /proc/$PID/net/igmp |grep "$INTF"| awk '{print $1}') 
  #using the index, we can identify the veth interface
  veth=$(sudo ip -br addr |grep "if${INDEX} "|awk '{print $1}'|cut -d '@' -f 1) #we need that extra whitespace at grep "if${INDEX} ", otherwise interface with the prefix will shown too
  if [[ -z $veth ]]
  then
    veth="N/A\t" #add extra Tabs straight away for prettify
    veth_mac="N/A\t\t" #add extra Tabs straight away for prettify
  else
    veth_mac=$(sudo ip a|grep $veth -A 2|grep ether|awk '{print $2}')
  fi

  #check if there is any special subnet created instead of the default
  network_mode=$(sudo docker inspect $i|jq -r .[].HostConfig.NetworkMode)

  if [ "$network_mode" == "default" ]
  then
    network="bridge"
  else
    network=$network_mode
  fi
    
  ip_address=$(sudo docker inspect $i|jq -r .[].NetworkSettings.Networks.$network.IPAddress)
  image=$(sudo docker inspect $i|jq -r .[].Config.Image)
  mac_address=$(sudo docker inspect $i| jq -r .[].NetworkSettings.Networks.$network.MacAddress)
  gateway=$(sudo docker inspect $i| jq -r .[].NetworkSettings.Networks.$network.Gateway)
  if [[ -z $gateway ]]
  then
    bridge="N/A\t"
    bridge_ip="N/A\t"
    bridge_mac="N/A\t\t"
  else
    bridge=$(sudo ip -br addr |grep $gateway|awk '{print $1}')
    if [[ -z $bridge ]]
    then
      bridge="N/A\t"
      bridge_ip="N/A"
      bridge_mac="N/A"
    else
      bridge_ip=$(sudo ip a |grep $bridge |grep inet|awk '{print $2}')
    
      #colons are super important below, without them, grep would find the veth interfaces as well that are connected to the bridge
      #by grepping on the ": <VETH>:", only the right line will be found
      bridge_mac=$(ip a |grep ": ${bridge}:" -A 1| grep ether| awk '{print $2}')
    fi
  fi
  #residuals from previous version that required built-in tools inside the container, but keeping them for reference
  #veth_in_container=$(sudo docker exec $i ip a|grep ${INTF}@|cut -d ':' -f 1)
  #veth_in_host=$(sudo ip a|grep "if${veth_in_container}:"|cut -d ":" -f 2|cut -d '@' -f 1|sed "s/ //g")

  #the number of characters in the container name can be arbitrarily short, for that we need use Tabs wisely
  # get the number of chars of the container name
  num_chars_name=${#i}
  extra_tab=""
  if [ $num_chars_name -lt 7 ]
  then
    extra_tab="\t"
  fi

  if [ "$bridge" == "docker0" ]
  then
    #we need an extra TAB before Bridge
    echo -e "${veth}\t${veth_mac}\t${ip_address}\t${mac_address}\t${bridge}\t\t\t${bridge_ip}\t${bridge_mac}\t${i}\t${extra_tab}${image}"
  else
    echo -e "${veth}\t${veth_mac}\t${ip_address}\t${mac_address}\t${bridge}\t\t${bridge_ip}\t${bridge_mac}\t${i}\t${extra_tab}${image}"
  fi
done
c_print "Yellow" "\n\nIf you see N/A for veth, try using different interface identifier, e.g., eth1"

