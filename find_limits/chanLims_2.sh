#!/bin/bash
chan=$1
#echo $chan
#200000
~/yupy ~/stutils/trender.py --text --start "Jun 23 00:00:00 PDT 2023" --duration 200000 --timebins 25 -- $chan | awk 'BEGIN{mn=1.0e+36;mx=-1.0e+36; nvals=0; sum=0.0; sumsq=0.0} /\//{mx=($2>mx?$2:mx); mn=($2<mn?$2:mn); sum=sum+$2; sumsq=sumsq+$2*$2; nvals=nvals+1} END{sqarg=(sumsq-(sum*sum)/nvals)/(nvals-1);print $(NF-1),mn,mx,sum,sumsq,nvals,sqrt((sqarg>0)*sqarg)}'
