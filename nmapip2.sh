#!/bin/bash
#
# description:通过nmap扫描网络主机IP地址，并判断主机操作系统类型
#
# @name:      nmapip,sh
# @author:    chenhongyu
# @created:   2019.03.15
# @version:   v1.1
# @Modified:
# No        Name               Date         Description
# --- -------------------- -----------  ------------------------------------------------
# 1   增加主机类型判断     2015-09-23   通过icmp的ttl判断主机操作类型   
# 2   
# --------------------------------------------------------------------------------------

#网段扫描结果
netip=nmap_ip_`date +%F`

#IP地址最终扫描结果
iplist=ip_list_`date +%F`

#主机操作系统类型分类文件
host_linux=host_linux_`date +%F`
host_windows=host_windows_`date +%F`
host_unix=host_unix_`date +%F`
host_unknow=host_unkonw_`date +%F`

#采用nmap进行扫描IP网段
function get_ip() {
    seg=`echo $network |awk -F'.' '{print $1}'`
    nmap -sP $network | grep $seg |grep -v "254" 2> /dev/null > $netip
    #echo "[$network]" >> $iplist
   
    #由于扫描的结果，部分主机有主机名和IP地址，部分主机只有IP地址，需进行判断筛选,如下:
    #Nmap scan report for 192.168.19.210
    #Nmap scan report for tableau-server.adts.com (192.168.19.211)
    ip_num=`cat $netip |wc -l`
    for i in `seq 1 $ip_num`
    do
        ip_line=`cat $netip |sed -n $i'p'`
        ip_nf=`echo $ip_line |awk '{print NF}'`
        if [ $ip_nf -eq 5 ]
        then
            ip=`echo $ip_line |awk '{print $NF}'`
            echo $ip >> $iplist
        elif [ $ip_nf -eq 6 ]
        then
            ip=`echo $ip_line |awk -F"(" '{print $2}' |awk -F")" '{print $1}'`
            echo $ip >> $iplist
        else
            echo "---error---$ip_line"
        fi
    done
    rm $netip
}

function get_ostype() {
    for ip in `cat $iplist`
    do
        ttl=`ping -c 1 $ip |grep ttl |awk '{print $6}' |cut -d'=' -f2`
        if [ ! $ttl ];then
            echo $ip >> $host_unknow
        elif [ $ttl -le 64 ];then
            echo $ip >> $host_linux
        elif [ $ttl -gt 64 ] && [ $ttl -le 128 ];then
            echo $ip >> $host_windows
        elif [ $ttl -gt 128 ];then
            echo $ip >> $host_unix
        fi
    done
}

function main() {
    read -p "请输入扫描的网段（eg:192.168.19.0/24): " network
    get_ip
    get_ostype
}

main
