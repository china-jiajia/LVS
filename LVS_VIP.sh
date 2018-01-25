#!/bin/bash

SNS_VIP=$2
SNS_RIP1=$3
SNS_RIP2=$4

if [ "$1" == "stop" -a -Z "$2" ];then
	echo "----------------------------------------------"
	echo -e "\033[32mPlease Enter $0 stop LVS_VIP\n\nEXample:$0 stop 192.168.2.100\033[0m"
	echo 
	exit
else
	if [ -z "$2" -a -Z "$3" -a -Z "$4" ];then
		echo "------------------------------------------"
		echo -e "\033[32mPlease Enter Input $0 start VIP REALSERVER1 REASERVER2\n\nEXample:$0 start/stop 192.168.2.13 192.168.2.14\033[0m"
		echo
		exit 0
	fi
fi

. /etc/rc.d/init.d/functions

logger $0 called with $1

function IPVSADM(){
/sbin/ipvsadm --set 30 5 60 
/sbin/ifconfig eth0:0 $SNS_VIP broadcast $SNS_VIP network 255.255.255.255 broadcast $SNS_VIP up
/sbin/route add -host $SNS_VIP dev eth0:0
/sbin/ipvsadm -A -t $SNS_VIP:3306 -s rr -p 120
/sbin/ipvsadm -a -t $SNS_VIP:3306 -r $SNS_RIP1:3306 -g -w 1
/sbin/ipvsadm -a -t $SNS_VIP:3306 -r $SNS_RIP2:3306 -g -w 1
}



case "$1" in
	start)
		IPVSADM()
		/sbin/ipvsadm -Ln
		touch /var/lock/subsys/ipvsadm >/dev/null 2>&1
		;;
	stop)
		/sbin/ipvsadm -C
		/sbin/ipvsadm -Z
		ifconfig eth0:0 down >>/dev/null 2>&1
		route del $SNS_VIP >>/dev/null 2>&1
		rm /var/lock/subsys/ipvsadm -rf >/dev/null 2>&1
		echo "ipvsadm stopped!"
		;;
	status)
		if [ ! -e /var/lock/subsys/ipvsadm ];then
			echo "ipvsadm stopped!"
			exit 1
		else
			echo "ipvsadm started!"
		fi
		;;
		*)
	echo  "Usage: $0 {start|stop|status}"
	exit
esac
exit 0
