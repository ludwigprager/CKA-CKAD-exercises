#!/usr/bin/env bash

set -u

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CKA_BASEDIR=${BASEDIR}/..

source $BASEDIR/set-env.sh
source $BASEDIR/../set-env.sh
source $BASEDIR/../functions.sh


error=false

error=true

if [ "$error" = true ] ; then

cat << EOF
FAILED

- https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster
- read the path of the config.yaml specified in the kubelet's process '--config' parameter
- take note of the 'staticPodPath' field from the kubelet config.yaml. 

- update $.volumes.[?(@.name=='etc-data')].hostPath.path to $DATA_DIR


suggested solution:

# first, log on to the master:
docker exec -ti cncf-$(whoami)-control-plane bash

ps x | grep /usr/bin/kubelet | grep -o -- --config=[a-z,/]*
grep staticPodPath: /var/lib/kubelet/config.yaml

export ETCDCTL_API=3
etcdctl --data-dir $DATA_DIR snapshot restore $BACKUP

# update the pod
#sed -i 's|staticPodPath: /etc/kubernetes/manifests|staticPodPath: /var/lib/ex0302|' /etc/kubernetes/manifests/etcd.yaml
sed -i 's|path: /var/lib/etcd|path: $DATA_DIR|' /etc/kubernetes/manifests/etcd.yaml








EOF

else
  echo PASSED
  print-elapsed-time $BASEDIR
fi

