#!/bin/bash
subsys=$1
props=$2
#cfs cat config/$subsys/Limits/$props.properties | awk -F "/" '{print $1"/"$2}' | uniq | xargs -n 1 ./chanLims_2.sh | tee $subsys.dat
cfs cat config/RebPowerSupply/Limits/rebpower.properties | grep -v "^#" | awk '{print $1}' | sed 's/\/limit..//' | sed 's/\/warn..//' | uniq | xargs -n 1 ./chanLims_2.sh | tee $subsys.dat
