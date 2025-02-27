#!/bin/sh

echo "Running setup_lsstcam.sh"

export LSST_VERSION=w_2025_08

echo "Executing loadLSST.sh"
#source /sdf/group/rubin/sw/tag/${LSST_VERSION}/loadLSST.sh
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/${LSST_VERSION}/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t ${LSST_VERSION}
eups list -s lsst_distrib

# until a more appropriate location for this is devised
echo "Setting DAF_BUTLER_CACHE_EXPIRATION_MODE"
#export DAF_BUTLER_CACHE_EXPIRATION_MODE=datasets=500

export DAF_BUTLER_CACHE_DIRECTORY=/lscratch/${USER}
export DAF_BUTLER_CACHE_EXPIRATION_MODE=size=1_000_000_000_000
export LSST_S3_USE_THREADS=False

echo "End of setup_lsstcam.sh"
