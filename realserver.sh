#!/bin/sh

VIP=192.168.2.100
. /etc/rc.d/init.d/functions

case "$1" in
# 禁用本地的ARP请求、绑定本地回环地址
start)
    /sbin/ifconfig lo down
    /sbin/ifconfig lo up
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
    /sbin/sysctl -p >/dev/null 2>&1
    /sbin/ifconfig lo:0 $VIP netmask 255.255.255.255 up 
    /sbin/route add -host $VIP dev lo:0
    echo "LVS-DR real server starts successfully.\n"
    ;;
stop)
    /sbin/ifconfig lo:0 down
    /sbin/route del $VIP >/dev/null 2>&1
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
echo "LVS-DR real server stopped.\n"
    ;;
status)
    isLoOn=`/sbin/ifconfig lo:0 | grep "$VIP"`
    isRoOn=`/bin/netstat -rn | grep "$VIP"`
    if [ "$isLoON" == "" -a "$isRoOn" == "" ]; then
        echo "LVS-DR real server has run yet."
    else
        echo "LVS-DR real server is running."
    fi
    exit 3
    ;;
*)
    echo "Usage: $0 {start|stop|status}"
    exit 1
esac
exit 0