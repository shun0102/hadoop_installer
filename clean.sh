LOCAL_DISK="/data/local/hadoop"

for service in /etc/init.d/hadoop-0.20*; do sudo $service stop; done
rm -rf $LOCAL_DISK
rm -rf /var/log/hadoop-0.20
rm -rf /etc/hadoop-0.20/conf.cluster

apt-get --purge -y remove hadoop*
