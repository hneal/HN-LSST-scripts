#!/bin/bash
# ---------------
# genLimsForSubSys - get limit channels for $subsys using the existing $props properties and then pass that on to chanLims_2 which uses trender to get channel characteristics for generating new limits 
# arguments:
# 1) sub system name on the bus
# 2) category name
# 3) properties name (defaultInitial, rebpower, ...)
# ---------------

if [ "$#" -ne 3 ]; then
  echo "Expected arguments: <subsys name on the bus>   <category name>   <properties name (defaultInitial, rebpower, ...)>" >&2
  exit 1
fi

subsys=$1
category=$2
props=$3
#ssh lsstcam-mcm
cfs cat config/$category/Limits/$props.properties > oldprops.temp
grep -v "^#" oldprops.temp | sed 's/=/ /' | awk '{print $1}' | sed 's/\/limit..//' | sed 's/\/warn..//' | uniq | xargs -n 1 --replace=CHAN ./chanLims_3.sh \^$1/CHAN\$ | tee $category.dat
