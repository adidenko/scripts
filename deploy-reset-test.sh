#!/bin/bash
# 5 controllers, 1 compute, HA
controllers=5
computes=1
env=1

if [[ "$1" != "" ]] ; then
  if ! [[ -f "$1" ]] ; then
    echo "$1 file not found"
    exit 1
  fi
  echo
  deployments=`grep 'Deployment complete' $1  | wc -l`
  echo "Deployments completed: $deployments"
  res_enabled=`grep -A $controllers Resource: $1 | grep Enabled | wc -l`
  res_total=`grep Resource: $1 | wc -l`

  echo
  echo "==== Constraints ===="
  echo Resources: $res_total
  echo "Enabled on nodes:  $res_enabled"
  res_should_be_enabled=$(( res_total * controllers ))
  echo "Should be enabled: $res_should_be_enabled"
  if [[ $res_enabled -eq $res_should_be_enabled ]] ; then
    echo "Result: OK"
  else
    echo "Result: Error. Please check $1 log for details"
  fi
  echo

  echo "==== RabbitMQ ===="
  echo

  echo "Checking cluster nodes"
  for cid in `fuel node | grep controller | awk '{print $1}'` ; do
    cnum=`awk '/{nodes,\[/{flag=1}/{running_nodes/{flag=0}flag' $1 | grep -o node-$cid | wc -l`
    if [[ $cnum -eq $deployments ]] ; then
      echo "node-$cid: OK ($cnum)"
    else
      echo "node-$cid: ERROR ($cnum, but should be $deployments)"
    fi
  done

  echo
  echo "Checking running nodes"
  for cid in `fuel node | grep controller | awk '{print $1}'` ; do
    cnum=`awk '/running_nodes,\[/{flag=1}/{cluster_name,/{flag=0}flag' $1 | grep -o node-$cid | wc -l`
    if [[ $cnum -eq $deployments ]] ; then
      echo "node-$cid: OK ($cnum)"
    else
      echo "node-$cid: ERROR ($cnum, but should be $deployments)"
    fi
  done

  echo
  if grep partitions $1 | grep -v 'partitions,\[\]' ; then
    echo "ERROR: Partitions found"
  else
    echo "Partitions OK"
  fi
  echo
  exit 0
fi

num=$(( controllers + computes ))
# Now lets deploy openstack forever :-)
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
