#export LSST_VERSION=d_2024_06_21
#source /sdf/group/rubin/sw/tag/${LSST_VERSION}/loadLSST.bash

#export LSST_VERSION=w_2024_31
export LSST_VERSION=w_2024_40
#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/${LSST_VERSION}/loadLSST.sh
source /sdf/group/rubin/sw/tag/${LSST_VERSION}/loadLSST.sh
setup lsst_distrib -t ${LSST_VERSION}

# until a more appropriate location for this is devised
export DAF_BUTLER_CACHE_EXPIRATION_MODE=datasets=500

#dev_dir=/sdf/home/h/homer/proc_comcam_sim
#setup -r ${dev_dir}/obs_lsst -j

#setup -j -r ~/proc_comcam_sim/drp_pipe

