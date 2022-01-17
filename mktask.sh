#!/bin/bash
. helpers.sh

[[ -z ${1} ]] && (echo "check expect one argument, <target name>"; exit 1)
tgt=$(basename ${1} .sh)

. "secrets/${tgt}.sh"
. "providers/${provider}.sh"

mkdir -p "data/${tgt}/${now}"

# Generate a random CID to test it with
cid=$(dd if=/dev/urandom bs=2048 count=1 status=none | ipfs add -Q --raw-leaves --cid-version 1 -)
[[ ${?} != "0" ]] && (echo "ipfs add failed"; exit 1)
export cid=$(normaliseCID ${cid})
[[ -z "${cid}" ]] && (echo "ipfs add failed, no cid"; exit 1)
echo "created cid: ${cid}"

pinCID ${cid} || (echo "error pinning the cid"; ipfs pin rm ${cid}; exit 1)

echo "successfully pinned ${cid}"

(echo -e "export cid='${cid}'\nexport secret='${tgt}'\nexport createdAt='${now}'") > "tasks/${now}_${tgt}.sh"
