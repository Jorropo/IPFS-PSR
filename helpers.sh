#!/bin/bash

porcelain() {
  awk '{$1=$1};1'
}

normaliseCID() {
  ipfs cid format -v 1 -b base32 ${1}
}
