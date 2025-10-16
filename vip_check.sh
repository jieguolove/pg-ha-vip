#!/bin/bash
step=3
while true; do
    /etc/vip_repmgrd.sh > /dev/null 2>&1
    /etc/vip_pg.sh > /dev/null 2>&1
    sleep $step
done
