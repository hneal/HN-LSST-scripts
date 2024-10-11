pipetask run -b /repo/ops-rehearsal-3-prep \
         -p pipelines/sfp.yaml#isr,characterizeImage,calibrate \
         -i u/jchiang/flat_50240117_w_2024_04,refcats \
         -o u/homer/sfp_checks_w_2024_04 \
         -d "instrument='LSSTComCamSim' and exposure in (5024032100240)" \
         --register-dataset-types
