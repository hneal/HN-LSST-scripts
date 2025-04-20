#!/bin/sh
# script for launching nightly
# -----------------------------------------
# subnightlystepbystep
# author: Homer for DM CM
# circa: Feb. 2025
#
#  Submit Nightly Validation pipeline processing step by step.
#
# optional arguments:
#   alternative obs_date: Ex. 20241028
#   alternative list of steps: "step2d step3a step3b step7"
# ------------------------------------------
#subdir=/sdf/data/rubin/shared/campaigns/LSSTCam-Nightly-Validation
subdir=/sdf/home/h/homer/LSSTCam-Nightly-Validation

echo "setting up environment"
source ${subdir}/setup_lsstcam.sh

cd ${subdir}

echo "setting date range"
export otherdate="$1"

if [[ ${otherdate} == "ALL" ]]; then
    export NIGHTLY_START="0"
    export NIGHTLY_END="0"
    export SASQ_TIMESTAMP="20220101"
    echo "NIGHTLY_START = ${NIGHTLY_START}"
    echo "NIGHTLY_END = ${NIGHTLY_END}"
else
    if [[ ${otherdate} == "" ]]; then
	export NIGHTLY_START=`date -d '-1 day' '+%Y%m%d'`
	export NIGHTLY_END=`date -d '-1 day' '+%Y%m%d'`
#  export NIGHTLY_END=`date +%Y%m%d`
	echo "NIGHTLY_START = ${NIGHTLY_START}"
	echo "NIGHTLY_END = ${NIGHTLY_END}"
	export SASQ_TIMESTAMP=`date +%Y%m%d`
    else
# --- test ---
	export NIGHTLY_START=${otherdate}
	export NIGHTLY_END=${otherdate}
#  export NIGHTLY_END=`date -d${otherdate}+1day '+%Y%m%d'`
	echo "TEST: OVERRIDING NIGHTLY_START = ${NIGHTLY_START}"
	echo "TEST: OVERRIDING NIGHTLY_END = ${NIGHTLY_END}"
	export SASQ_TIMESTAMP=`date -d${otherdate}+1day '+%Y%m%d'`
    fi
fi

echo "setting steps to process"
export steplist="step1 step2 step3 step4 step7"

export usersteps="$2"
if [[ ${usersteps} != "" ]]; then
    export steplist="${usersteps}"
fi
echo "steps to process are: ${steplist}"

export DISTRIB=`eups list -s lsst_distrib | awk '{print $2}'`
echo "Using distribution: ${DISTRIB}"


export firststep=`echo ${steplist} | cut -d ' ' -f1,1`
echo "First step = ${firststep}"

export fj="INIT"

export ostepname=""

for stepname in ${steplist}
do
  export grplist=`ls bps_configs_test/bps_NV_${stepname}_day1*.yaml | sed -z "s/\n/ /g"`
  # if first step submit it now
  if [[ ${stepname} == ${firststep} ]]; then
    for bpsyaml in ${grplist}
    do		     

       export bynoext=`echo ${bpsyaml} | cut -d '/' -f 2,2 | cut -d '.' -f 1,1`
       echo "performing bps submission for step ${stepname} - yaml ${bynoext} "
       export curlog=/sdf/home/h/homer/LSSTCam-Nightly-Validation/bps_sub_logs/${stepname}/${bynoext}-log 

# comment out to recover from first step timeout
#hn       bps submit ${subdir}/${bpsyaml} 2>&1 | tee ${curlog}

    done
  else
        export grplist=`ls bps_configs_test/bps_NV_${stepname}_day1*.yaml | sed -z "s/\n/ /g"`
	# periodically check bps submission progression and wait for finalJob to have run
	for iloop in $(seq 1 2880);
	do
	    sleep 30

	    export fini=1
	    for bpsyaml in ${ogrplist}
	    do		     
		export bynoext=`echo ${bpsyaml} | cut -d '/' -f 2,2 | cut -d '.' -f 1,1`
#		echo "performing bps submission for step ${stepname} - yaml ${bynoext} "
		export curlog=/sdf/home/h/homer/LSSTCam-Nightly-Validation/bps_sub_logs/${ostepname}/${bynoext}-log 
		export sd=`grep "Submit dir" ${curlog} | cut -d " " -f 3,3`
		export fj=`awk /finalJob/'{getline stat;split(stat,dsc,"\"");print ( (match(dsc[2],"DONE") == 0) ? ( (match(dsc[2],"ERROR") == 0) ? 0 : 2) : 1) }' ${sd}/*.node_status`
		echo "finalJob status for ${bynoext} = ${fj}"
		if [[ ${fj} == "0" ]]; then
		    export fini=0
		fi
	    done
	    
	    if [[ ${fini} == "0" ]]; then
		echo "still waiting for all jobs to finish"
	    else
		echo "all done ... proceeding to next step"
	    fi
	    
	    if [[ ${fini} == "1" ]]; then

		# check the number of jobs successfully run before finalJob to know whether the next step should be submitted
# skipping check for now
		export pf=1
		if [[ ${pf} != "0" ]]; then
		    for bpsyaml in ${grplist}
		    do		     
			export bynoext=`echo ${bpsyaml} | cut -d '/' -f 2,2 | cut -d '.' -f 1,1`
			echo "performing bps submission for step ${stepname} - yaml ${bynoext} "
			export curlog=/sdf/home/h/homer/LSSTCam-Nightly-Validation/bps_sub_logs/${stepname}/${bynoext}-log 
			bps submit ${subdir}/${bpsyaml} 2>&1 | tee ${curlog}
			echo "submit directory :"
			grep "Submit dir" ${curlog}
		    done

		    sleep 30
		    break
		else
		    echo "Ending. Nothing for the next step to process :-("
		    exit
		fi
	    fi
#	    if [[ ${fj} == "2" || ${fj} == "" ]]; then
#		exit
#	    fi
	    
	done
    fi
#    if [[ ${fj} == "2" || ${fj} == "" ]]; then
#	exit
#    fi
    export ogrplist=${grplist}
    export ostepname=${stepname}
done

