#!/bin/bash
# --------------------------------------------------------
# chanLims2.sh - get the trender stats for a channel
# --------------------------------------------------------

chan=$1
start="Jun 23 00:00:00 PDT 2023"
dur="2d"
#echo $chan

python ~/mutils/trendutils/trender.py --stats --start "$start" --duration $dur  -- $chan | awk '!/#/{print $(NF-1),$5,$6,$2,-1,$1,$4}'







# --------------------- legacy reference information ----------------------------------------------------------
# testing only ---------------------------
#echo ~/yupy ~/stutils/trender.py --text --start "Jun 23 00:00:00 PDT 2023" --duration 200000 --timebins 25 -- $chan

# local stats -------------------------------
#~/yupy ~/stutils/trender.py --text --start "Jun 23 00:00:00 PDT 2023" --duration 200000 --timebins 25 -- $chan | awk 'BEGIN{mn=1.0e+36;mx=-1.0e+36; nvals=0; sum=0.0; sumsq=0.0} /\//{mx=($2>mx?$2:mx); mn=($2<mn?$2:mn); sum=sum+$2; sumsq=sumsq+$2*$2; nvals=nvals+1} END{sqarg=(sumsq-(sum*sum)/nvals)/(nvals-1);print $(NF-1),mn,mx,sum,sumsq,nvals,sqrt((sqarg>0)*sqarg)}'

# trender stats --------------------------
#
# -- stats output example
# [homer@lsst-it01 find_limits]$ /home/homer/yupy /home/homer/stutils/trender.py --stats --start "Jun 23 00:00:00 PDT 2023" --duration 200000 -- R02/Reb1/analog/IbefLDO
#
# None
#
# CCS trending stats at 2023-08-04T09:48:16-07:00
# Data for 200000 total seconds from 1 intervals over 2 days, 7:33:20 (h:m:s) from:
#     tmin="2023-06-23T00:00:00-07:00"
#     tmax="2023-06-25T07:33:20-07:00"
#  cnt     mean   median   stddev      min      max    d/dt 1/m path                                      units
# 24656      612      630       28      565      634           0 rebpower/R02/Reb1/analog/IbefLDO             mA
