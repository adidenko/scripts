#!/bin/bash

# formatting
MR=20
CR=10
LR=10

if ! [ -f "$1" ] ; then
  echo "Provide a file with list of modules/versions as argument"
  exit 1
fi

printf "%-${MR}s%-${CR}s %s\n" "MODULE" "CURRENT" "LATEST"
printf "%-${MR}s%-${CR}s %s\n" "------" "-------" "------"
for i in `awk '{print $1}' $1`; do
  current=`grep ^version $i/Modulefile | awk '{print $2}' | sed -e "s#'##g"`
  latest=`grep ^$i $1 | awk '{print $2}'`
  printf "%-${MR}s" "$i"
  printf "%-${CR}s %s\n" "$current" "$latest"
done
