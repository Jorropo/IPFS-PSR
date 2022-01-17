#!/bin/bash

pinCID() {
  r=$(ipfs dag export ${1} | curl -s -X POST -H "Authorization: Bearer ${key}" -H "Content-Type: application/car" --data-binary @- "${api}/car")
  [[ "${1}" != $(normaliseCID $(echo ${r} | jq .cid -r)) ]] && (echo "Failed to pin, response:"; echo ${r} | jq .; return 1)
  return 0
}
