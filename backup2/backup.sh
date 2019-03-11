#!/bin/bash
#
# description:  采用rpm包方式安装logstash
#                Test on RHEL-6.5_x86_64
#
# @name:      logstash
# @author:    chenhongyu
# @created:   2018.08.15
# @Introduced:
# @Modified:

. /etc/profile

##脚本参数定义
#获取脚本目录路径
basepath=$(cd `dirname $0`; pwd)
#备份文件保存路径
BackupPath=/opt/yunwei/backup
#脚本日志
LogFile=${BackupPath}/log/`date +"%Y-%m"`.log
#获取本机IP地址
THE_HOST_IP=$(ip addr |grep 'scope global ' |head -1|tr '/' ' ' |awk '{print $2}')

#定义需要的备份文件
FilePath=/etc
FileName=my.cnf
DATE=`date +"%Y-%m-%d"`
BackupFile=${THE_HOST_IP}-${DATE}.${FileName}
#保留备份文件有效期
SaveDay=7


#复制文件进行备份
if [ -f $BackupPath/$BackupFile ]
then
	echo "###backup file have exist###" >>$LogFile
else
	cp $FilePath/$FileName $BackupPath/$BackupFile
	echo "backup finish at $(date +"%Y-%m-%d %H:%M:%S")" >>$LogFile
fi


########################################
#通过FTP上传到备份服务器

HOST=IP地址######
FTP_USERNAME=用户名#######
FTP_PASSWORD=用户密码########
cd  $BackupPath

/usr/bin/ftp -in <<EOF
open $HOST
user $FTP_USERNAME $FTP_PASSWORD
binary
put $BackupPath/$BackupFile
bye
EOF

echo "ftp put end at $(date +"%Y-%m-%d %H:%M:%S")" >>$LogFile
echo " " >> $LogFile

#最后上传完毕后再查看本地备份大于7天的自动删除，这样就可以实现本地异地双备份
find $BackupPath -type f -mtime +$SaveDay -name "*.${FileName}" | xargs rm -f >/dev/null

exit 0
