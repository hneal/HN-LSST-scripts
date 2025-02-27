import os
import lsst.utils as utils

#PACKAGE_DIR = utils.getPackageDir("or5")
PACKAGE_DIR = os.getcwd()

step = "step2"
day = "day1"
version = "w_2025_08"
ticket = "DM-49179"
repo = "embargo_or5"
tagged_collection = f"2.2i/raw/OR5/WFD/{day}/DM-48585"

bps_config_dir = "./bps_configs_test"
os.makedirs(bps_config_dir, exist_ok=True)

template_file = os.path.join(PACKAGE_DIR, "bps",
                             f"bps_NV_{step}_template.yaml")
with open(template_file) as fobj:
    bps_template = "".join(fobj.readlines())

bps_yaml = os.path.join(bps_config_dir,
                        f"bps_NV_{step}_{day}.yaml")
with open(bps_yaml, "w") as fobj:
    fobj.write(bps_template % locals())
