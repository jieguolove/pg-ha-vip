#!/bin/bash
pg_stats=`su - postgres -c "pg_ctl status"|grep PID|wc -l`
repmgrd_stats=`ps -ef|grep "repmgrd -d"|grep -v grep|wc -l`
 
if [[ "${pg_stats}" -eq 1 ]] ; then
    if [[ "${repmgrd_stats}" -eq 0 ]]; then
        su - postgres -c "repmgrd -d"
    fi
fi
