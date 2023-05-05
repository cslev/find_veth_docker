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


if [ -z $NAME ]
then
  # c_print "Yellow" "No container name specified...looking for all veths...!"
  cmd="sudo docker ps --format {{.Names}}"
else
  cmd="sudo docker ps --format {{.Names}} -f name=$NAME"
 fi

if [ -z $INTF ]
then
  # c_print "Yellow" "No interface name specified in the container...Using default: ${INTF}!"
  INTF="eth0"
fi



#getting the container names and interface data
c_print "BBlue" "VETH@HOST\tCONTAINER"
for i in $($cmd)
do
  #getting the PIDs of the containers
  PID=$(docker inspect $i --format "{{.State.Pid}}")
  #using the PID, we can get the interface index of the eth0 interfae inside the container
  INDEX=$(cat /proc/$PID/net/igmp |grep $INTF| awk '{print $1}')
  #using the index, we can identify the veth interface
  veth=$(ip -br addr |grep "if${INDEX}"|awk '{print $1}'|cut -d '@' -f 1)

  #residuals from previous version that required built-in tools inside the container, but keeping them for reference
  #veth_in_container=$(sudo docker exec $i ip a|grep ${INTF}@|cut -d ':' -f 1)
  #veth_in_host=$(sudo ip a|grep "if${veth_in_container}:"|cut -d ":" -f 2|cut -d '@' -f 1|sed "s/ //g")

  echo -e "${veth}\t${i}"
done
