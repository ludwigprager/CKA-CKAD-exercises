#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR
CKA_BASEDIR=${BASEDIR}/..

source ./set-env.sh
source ../set-env.sh
source ../functions.sh
function finish {
  $CKA_BASEDIR/90-teardown.sh
}
trap finish INT TERM EXIT
../10-prepare.sh
source ../.env

echo "Preparing the environment ..."

# setup

kubectl delete ns $TASK  > /dev/null 2>&1  || true
kubectl create ns $TASK > /dev/null || true


#export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)

docker exec -ti cncf-$(whoami)-control-plane \
  curl -L -O https://github.com/etcd-io/etcd/releases/download/v3.5.14/etcd-v3.5.14-linux-amd64.tar.gz > /dev/null 2>&1
#kubectl node-shell cncf-$(whoami)-control-plane -- \
docker exec -ti cncf-$(whoami)-control-plane \
  tar zxvf etcd-v3.5.14-linux-amd64.tar.gz > /dev/null 2>&1
#kubectl node-shell cncf-$(whoami)-control-plane -- \
#  chmod +x etcd-v3.5.14-linux-amd64/\* > /dev/null 2>&1
#kubectl node-shell cncf-$(whoami)-control-plane -- \
docker exec -ti cncf-$(whoami)-control-plane \
  cp etcd-v3.5.14-linux-amd64/etcdctl /usr/local/bin > /dev/null 2>&1

#kubectl node-shell cncf-$(whoami)-control-plane -- \
docker exec -ti cncf-$(whoami)-control-plane \
  sh -c "ETCDCTL_API=3 etcdctl \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save $BACKUP \
  "

cat << EOF > task.txt

Q0302: Restore ETCD using the backup file in $BACKUP
into directory $DATA_DIR

hint: use 'docker exec -ti <node name> bash' to log on to a node

EOF
clear
cat task.txt
take-down-time $BASEDIR
bash --rcfile <(cat $CKA_BASEDIR/.env $CKA_BASEDIR/set-env.sh set-env.sh)
../90-teardown.sh
