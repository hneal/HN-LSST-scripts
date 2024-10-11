#pipetask run -b /repo/ops-rehearsal-3-prep -i LSSTComCamSim/raw/test-or3-2,refcats,skymaps -o u/homer/lsstcomcamsim-step1-test-7024033000793_test_iter2  -p ${DRP_PIPE_DIR}/pipelines/LSSTComCamSim/DRP-ops-rehearsal-3.yaml#step1  -d "exposure=7024033000793 AND detector=0 AND skymap='ops_rehersal_prep_2k_v1'" --register-dataset-types -j 12

ipetask run -b /repo/ops-rehearsal-3-prep -i LSSTComCamSim/raw/test-or3-2,refcats,skymaps -i LSSTComCamSim/calib -o u/homer/lsstcomcamsim-step1-test-7024040500918_test_iter2  -p ${DRP_PIPE_DIR}/pipelines/LSSTComCamSim/DRP-ops-rehearsal-3.yaml#step1  -d "exposure in (7024040500918) AND detector=0 AND skymap='ops_rehersal_prep_2k_v1'" --register-dataset-types -j 12 >& lsstcomcamsim-step1-test-7024040500918.log