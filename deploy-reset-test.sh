#!/bin/bash
# 5 controllers, 1 compute, HA
num=6
env=1
while true; do

  # Wait for nodes to discover
  discovered=0
  while [[ $discovered -lt $num ]] ; do
    sleep 31
    discovered=`fuel node | grep discover | grep True | wc -l`
  done
  echo "Ready to deploy at `date`" >> out.txt

  # Deploy
  if [[ $discovered -eq $num ]] ; then
    echo "Deployment started at `date`" >> out.txt
    fuel deploy-changes --env $env
  fi

  # Wait for deployment to complete
  ready=`fuel nodes | grep -e ready -e error | wc -l`
  while [[ $ready -lt $num ]]  ; do
    sleep 32
    ready=`fuel nodes | grep -e ready -e error | wc -l`
  done
  echo "Deployment complete at `date`" >> out.txt
  sleep 5

  # Gather info
  cid=`fuel node | grep controller | head -n1 | awk '{print $1}'`
  ssh node-$cid "pcs constraint list" 2>&1 | tee -a out.txt
  ssh node-$cid "rabbitmqctl cluster_status" 2>&1 | tee -a out.txt
  ssh node-$cid "rabbitmqctl list_users" 2>&1 | tee -a out.txt
  sleep 5

  # Reset env
  echo "Reset started at `date`" >> out.txt
  fuel reset --env $env
  while fuel task | grep reset_environment | grep running ; do
    sleep 33
  done
  echo "Reset complete at `date`" >> out.txt

done
