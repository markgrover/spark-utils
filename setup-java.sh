#!/bin/bash -x
. cluster_properties.sh
for host in ${DEFAULT_HOSTNAMES[@]}; do
 ssh root@$host "echo 'export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera' >> ~/.bashrc"
done
