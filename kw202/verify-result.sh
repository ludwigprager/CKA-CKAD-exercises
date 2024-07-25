#!/usr/bin/env bash

set -u

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CKA_BASEDIR=${BASEDIR}/..

source $BASEDIR/set-env.sh
source $CKA_BASEDIR/set-env.sh
source $CKA_BASEDIR/functions.sh


error=false
message=

run=$( kubectl get svc $SERVICE -o jsonpath='{.spec.selector.run}' )


if [[ "$run" != "nginxpod" ]]; then
  error=true
  echo "service doesn't expose nginxpod"
fi

kubectl exec -ti $TESTPOD -- sh -c "curl --fail -s --connect-timeout 2 $SERVICE:$PORT > /dev/null"
if [[ $? -ne 0 ]]; then
  echo $SERVICE could not be reached on port $PORT
  error=true
fi



if [ "$error" = true ] ; then

cat << EOF
FAILED
$message

suggested solution:

kubectl expose pod nginxpod --name nginxsvc --port $PORT

EOF

else
  echo PASSED
  print-elapsed-time $BASEDIR
fi
