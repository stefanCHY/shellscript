#!/bin/bash
#
# description:扫描C段网络主机IP地址
#             
#
# @name:      nmapip,sh
# @author:    chenhongyu
# @created:   2019.03.14
# @Introduced:
# @Modified:

#网段扫描结果
netip=nmap_ip_`date +%F`

#IP地址最终扫描结果
iplist=ip_list_`date +%F`

#需要扫描的网段
net="19 20 30 32 71 72 81"

#采用nmap进行扫描IP网段
for network in $net
do
    nmap -sP 192.168.$network.0/24 | grep "192.168" |grep -v "254"> $netip
    echo "[IP$network]" >> $iplist
   
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
done
