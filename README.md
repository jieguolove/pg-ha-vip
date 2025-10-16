# pg-ha-vip 2.0版本
两节点的postgresql+repmgr主备集群方式，配置vip便于应用透明连接。
实际案例：
pg17.6+repmgr5.5
原理：
在两节点配置随机启动的脚本，实现每3秒自动检测哪个是主库，如果判定为主库则将vip挂接在主库所在的网卡上，实现应用快速透明连接。(通过脚本方式比使用keepalive更方便灵活）

随系统启动的配置：在/etc/rc.local 添加如下内容：
/etc/vip_check.sh > /dev/null 2>&1 &
确认可执行权限:
chmod +x /etc/rc.d/rc.local
其中/etc/vip_check.sh的脚本内容如下：
#!/bin/bash
step=3
while true; do
    /etc/vip_repmgrd.sh > /dev/null 2>&1
    /etc/vip_pg.sh > /dev/null 2>&1
    sleep $step
done

表示每3秒检测一次。

其中/etc/vip_repmgrd.sh内容如下：
#!/bin/bash
pg_stats=`su - postgres -c "pg_ctl status"|grep PID|wc -l`
repmgrd_stats=`ps -ef|grep "repmgrd -d"|grep -v grep|wc -l`
 
if [[ "${pg_stats}" -eq 1 ]] ; then
    if [[ "${repmgrd_stats}" -eq 0 ]]; then
        su - postgres -c "repmgrd -d"
    fi
表示pg库运行的情况下，启动repmgr的监测进程，确保可以在主备故障的时候可以实现自动切换主备库。如果不期望自动切换，则注释该行 #   /etc/vip_repmgrd.sh > /dev/null 2>&1

其中/etc/vip_pg.sh内容如下：
#!/bin/bash
dbstats=`su - postgres -c "repmgr cluster show"|grep longxi01|grep primary|grep running|wc -l`
ip=`/usr/sbin/ip a|grep ens192:1|wc -l`
 
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

longxi01为节点1的主机名，如果在节点2部署，则改名为longxi02即可。根据两节点实际情况修改。
网卡ens192为ip a看到的网卡名称，根据实际情况修改。
ip地址根据实际情况修改。

两节点的集群实际配置效果如下图：
<img width="1885" height="883" alt="image" src="https://github.com/user-attachments/assets/d25a1147-f997-4dc2-a5db-77bc58f83458" />
