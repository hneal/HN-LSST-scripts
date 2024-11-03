#!/bin/sh
# script for launching nightly
# -----------------------------------------
# subnightlystepbystep
# author: Homer for DM CM
# circa: Nov. 2024
#
#  Submit Nightly Validation pipeline processing step by step.
#
# optional arguments:
#   alternative obs_date: Ex. 20241028
#   alternative list of steps: "step2d step3a step3b step7"
# ------------------------------------------
subdir=/sdf/data/rubin/shared/campaigns/ComCam-Nightly-Validation

echo "setting up environment"
source ${subdir}/setup_cc.sh

cd ${subdir}

echo "setting date range"
export otherdate="$1"

if [[ ${otherdate} == "" ]]; then
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

echo "setting steps to process"
export steplist="step1 step2a step2b step2d step2e step3a step3b step7"

export usersteps="$2"
if [[ ${usersteps} != "" ]]; then
    export steplist="${usersteps}"
fi
echo "steps to process are: ${steplist}"

export DISTRIB=`eups list -s lsst_distrib | awk '{print $3}'`
echo "Using distribution: ${DISTRIB}"


export firststep=`echo ${steplist} | cut -d ' ' -f1,1`
echo "First step = ${firststep}"

for stepname in ${steplist}
do
    # if step1 submit it now
    if [[ ${stepname} == ${firststep} ]]; then
       echo "performing bps submission for step ${stepname}"
       export curlog=/sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-${stepname}-log 
       bps submit ${subdir}/hn_cc_nightly-${stepname}.yaml 2>&1 | tee ${curlog}
    else
	# periodically check bps submission progression and wait for finalJob to have run
	for iloop in $(seq 1 480);
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
		    echo "Collections exist for ${stepname}. Proceeding to submit next step."
		    export curlog=/sdf/home/l/lsstsvc1/sub-cc-nightly${NIGHTLY_START}-${stepname}-log 
		    bps submit ${subdir}/hn_cc_nightly-${stepname}.yaml 2>&1 | tee ${curlog}
		    echo "submit directory :"
		    grep "Submit dir" ${curlog}
		    break
		else
		    echo "Ending. Nothing for the next step to process :-("
		    exit
		fi
	    fi
	done
    fi
done

