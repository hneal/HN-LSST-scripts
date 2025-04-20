import os
import glob
import time
import subprocess

bps_files = sorted(glob.glob("bps_configs/bps_step1_OR5.2_NV_DDF_day1_*.yaml"))
dt = 5

log_dir = "./logs"
os.makedirs(log_dir, exist_ok=True)

for bps_file in bps_files:
    log_file = os.path.join(
        log_dir, os.path.basename(bps_file).replace(".yaml", ".log"))
    command = f"(time bps submit {bps_file}) &> {log_file}"
    print(command)
    #subprocess.check_call(command, shell)
    time.sleep(dt)
