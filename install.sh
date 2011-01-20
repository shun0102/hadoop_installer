#!/bin/sh

export MASTER="debian.lab.hpcs.cs.tsukuba.ac.jp"
export LOCAL_DISK="/data/local/hadoop"
export CPU_NUM=2
HOSTNAME=`hostname -f`
erb core-site.erb > conf/core-site.xml
erb mapred-site.erb > conf/mapred-site.xml
erb hdfs-site.erb > conf/hdfs-site.xml

cp -f cloudera.list /etc/apt/sources.list.d/cloudera.list
curl -s http://archive.cloudera.com/debian/archive.key | apt-key add -

apt-get update
apt-cache search hadoop
if [ $HOSTNAME = $MASTER ];
then
apt-get -y install hadoop-0.20-namenode
apt-get -y install hadoop-0.20-secondarynamenode
apt-get -y install hadoop-0.20-jobtracker
update-rc.d hadoop-0.20-namenode defaults
update-rc.d hadoop-0.20-secondarynamenode defaults
update-rc.d hadoop-0.20-jobtracker defaults

else
apt-get -y install hadoop-0.20-datanode
apt-get -y install hadoop-0.20-tasktracker
update-rc.d hadoop-0.20-datanode defaults
update-rc.d hadoop-0.20-tasktracker defaults

fi

mkdir -p /etc/hadoop-0.20/conf.cluster
cp -fr conf/* /etc/hadoop-0.20/conf.cluster/
update-alternatives --install /etc/hadoop-0.20/conf hadoop-0.20-conf /etc/hadoop-0.20/conf.cluster 50
update-alternatives --set hadoop-0.20-conf /etc/hadoop-0.20/conf.cluster

mkdir -p $LOCAL_DISK/cache
chown root:root $LOCAL_DISK/cache
chmod 1777 $LOCAL_DISK/cache

mkdir -p $LOCAL_DISK/mapred/local
chown -R mapred:hadoop $LOCAL_DISK/mapred
chmod -R 755 $LOCAL_DISK/mapred

if [ $HOSTNAME = $MASTER ];
then
mkdir $LOCAL_DISK/nn
chown hdfs:hadoop $LOCAL_DISK/nn
chmod 700 $LOCAL_DISK/nn
sudo -u hdfs hadoop namenode -format

else
mkdir $LOCAL_DISK/dn
chown hdfs:hadoop $LOCAL_DISK/dn
chmod 755 $LOCAL_DISK/dn

fi
