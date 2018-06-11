#!/bin/bash

# nginx log 目录
dir=/home/ymt/openresty/nginx/logs

# 按日期切分
fmtd=`date +%Y%m%d`
# 按小时切分
fmth=`date +%Y%m%d.%H%M`

fmt=$fmth

cd $dir 
cp access.log "access."$fmt".log" && > access.log
cp error.log "error."$fmt".log" && > error.log

