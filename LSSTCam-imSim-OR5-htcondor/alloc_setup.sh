#!/bin/bash
#export LSST_TAG=w_2025_08
#lsstsw_root=/sdf/group/rubin/sw
#source ${lsstsw_root}/loadLSST.bash
#setup -v lsst_distrib -t ${LSST_TAG}

# Loop for a long time, executing allocateNodes repeatedly
for i in {1..10000}
do
#    allocateNodes.py --auto --account rubin:production -n 15 -c 16 -m 4-00:00:00 -q milano -g 60 s3df
#    allocateNodes.py --auto --account rubin:developers -n 15 -c 16 -m 4-00:00:00 -q milano -g 60 s3df
#    allocateNodes.py --auto --account rubin:developers -n 15 -m 1-00:00:00 -q milano -g 240 s3df
    allocateNodes.py --account rubin:production --auto -n 500 -m 1-00:00:00 -q milano -g 240 s3df
    # -maxjobs 1500
#    allocateNodes.py --auto --account rubin:developers -n 200 -m 4-00:00:00 -q milano -g 240 s3df
#    allocateNodes.py --auto --account rubin:developers -n 200 -m 4-00:00:00 -q milano,roma -g 240 s3df
    sleep 120
done
