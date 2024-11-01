#!/sin/sh
# script for launching nightly

subdir=/sdf/data/rubin/shared/campaigns/ComCam-Nightly-Validation

export sd=/sdf/home/l/lsstsvc1/submit/u/homer/DM-47059/d_2024_10_25/pipeline_test4_20241029/20241030T153554Z
bps report --id=${sd} | awk '/finalJob/{print $1,$10}'
fj="`bps report --id=${sd} | awk '/finalJob/{print $1,$10}' 2>&1`"
echo "finalJob status = ${fj}"



echo "setting up environment"
source ${subdir}/setup_cc.sh

echo "setting date range"
export otherdate="$1"

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
#bps submit ${subdir}/hn_cc_nightly-step1.yaml 2>&1 | tee /sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-step1-log

# periodically check bps submission progression and wait for finalJob to have run
for iloop in $(seq 1 20);
do
    sleep 30
    export sd=`grep "Submit dir" /sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-step1-log | cut -d " " -f 3,3`
    echo "sd = ${sd}"
    echo "bps report --id=${sd}"
    bps report --id=${sd} | awk '/finalJob/{print $1,$10}'
    export fj="`bps report --id=${sd} | awk '/finalJob/{print $10}'`"
    echo "finalJob status = ${fj}"
    if [[ ${fj} == "1" ]]; then
	export pf=`bps report --id=${sd} | awk '/transformPreSourceTable/{print $10}'`
	# check the number of jobs successfully run before finalJob to know whether step2 should be submitted
	if [[ ${pf} == "1" ]]; then
	    echo "Collections exist for step2. Proceeding to submit step2."
	    echo bps submit ${subdir}/hn_cc_nightly-step2plus.yaml 2>&1 | tee /sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-step2plus-log
	else
	    echo "Ending. Nothing for step2 to process :-("
	fi
	exit
    fi
	
	
done

echo "submit directory :"
grep "Submit dir" subnightly-log-${NIGHTLY_START}
