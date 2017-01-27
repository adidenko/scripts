#!/bin/bash

function get_ns(){
  awk '/^nameserver/{print $2}' /etc/resolv.conf
}

function test_tcp(){
  echo -n "Checking tcp to $1:$2 ... "
  timeout -t $3 bash -c "cat < /dev/null > /dev/tcp/$1/$2 && echo OK" || echo ERR
}

function test_dns(){
  nslookup $2 $1
}

dns=$(get_ns)
while : ; do
  echo
  date +"%Y-%m-%d %T"
  test_tcp $dns 53 1
  test_dns $dns nginxsvc
  test_tcp nginxsvc 80 1
  sleep 1
done
