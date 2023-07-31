#!/bin/bash
subsys=$1
cfs cat config/$subsys/Limits/defaultInitial.properties | awk -F "/" '{print $1"/"$2}' | uniq | xargs -n 1 ./chanLims_2.sh | tee $subsys.dat
