# script for launching nightly

cd /sdf/home/h/homer/proc_auxtel/

echo "setting up environment"
source setup_aux.sh

echo "setting date range"
export NIGHTLY_START=`date -d '-1 day' '+%Y%m%d'`
export NIGHTLY_END=`date +%Y%m%d`
echo "NIGHTLY_START = ${NIGHTLY_START}"
echo "NIGHTLY_END = ${NIGHTLY_END}"

# --- test ---
export NIGHTLY_START="20240806"
export NIGHTLY_END="20240807"
echo "TEST: OVERRIDING NIGHTLY_START = ${NIGHTLY_START}"
echo "TEST: OVERRIDING NIGHTLY_END = ${NIGHTLY_END}"

echo "performing bps submission"
bps submit hn_aux_nightly_test.yaml 2>&1 | tee autotest-log-${NIGHTLY_START}

echo "submit directory :"
grep "Submit dir" autotest-log-${NIGHTLY_START}"
