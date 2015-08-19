#!/bin/bash -x
DEFAULT_TARBALL_NAME=spark-1.5.0-SNAPSHOT-bin-nm.tgz
# Must have password less SSH setup between all nodes of the cluster. In particular
# it needs to be setup from the node where this script is going to run to all other
# nodes of the cluster. This is only O(n) connections, other connections are not required
DEFAULT_HOSTNAMES=($(echo mgrover-haa3-{1..4}.vpc.cloudera.com))

if [ -n "$1" ]; then
  TARBALL_NAME=$1
else
  TARBALL_NAME=$DEFAULT_TARBALL_NAME
fi

TEMP_SCRIPT=$(mktemp)
cat > $TEMP_SCRIPT << EOF
rm -rf ~/spark-*/
cd ~
tar -xzvf $TARBALL_NAME
SPARK_DIR=\$(ls -d spark-*/)
cd \$SPARK_DIR
rm -rf conf
ln -s /etc/spark/conf conf
cd ..
EOF
chmod 700 $TEMP_SCRIPT

if [ $# -eq 0 ]; then
 HOSTS=${DEFAULT_HOSTNAMES[@]}
else
 HOSTS=$@
fi

for host in $HOSTS; do
  if [ $host != $HOSTNAME ]; then
    scp $TARBALL_NAME root@$host:~
    scp $TEMP_SCRIPT root@$host:~
    ssh root@$host '$TEMP_SCRIPT'
  else
    $TEMP_SCRIPT
  fi
done
