import os
import numpy as np
import lsst.daf.butler as daf_butler
import lsst.utils as utils

#PACKAGE_DIR = utils.getPackageDir("or5")
PACKAGE_DIR = os.getcwd()

step = "step1"
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

        butler = daf_butler.Butler(repo, collections=[tagged_collection])

        # Group by exposures
        njobs = 10000  # number of concurrent jobs
        num_dets = 189  # number of detectors
        nexp_groups = int(np.ceil(njobs / num_dets))

        # Get exposure list.
        where = "detector=94"
        refs = butler.query_datasets("raw", where=where, limit=None)
        exposures = sorted(_.dataId["exposure"] for _ in refs)
        indices = np.linspace(0, len(exposures), nexp_groups+1, dtype=int)

        for igroup, (imin, imax) in enumerate(zip(indices[:-1], indices[1:])):
            group = f"{igroup:02d}"
            exps = exposures[imin:imax]
            exposure_selection = f"(exposure in ({exps[0]}..{exps[-1]}))"
            bps_yaml = os.path.join(bps_config_dir,
                                    f"bps_NV_{step}_{day}_{group}.yaml")
            with open(bps_yaml, "w") as fobj:
                fobj.write(bps_template % locals())
                
