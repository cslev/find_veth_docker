#!/bin/bash

 source sources/extra.sh


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
    $INTF="eth0"
  fi



#getting the container names and interface data
c_print "BBlue" "VETH@HOST\tCONTAINER"
for i in $($cmd)
do
  veth_in_container=$(sudo docker exec $i ip a|grep ${INTF}@|cut -d ':' -f 1)
  veth_in_host=$(sudo ip a|grep "if${veth_in_container}"|cut -d ":" -f 2|cut -d '@' -f 1|sed "s/ //g")
  echo -e "${veth_in_host}\t${i}"
done
