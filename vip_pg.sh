#!/bin/bash
dbstats=`su - postgres -c "repmgr cluster show"|grep longxi01|grep primary|grep running|wc -l` ### 在节点2上该脚本需修改longxi01为longxi02，请根据hostname和repmgr cluster show看到的实际修改，其它一样
ip=`/usr/sbin/ip a|grep ens192:1|wc -l` ##网卡名称ens192请根据ip a看到是实际修改
 
if [[ "${dbstats}" -eq 1 ]] ; then
    if [[ "${ip}" -eq 0 ]]; then
    /usr/sbin/ifconfig ens192:1 192.168.207.49 netmask 255.255.255.0 up
    /usr/sbin/arping -I ens192 -b -s 192.168.207.49 192.168.207.1 -c 3
    fi
else
    if [[ "${ip}" -gt 0 ]]; then
    /usr/sbin/ifconfig ens192:1 down
    fi
fi
