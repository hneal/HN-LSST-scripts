#!/bin/bash
if [ -z "$1" ]
then
    MAXNODES=576  # x 15 cores/node = 8640 cores (= 72 nodes x 120 cores/node)
else
    MAXNODES=$1
fi

# Loop for a long time, executing "allocateNodes auto" every 5 minutes.
for i in {1..500}
do
    allocateNodes.py --auto -c 15 --account rubin:production -n ${MAXNODES} -m 1-00:00:00 -q milano -g 240 s3df
    sleep 120
done
