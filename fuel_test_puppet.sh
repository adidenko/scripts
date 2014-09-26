#!/bin/bash

mkdir -p /tmp/modules

if [ -z "$SITE_PP"] ; then
  SITE_PP="/zkskksjkdjd/dkldjdkjdkd/dkdkdjdkjd/dkdjdkjd"
fi

if [ -z "$MODULE_PATH" ] ; then
  MODULE_PATH='/tmp/modules/upstream:/tmp/modules/fuel-library/deployment/puppet'
fi

if [ -z "$YAML_URL_BASE"] ; then
  YAML_URL_BASE="https://raw.githubusercontent.com/adidenko/scripts/master/fuel-yaml/5.1"
fi

if [ -z "$YAMLS" ] ; then
YAMLS="
ha_neut_vlan_cei.compute.yaml
ha_neut_vlan_cei.controller.yaml
ha_neut_vlan_cei.primary-controller.yaml
ha_neut_vlan_sah_mur_cei.cinder.yaml
ha_neut_vlan_sah_mur_cei.compute.yaml
ha_neut_vlan_sah_mur_cei.controller.yaml
ha_neut_vlan_sah_mur_cei.primary-controller.yaml
simple_neut_gre_ceph_sah_mur_cei.ceph-osd.yaml
simple_neut_gre_ceph_sah_mur_cei.compute.yaml
simple_neut_gre_ceph_sah_mur_cei.controller.yaml
simple_neut_gre_ceph_sah_mur_cei.primary-mongo.yaml
simple_nova_flat_cei.cinder.yaml
simple_nova_flat_cei.compute.yaml
simple_nova_flat_cei.controller.yaml
"
fi

IFS=':' read -ra MARR <<< "$MODULE_PATH"
for i in "${MARR[@]}"; do
  if [ -f "$i/osnailyfacter/examples/site.pp" ] ; then
    SITE_PP="$i/osnailyfacter/examples/site.pp"
    break
  fi
done

if ! [ -f "$SITE_PP" ] ; then
  echo "No site.pp found in your MODULE_PATH"
  exit 1
fi

echo
printf "%-70s%-10s %s\n" "YAML EXAMPLE" "RESULT" "LOGFILE"
for YAML in $YAMLS ; do
    printf "%-70s" "Running $YAML ..."
    curl -s "$YAML_URL_BASE/$YAML" > /etc/fuel/astute.yaml
    ( FACTER_hostname=`awk '/^fqdn:/{print $2}' /etc/fuel/astute.yaml | cut -d. -f1` puppet apply -d -v --modulepath $MODULE_PATH --noop $SITE_PP ; echo Exit code: $? ; echo ) &> /tmp/modules/puppet-apply.${YAML}.log
    if grep -q 'Exit code: 0' /tmp/modules/puppet-apply.${YAML}.log ; then
        printf "%-10s %s\n" "OK" "/tmp/modules/puppet-apply.${YAML}.log"
    else
        printf "%-10s %s\n" "FAILED" "/tmp/modules/puppet-apply.${YAML}.log"
    fi
done
