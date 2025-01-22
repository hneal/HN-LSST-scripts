#!/bin/sh

echo "Running setup_cc.sh"

export LSST_VERSION=d_2024_11_05
#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/${LSST_VERSION}/loadLSST.sh

echo "Executing loadLSST.sh"
source /sdf/group/rubin/sw/tag/${LSST_VERSION}/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t ${LSST_VERSION}
eups list -s lsst_distrib

# until a more appropriate location for this is devised
echo "Setting DAF_BUTLER_CACHE_EXPIRATION_MODE"
export DAF_BUTLER_CACHE_EXPIRATION_MODE=datasets=500

echo "Setting up use of obs_lsst and drp_pipe branches"
#export dev_dir=/sdf/data/rubin/shared/campaigns/ComCam-Nightly-Validation
#setup -r ${dev_dir}/obs_lsst -j
#setup -r ${dev_dir}/drp_pipe -j

#setup -j -r ~/proc_comcam_sim/drp_pipe

echo "End of setup_cc.sh"
