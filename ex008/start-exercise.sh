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

../kubectl delete ns $TASK  > /dev/null 2>&1 > /dev/null || true
../kubectl create ns $TASK > /dev/null

cat << EOF > task.txt

Q8: Create a deployment with 3 replicas and upgrade by using rolling update

- deployment name: $DEPLOYMENT
- image: $IMAGE1
- upgrade image: $IMAGE2

Ensure the pod is running.
Use namespace '${TASK}'.

Call the script '$BASEDIR/verify-result.sh' when done

EOF
clear
cat task.txt
take-down-time $BASEDIR
bash --rcfile <(cat $CKA_BASEDIR/.env $CKA_BASEDIR/set-env.sh set-env.sh)
../90-teardown.sh
