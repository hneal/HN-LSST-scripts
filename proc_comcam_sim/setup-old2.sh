if [ -z "$1" ]
then
#    # set up the most recently available weekly
#    foo=`/usr/bin/ls -rt /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib | grep ^w_20`
#    weekly_version=`echo $foo | awk -F ' ' '{print $NF}'`
    weekly_version=w_2024_04
else
    # set up the requested weekly
    weekly_version=$1
fi
export WEEKLY=${weekly_version}

LSST_DISTRIB=/cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/${weekly_version}
source ${LSST_DISTRIB}/loadLSST-ext.bash
setup lsst_distrib
export OMP_NUM_THREADS=1
export NUMEXPR_MAX_THREADS=1
export OMP_PROC_BIND=false

dev_dir=/sdf/home/h/homer/proc_comcam_sim

#setup -r ${dev_dir}/imSim -j
#setup -r ${dev_dir}/skyCatalogs -j
#setup -r ${dev_dir}/GalSim -j
#setup -r ${dev_dir}/desc_roman_sims -j
setup -r ${dev_dir}/obs_lsst -j
#setup -r ${dev_dir}/imsim_utils -j
#setup -r ${dev_dir}/refcat_generation -j

wq_env=/fs/ddn/sdf/group/lsst/software/IandT/bps_env/wq

#export RUBIN_SIM_DIR=/sdf/home/h/homer/dev/rubin_sim
#export RUBIN_SIM_DATA_DIR=/sdf/data/rubin/user/homer/imSim/rubin_sim_data
#export SIMS_SED_LIBRARY_DIR=/sdf/data/rubin/user/homer/imSim/rubin_sim_data/sims_sed_library
#BATOID_RUBIN_DIR=${dev_dir}/batoid_rubin
#GCR_DIR=/sdf/home/h/homer/dev/generic-catalog-reader
#GCR_CATALOGS_DIR=/sdf/home/h/homer/dev/gcr-catalogs
#export PYTHONPATH=${GCR_CATALOGS_DIR}:${GCR_DIR}:${BATOID_RUBIN_DIR}:${RUBIN_SIM_DIR}:${wq_env}/lib/python3.10/site-packages:${PYTHONPATH}
export PYTHONPATH=${wq_env}/lib/python3.10/site-packages:${PYTHONPATH}
export PATH=${wq_env}/bin:${PATH}


export KMP_DUPLICATE_LIB_OK=TRUE

PS1="\[\033]0;\w\007\][`hostname` ${weekly_version} \W] "
