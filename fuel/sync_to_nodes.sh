#!/bin/bash

if [ -z "$1" ] ; then
  echo "Please provide env ID as argument"
  echo "Listing all nodes and envs:"
  fuel node
  exit 1
fi
env_id=$1

function sync_node {
  id="${1%:*}"
  ip="${1#*:}"
  echo "Uploading modules to node-$id"
  rsync -a --delete /etc/puppet/modules/ $ip:/etc/puppet/modules/
  echo "Uploading manifests to node-$id"
  rsync -a --delete /etc/puppet/manifests/ $ip:/etc/puppet/manifests/
  if [ -d "/root/deployment_$env_id" ] ; then
    echo "Uploading astute.yaml to node-$id"
    rsync /root/deployment_$env_id/*_$id.yaml $ip:/etc/astute.yaml
  fi
}

for i in `fuel node --env $env_id | grep True | awk '{print $1":"$10}'`; do
  sync_node $i
done

