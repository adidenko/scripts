#!/bin/bash
# export PYTHONPATH="./pylibs:./05_setup/environments"
# export FUEL_MASTER_NODE=10.108.0.2

set -e

envs="
simple_nova_flat_cei
simple_neut_gre_ceph_sah_mur_cei
ha_neut_vlan_cei
ha_neut_vlan_sah_mur_cei
"

mkdir -p yaml

function rename_yaml () {
  in=$1
  name=$2
  for file in ${in}*yaml ; do
    if [ -f "$file" ] ; then
      role=$(awk '/^role:/{print $2}' $file) && mv $file ${name}.${role}.yaml || true
    fi
  done
}

for env in $envs ; do
  # cleanup
  ssh root@$FUEL_MASTER_NODE rm -rf /root/deployment_*/

  # create env
  python manage_env.py $FUEL_MASTER_NODE $env create /dev/null

  # download yaml
  sleep 1
  ssh root@$FUEL_MASTER_NODE 'fuel deployment --default --env $(fuel node | grep controller | awk "{print \$8}")'
  sleep 1
  scp root@$FUEL_MASTER_NODE:~/deployment_*/*yaml yaml/

  # rename yamls
  pushd yaml
    rename_yaml cinder ${env}
    rename_yaml compute ${env}
    rename_yaml controller ${env}
    rename_yaml ceph-osd ${env}
    rename_yaml primary-mongo ${env}
    rename_yaml primary-controller ${env}
#    rename_yaml  ${env}
  popd

  python manage_env.py $FUEL_MASTER_NODE $env remove /dev/null

done

