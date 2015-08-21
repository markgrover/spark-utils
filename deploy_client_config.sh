#!/bin/bash -xe
DEFAULT_HOSTNAMES=($(echo mgrover-haa3-{1..4}.vpc.cloudera.com))

TEMP_SCRIPT=$(mktemp)
cat > $TEMP_SCRIPT << EOF
cd /etc/spark/conf
sed -e "s#^export SPARK_HOME=.*#export SPARK_HOME=/root/spark#" spark-env.sh > spark-env.sh
sed -e "s#spark.yarn.jar=.*#spark.yarn.jar=local:/root/spark/lib/spark-assembly.jar#" spark-defaults.conf > spark-defaults.conf
cd -
EOF

chmod 700 $TEMP_SCRIPT

if [ $# -eq 0 ]; then
 HOSTS=${DEFAULT_HOSTNAMES[@]}
else
 HOSTS=$@
fi

for host in $HOSTS; do
  if [ $host != $HOSTNAME ]; then
    scp $TEMP_SCRIPT root@$host:$TEMP_SCRIPT
    ssh root@$host "$TEMP_SCRIPT"
  else
    $TEMP_SCRIPT
  fi
done
