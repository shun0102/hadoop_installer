#!/bin/sh

TYPE=$1

if [ "$TYPE" = "" ];
then
  echo "usage ./install.sh master|slave|all"
  exit
fi

cp cloudera.list /etc/apt/sources.list.d/cloudera.list
curl -s http://archive.cloudera.com/debian/archive.key | apt-key add -

apt-get update
apt-cache search hadoop
if [ $TYPE = master ];
then
apt-get -y install hadoop-0.20-namenode
apt-get -y install hadoop-0.20-secondarynamenode
apt-get -y install hadoop-0.20-jobtracker
update-rc.d hadoop-0.20-namenode defaults
update-rc.d hadoop-0.20-secondarynamenode defaults
update-rc.d hadoop-0.20-jobtracker defaults

elif [ $TYPE = slave ];
then
apt-get -y install hadoop-0.20-datanode
apt-get -y install hadoop-0.20-tasktracker
update-rc.d hadoop-0.20-datanode defaults
update-rc.d hadoop-0.20-tasktracker defaults

else
apt-get -y install hadoop-0.20-namenode
apt-get -y install hadoop-0.20-secondarynamenode
apt-get -y install hadoop-0.20-jobtracker
apt-get -y install hadoop-0.20-datanode
apt-get -y install hadoop-0.20-tasktracker
update-rc.d hadoop-0.20-namenode defaults
update-rc.d hadoop-0.20-secondarynamenode defaults
update-rc.d hadoop-0.20-jobtracker defaults
update-rc.d hadoop-0.20-datanode defaults
update-rc.d hadoop-0.20-tasktracker defaults
fi

cp -r conf /etc/hadoop-0.20/conf.cluster
update-alternatives --install /etc/hadoop-0.20/conf hadoop-0.20-conf /etc/hadoop-0.20/conf.cluster 50
update-alternatives --set hadoop-0.20-conf /etc/hadoop-0.20/conf.cluster

DISK=/data/local
mkdir -p $DISK/hadoop

mkdir $DISK/hadoop/cache
chown root:root $DISK/hadoop/cache
chmod 1777 $DISK/hadoop/cache

if [ $TYPE = master ];
then
mkdir $DISK/hadoop/nn
chown hdfs:hadoop $DISK/hadoop/nn
chmod 700 $DISK/hadoop/nn

elif [ $TYPE = slave ];
then
mkdir $DISK/hadoop/dn
chown hdfs:hadoop $DISK/hadoop/dn
chmod 755 $DISK/hadoop/dn

else
mkdir $DISK/hadoop/nn
chown hdfs:hadoop $DISK/hadoop/nn
chmod 700 $DISK/hadoop/nn
mkdir $DISK/hadoop/dn
chown hdfs:hadoop $DISK/hadoop/dn
chmod 755 $DISK/hadoop/dn
fi

mkdir -p $DISK/hadoop/mapred/local
chown -R mapred:hadoop $DISK/hadoop/mapred
chmod -R 755 $DISK/hadoop/mapred

if [ $TYPE != slave ];
then
sudo -u hdfs hadoop namenode -format
fi
