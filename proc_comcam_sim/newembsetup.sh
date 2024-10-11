. ~/setupdaily.sh
cd ~/proc_comcam_sim/drp_pipe
setup -j -r .
export LSST_RESOURCES_S3_PROFILE_embargo=https://sdfembs3.sdf.slac.stanford.edu
export butlerRoot=s3://embargo@repo-test-users/repotest02
