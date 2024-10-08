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
kubectl run $POD --image=nginx

cat << EOF > task.txt

Q7 you can find a pod named $POD in the default namespace, please check the status of the pod and troubleshoot, you can recreate the pod if you want 

Pod: $POD

EOF
clear
cat task.txt
take-down-time $BASEDIR
bash --rcfile <(cat $CKA_BASEDIR/.env $CKA_BASEDIR/set-env.sh set-env.sh)
