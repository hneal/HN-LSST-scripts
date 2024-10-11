from collections import defaultdict
import numpy as np
import pandas as pd
import lsst.daf.butler as daf_butler

repo = '/repo/ops-rehearsal-3-prep'
collections = ['LSSTComCamSim/raw/all']

butler = daf_butler.Butler(repo, collections=collections)

#where = "exposure.observation_reason='survey'"
where = "instrument='LSSTComCamSim' and exposure in (5024032100240..5024032100299)"
refs = sorted(set(butler.registry.queryDatasets('raw', where=where)
                  .expanded()), key=lambda ref: ref.dataId['exposure'])
#exp = butler.get(refs[-1])
#det = exp.getDetector()
#for amp in det:
#    print(amp.getName(), amp.getGain(), amp.getSaturation())

exp_md_key = 'observation_type'

print(len(refs))
data = defaultdict(list)
for ref in refs:
    exposure_rec = ref.dataId.records['exposure']
    data['obs_id'].append(exposure_rec.obs_id)
    data['exposure'].append(ref.dataId['exposure'])
    data['observation_type'].append(exposure_rec.observation_type)
    data['observation_reason'].append(exposure_rec.observation_reason)
    data['physical_filter'].append(ref.dataId['physical_filter'])
    data['exposure_time'].append(exposure_rec.exposure_time)
    data['dark_time'].append(exposure_rec.dark_time)
    data['mjd'].append(exposure_rec.timespan.begin.to_value(format='mjd'))
df = pd.DataFrame(data)
