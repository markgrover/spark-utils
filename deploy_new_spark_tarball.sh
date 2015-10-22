#!/bin/bash -xe
# * Must scp the tarball to one of the nodes of the cluster (can be any node)
# * Must also scp this script to the same node.
# * It's assumed that both this tarball and the script are present in the home directory
# * The first optional parameter to this script is the name of the spark tarball
# * The rest of the arguments to the script are the names of all of the nodes in the cluster
# e.g. mynodes-{1..4}.mycompany.com 
# * Must have password less SSH setup between all nodes of the cluster. In particular
# it needs to be setup from the node where this script is going to run to all other
# nodes of the cluster. This is only O(n) connections, other connections are not required

. cluster_properties.sh
if [ -n "$1" ]; then
  TARBALL_NAME=$1
else
  TARBALL_NAME=$DEFAULT_TARBALL_NAME
fi

TEMP_SCRIPT=$(mktemp)
cat > $TEMP_SCRIPT << EOF
cd ~
SPARK_DIR=spark
rm -rf \$SPARK_DIR || :
mkdir \$SPARK_DIR 
tar -C spark --strip-components=1 -xzvf $TARBALL_NAME
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
    scp $TEMP_SCRIPT root@$host:$TEMP_SCRIPT
    ssh root@$host "$TEMP_SCRIPT"
  else
    $TEMP_SCRIPT
  fi
done
