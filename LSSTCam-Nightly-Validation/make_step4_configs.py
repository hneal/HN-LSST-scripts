import os
import numpy as np
import lsst.utils as utils
from or5.or5_tracts import or5_wfd_tracts

#PACKAGE_DIR = utils.getPackageDir("or5")
PACKAGE_DIR = os.getcwd()

step = "step4"
day = "day1"
version = "w_2025_07"
ticket = "DM-xxxxx"
repo = "embargo_or5"
tagged_collection = f"2.2i/raw/OR5/WFD/{day}/DM-48585"
ngroups = 10

bps_config_dir = "./bps_configs_test"
os.makedirs(bps_config_dir, exist_ok=True)

template_file = os.path.join(PACKAGE_DIR, "bps",
                             f"bps_NV_{step}_template.yaml")
with open(template_file) as fobj:
    bps_template = "".join(fobj.readlines())

# Divide into groups.
indices = np.linspace(0, len(or5_wfd_tracts) + 1, ngroups + 1, dtype=int)

for igroup, (imin, imax) in enumerate(zip(indices[:-1], indices[1:])):
    group = f"{igroup:02d}"
    tract_list = ",".join([str(_) for _ in or5_wfd_tracts[imin:imax]])
    bps_yaml = os.path.join(bps_config_dir,
                            f"bps_NV_{step}_{day}_{group}.yaml")
    with open(bps_yaml, "w") as fobj:
        fobj.write(bps_template % locals())
