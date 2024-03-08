#!/bin/bash
export LSST_TAG=w_2024_08
lsstsw_root=/sdf/group/rubin/sw
source ${lsstsw_root}/loadLSST.bash
setup -v lsst_distrib -t ${LSST_TAG}

# Loop for a long time, executing "allocateNodes auto" every 10 minutes.
for i in {1..500}
do
    allocateNodes.py --auto --account rubin:developers -n 200 -m 4-00:00:00 -q milano -g 240 s3df
#    allocateNodes.py --auto --account rubin:developers -n 200 -m 4-00:00:00 -q milano,roma -g 240 s3df
    sleep 60
done
