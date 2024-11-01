#!/bin/sh
# script for launching nightly

subdir=/sdf/data/rubin/shared/campaigns/ComCam-Nightly-Validation

echo "setting up environment"
source ${subdir}/setup_cc.sh

echo "setting date range"
export otherdate="$1"

if [${otherdate} == ""]; then
  export NIGHTLY_START=`date -d '-1 day' '+%Y%m%d'`
  export NIGHTLY_END=`date -d '-1 day' '+%Y%m%d'`
#  export NIGHTLY_END=`date +%Y%m%d`
  echo "NIGHTLY_START = ${NIGHTLY_START}"
  echo "NIGHTLY_END = ${NIGHTLY_END}"
else
# --- test ---
  export NIGHTLY_START=${otherdate}
  export NIGHTLY_END=${otherdate}
#  export NIGHTLY_END=`date -d${otherdate}+1day '+%Y%m%d'`
  echo "TEST: OVERRIDING NIGHTLY_START = ${NIGHTLY_START}"
  echo "TEST: OVERRIDING NIGHTLY_END = ${NIGHTLY_END}"
fi

#echo "performing bps submission"
#bps submit ${subdir}/hn_cc_nightly-step1.yaml 2>&1 | tee /sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-step1-log

for stepname in step1 step2a step2b step2d step2e step3 step7
do
    # if step1 submit it now
    if [[ ${stepname} == "step1" ]]; then
       echo "performing bps submission"
       export curlog=/sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-${stepname}-log 
       bps submit ${subdir}/hn_cc_nightly-${stepname}.yaml 2>&1 | tee ${curlog}
    else
	# periodically check bps submission progression and wait for finalJob to have run
	for iloop in $(seq 1 100);
	do
	    sleep 30
	    export sd=`grep "Submit dir" ${curlog} | cut -d " " -f 3,3`
	    echo "Retrieving finalJob status using: bps report --id=${sd}"
	    export fj="`bps report --id=${sd} | awk '/finalJob/{print $10}'`"
	    echo "finalJob status = ${fj}"
	    if [[ ${fj} == "1" ]]; then
		export pf=`bps report --id=${sd} | grep -B 1 "^finalJob" | head -1  | awk '{print $10}'`
		# check the number of jobs successfully run before finalJob to know whether the next step should be submitted
		if [[ ${pf} != "0" ]]; then
		    echo "Collections exist for step2. Proceeding to submit next step."
		    bps submit ${subdir}/hn_cc_nightly-${stepname}.yaml 2>&1 | tee /sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-${stepname}-log
		    break
		else
		    echo "Ending. Nothing for the next step to process :-("
		    exit
		fi
	    fi
	done
    fi
done

echo "submit directory :"
grep "Submit dir" subnightly-log-${NIGHTLY_START}
