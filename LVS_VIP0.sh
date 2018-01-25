#!/bin/bash

VIP=192.168.98.77 #虚拟ip（供用户访问的ip）
RIP1=192.168.98.74 #真实服务器(real server)ip
RIP2=192.168.98.117 #真实服务器(real server)ip
PORT=2200 #端口


case "$1" in
	start)
		echo "start config LVS Director Server..."
		ifconfig eth0:0 $VIP broadcast $VIP netmask 255.255.255.255 up
		route add -host $VIP dev eth0:0
		echo "1">/proc/sys/net/ipv4/ip_forward

		ipvsadm -C
		ipvsadm -A -t $VIP:$PORT -s rr 120
		ipvsadm -a -t $VIP:$PORT -r $RIP1:$PORT –g 
		ipvsadm -a -t $VIP:$PORT -r $RIP2:$PORT –g 
		ipvsadm
		echo "config LVS Director Server success!"
		;;
	stop)
		echo "shut down LVS Director Server"
		echo "0">/proc/sys/net/ipv4/ip_forward
		ipvsadm -C
		ifconfig eth0:0 down
		echo "shut down LVS Director Server success!"
		;;
	status)
		if [ ! e  /var/lock/subsys/ipvsadm ];then
			echo "ipvsadm stopped!"
		else
			echo "ipvsadm started!"
		fi
		;;
		*)
		echo "usage:$0 {start|stop|status}"
		exit 1
esac

