#!/bin/bash
# ---------------
# genLimsForSubSys - get limit channels for $subsys using the existing $props properties and then pass that on to chanLims_2 which uses trender to get channel characteristics for generating new limits 
# ---------------
subsys=$1
props=$2
cfs cat config/$subsys/Limits/$props.properties | grep -v "^#" | awk '{print $1}' | sed 's/\/limit..//' | sed 's/\/warn..//' | uniq | xargs -n 1 ./chanLims_2.sh | tee $subsys.dat
