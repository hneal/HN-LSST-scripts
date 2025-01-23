#!/bin/sh
# script for launching nightly

cd /sdf/home/h/homer/proc_comcam/

echo "setting up environment"
source setup_cc.sh

echo "setting date range"
export otherdate="$1"
#echo ${otherdate}

if [${otherdate} == ""]; then
  export NIGHTLY_START=`date -d '-1 day' '+%Y%m%d'`
  export NIGHTLY_END=`date +%Y%m%d`
  echo "NIGHTLY_START = ${NIGHTLY_START}"
  echo "NIGHTLY_END = ${NIGHTLY_END}"
else
# --- test ---
  export NIGHTLY_START=${otherdate}
  export NIGHTLY_END=`date -d${otherdate}+1day '+%Y%m%d'`
  echo "TEST: OVERRIDING NIGHTLY_START = ${NIGHTLY_START}"
  echo "TEST: OVERRIDING NIGHTLY_END = ${NIGHTLY_END}"
fi

echo "performing bps submission"
bps submit hn_cc_nightly.yaml 2>&1 | tee autotest-log-${NIGHTLY_START}

echo "submit directory :"
grep "Submit dir" autotest-log-${NIGHTLY_START}
