#!/bin/bash
. helpers.sh
cd $(dirname $(realpath $0))
export IFS=' '

makeDeamon() {
  ipfs init -e -p randomports >/dev/null || (echo "ipfs init failed"; rm -rf ${IPFS_PATH}; exit 1)
  jq -c --arg a "/ip4/127.0.0.1/tcp/12234" '.Addresses.API = $a' ${IPFS_PATH}/config | jq -c --arg a "/ip4/127.0.0.1/tcp/12235" '.Addresses.Gateway = $a' > ${IPFS_PATH}/config.new
  mv ${IPFS_PATH}/config{.new,}
  ipfs daemon &>>"logs/${now}/deamon-add.log" &
  # Wait for the deamon start
  sleep 1
  while [[ ! $(ipfs swarm peers > /dev/null; echo ${?}) ]]; do sleep 1; done
}

stopDeamon() {
  ipfs shutdown
  rm -rf ${IPFS_PATH}
}

TZ='UTC' export now=$(date +%s)

mkdir -p secrets data "logs/${now}" tasks

# Spawn new tasks
export IPFS_PATH=$(mktemp -d --suffix=.IFPS-PSR)
makeDeamon
bash -c "cd secrets/; ls *.sh" | parallel --joblog - "bash -c './mktask.sh {} &> \"logs/${now}/{}-newTask.log\"'" | tail -n+2 | porcelain | while read jobresult; do
  jobresult=(${jobresult})
  taskname=$(basename ${jobresult[11]} .sh)
  exitcode=${jobresult[6]}
  [[ ${exitcode} != "0" ]] &&
    echo "New task ${taskname} failed with error code: ${exitcode}" ||
    echo "New task ${taskname} finished correctly."
done
stopDeamon

# Execute tasks
#makeDeamon
#bash -c "cd tasks/; ls *.sh" | parallel --joblog - "bash -c './exectask.sh {} &> \"logs/${now}/{}.log\"'" | tail -n+2 | porcelain | while read jobresult; do
#  jobresult=(${jobresult})
#  echo "${jobresult[11]}"
#done
#stopDeamon
