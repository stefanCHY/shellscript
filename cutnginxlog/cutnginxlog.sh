#!/bin/bash
#
# description:  切割nginx日志并保存在日志自身目录下
#               删除30天前日志文件
#
# @name:      cutnginxlog
# @author:    chenhongyu
# @created:   2019.03.07
# @Introduced:
# @Modified:

#获取脚本目录路径
basepath=$(cd `dirname $0`; pwd)

#nginx日志位置
logdir="/usr/local/nginx/logs2"

#切割日志保存位置
oldlogdir="${logdir}/oldlogs"

if [ ! -d ${oldlogdir} ];then
    mkdir ${oldlogdir}
fi

#获取昨天的日时间
yesterday="$(date -d "yesterday" +%Y%m%d)"

#获取nginx日志文件名
cd ${logdir}
ls -al *.log |awk '{print $9}' > ${basepath}/logname

#按天切割所有日志文件
echo -e "\n------$(date "+%F %T")------" >> ${basepath}/script.log
while read -r line
do
    mv ${logdir}/${line} ${oldlogdir}/${line}_${yesterday}
    echo "======日志文件$line切割完成======" >> ${basepath}/script.log
done < ${basepath}/logname

#向nginx主进程发送USR1信号，重新打开日志文件，否则会继续往mv后的文件写数据的。
#原因在于：linux系统中，内核是根据文件描述符来找文件的。
kill -USR1 `ps aux | grep "nginx: master process" | grep -v grep | awk '{print $2}'`

#删除30天前的日志
#echo echo -e "\n------$(date "+%F %T")进行30天前日志删除操作------" >> ${basepath}/script.log
find ${oldlogdir} -mtime +30 -name "*.log_20[1-9][1-9]*" | xargs rm -f

exit 0
