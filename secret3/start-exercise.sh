#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

CKA_BASEDIR=${BASEDIR}/..

source set-env.sh
source ../set-env.sh
source ../functions.sh

../10-prepare.sh
source ../.env

function finish {
  $CKA_BASEDIR/90-teardown.sh
}
trap finish INT TERM EXIT

echo "Preparing the environment ..."


cat << EOF > task.txt

Q3: Create a secret called $SECRET with key $KEY=$VALUE

    Create an nginx pod $POD that mounts the secret $SECRET as env variable $VARIABLE

Secret: $SECRET
Key: $KEY
Value: $VALUE
Pod: $POD
env Variable: $VARIABLE


(from: https://github.com/dgkanatsios/CKAD-exercises/blob/main/d.configuration.md#secrets )


EOF

cat task.txt

take-down-time $BASEDIR
bash --rcfile <(cat $CKA_BASEDIR/.env $CKA_BASEDIR/set-env.sh set-env.sh)
#../90-teardown.sh
