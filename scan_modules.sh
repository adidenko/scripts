#!/bin/bash
# Be careful, github ratelimits requests to API
# Using this script to often may lead to temporary blocking
# of your IP on github API side

for i in */Modulefile ; do
  if grep ^source $i | grep -q '://' ; then
    module=`echo $i | cut -d/ -f1`
    uri=`grep ^source $i | grep '://' | awk '{print $2}' | sed -e 's#^.*://github.com/##' -e "s#'##" -e 's#\.git$##'`
    latest=`curl -s https://api.github.com/repos/$uri/tags | head -n 10 | grep name | awk '{print $2}' | sed -e 's#"##g' -e 's#,##'`
    #echo "$module https://api.github.com/repos/$uri/tags"
    echo "$module $latest"
  fi
done
