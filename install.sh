#!/bin/sh

export MASTER="tsukuba-charlie.intrigger.omni.hpcc.jp"
export LOCAL_DISK="/data/local/hadoop"
export CPU_NUM=8
HOSTNAME=`hostname -f`
erb core-site.erb > conf/core-site.xml
erb mapred-site.erb > conf/mapred-site.xml
erb hdfs-site.erb > conf/hdfs-site.xml

if ! getent group hadoop >/dev/null; then
    groupadd -g 10283 hadoop
fi

if ! getent group mapred >/dev/null; then
    groupadd -g 10343 mapred
    useradd mapred -g mapred -G hadoop -u 10343
    mkdir -p /home/mapred
    chown -R mapred:mapred /home/mapred
fi

if ! getent group hdfs >/dev/null; then
    groupadd -g 10344 hdfs
    useradd hdfs -g hdfs -G hadoop -u 10344
    mkdir -p /home/mapred
    chown -R hdfs:hdfs /home/hdfs
fi

cp -f cloudera.list /etc/apt/sources.list.d/cloudera.list
wget -O - http://archive.cloudera.com/debian/archive.key | apt-key add -

apt-get update
apt-cache search hadoop

apt-get -y install hadoop-0.20
apt-get -y install hadoop-0.20-native

if [ $HOSTNAME = $MASTER ];
then
apt-get -y install hadoop-0.20-namenode
apt-get -y install hadoop-0.20-secondarynamenode
apt-get -y install hadoop-0.20-jobtracker
update-rc.d hadoop-0.20-namenode defaults
# secondarynamenode is option for availability
#update-rc.d hadoop-0.20-secondarynamenode defaults
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
chown hdfs:hadoop $LOCAL_DISK/cache
chmod 777 $LOCAL_DISK/cache

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
