#!/bin/bash

# */1 * * * * /home/ymt/openresty/nginx/ips/shell/cut_trace_log.sh >> /data/crontab.log

# 服务系统 log 目录
dir=/home/ymt/openresty/nginx/ips/log

# 按日期切分
fmtd=`date +%Y%m%d`
# 按小时切分
fmth=`date +%Y%m%d.%H%M`

fmt=$fmth

cd $dir 
cp trace.log "trace."$fmt".log" && > trace.log
cp monitor.log "monitor."$fmt".log" && > monitor.log

