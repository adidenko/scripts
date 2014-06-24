#!/bin/bash

YAML_URL_BASE="https://raw.githubusercontent.com/adidenko/scripts/master/fuel-yaml/5.1"
YAMLS="
ceph-osd.node-2.test.domain.local.yaml
cinder.node-5.domain.tld.yaml
compute.node-4.domain.tld.yaml
controller.ceph.node-3.test.domain.local.yaml
controller.node-2.domain.tld.yaml
primary-controller.node-1.domain.tld.yaml
pull-request.controller.node-1.test.domain.local.yaml
pull-request.compute.node-3.test.domain.local.yaml
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
