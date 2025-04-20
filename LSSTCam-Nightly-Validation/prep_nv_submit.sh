export obs_day=`date -d '-1 day' '+%Y%m%d'`
export topdir='/sdf/data/rubin/shared/campaigns/LSSTCam-Nightly-Validation'
if [ ! -d ${topdir}/submit_${obs_day} ]; then
    mkdir ${topdir}/submit_${obs_day}
    cd ${topdir}/submit_${obs_day}
    echo "created:"
    pwd
    echo "creating bps_sub_logs directories"
    mkdir -p bps_sub_logs/NV_1a
    mkdir bps_sub_logs/NV_1b-3
    echo "copying over scripts from previous processing"
    cp -p ${topdir}/submit_`date -d '-2 day' '+%Y%m%d'`/*.{sh,yaml} .
    echo "overwriting setup_lsstcam.sh with ../latest_setup_lsstcam.sh"
    cp -p ${topdir}/latest_setup_lsstcam.sh setup_lsstcam.sh
    echo "running subNV to start processing"
    source subNV.sh 2>&1 | tee -a run-subNV-`date -d '-1 day' '+%Y%m%d'`.log
fi
