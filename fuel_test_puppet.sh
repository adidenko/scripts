#!/bin/bash

YAML_URL_BASE="https://raw.githubusercontent.com/adidenko/scripts/master/fuel-yaml/5.1"
YAMLS="
ha_neut_vlan_cei.compute
ha_neut_vlan_cei.controller
ha_neut_vlan_cei.primary-controller
ha_neut_vlan_sah_mur_cei.cinder
ha_neut_vlan_sah_mur_cei.compute
ha_neut_vlan_sah_mur_cei.controller
ha_neut_vlan_sah_mur_cei.primary-controller
simple_neut_gre_ceph_sah_mur_cei.ceph-osd
simple_neut_gre_ceph_sah_mur_cei.compute
simple_neut_gre_ceph_sah_mur_cei.controller
simple_neut_gre_ceph_sah_mur_cei.primary-mongo
simple_nova_flat_cei.cinder
simple_nova_flat_cei.compute
simple_nova_flat_cei.controller
"

echo
printf "%-60s%-10s %s\n" "YAML EXAMPLE" "RESULT" "LOGFILE"
for YAML in $YAMLS ; do
    printf "%-60s" "Running $YAML ..."
    curl -s "$YAML_URL_BASE/$YAML" > /etc/fuel/astute.yaml
    ( FACTER_hostname=`awk '/^fqdn:/{print $2}' /etc/fuel/astute.yaml | cut -d. -f1` puppet apply -d -v --modulepath /tmp/modules/upstream:/tmp/modules/fuel-library/deployment/puppet --noop /tmp/modules/fuel-library/deployment/puppet/osnailyfacter/examples/site.pp ; echo Exit code: $? ; echo ) &> /tmp/modules/puppet-apply.${YAML}.log
    if grep -q 'Exit code: 0' /tmp/modules/puppet-apply.${YAML}.log ; then
        printf "%-10s %s\n" "OK" "/tmp/modules/puppet-apply.${YAML}.log"
    else
        printf "%-10s %s\n" "FAILED" "/tmp/modules/puppet-apply.${YAML}.log"
    fi
done
