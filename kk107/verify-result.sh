#!/usr/bin/env bash

set -u

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CKA_BASEDIR=${BASEDIR}/..

source $BASEDIR/set-env.sh
source $CKA_BASEDIR/set-env.sh
source $CKA_BASEDIR/functions.sh


error=false
message=

# test deployment exists
pod=$(kubectl get pod -n ${NAMESPACE} ${POD} -o jsonpath='{.metadata.name}')
if [[ $pod != ${POD} ]]; then
  error=true
  echo "pod ${POD} not found in namespace ${NAMESPACE}"
fi

## test ready replicas
#ready=$(kubectl get deployment ${DEPLOYMENT} -o jsonpath='{.status.readyReplicas}')
#if [[ ! $ready -eq 2 ]]; then
#  error=true
#  echo "replicas not ready"
#fi

if [ "$error" = true ] ; then

cat << EOF
FAILED
$message

suggested solution:

kubectl create namespace ${NAMESPACE}
kubectl run pod ${POD} --image ${IMAGE} -n ${NAMESPACE}


EOF

else
  echo PASSED
  print-elapsed-time $BASEDIR
fi

