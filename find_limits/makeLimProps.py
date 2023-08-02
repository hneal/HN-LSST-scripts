# --------------------------------------------------------------------------------------
# makeLimsProps.py
# - Make limit properties using output from ./genLimsForSubSys.sh
#  Example:
#  [homer@lsst-it01 find_limits]$ ./genLimsForSubSys.sh RebPowerSupply rebpower
#  Then after renaming the output file: RebPowerSupply.dat --> RebPowerSupply-operational.dat
#  [homer@lsst-it01 find_limits]$ ~/yupy makeLimProps.py RebPowerSupply-operational.dat
# ---------------------------------------------------------------------------------------
import sys
import numpy as np

fp=open(sys.argv[1])

# rebpower/RebPS/P12/BoardTemp6 21.93766 22.53264 626.843 14033.7 28 0.123253

# loop over reduced trender output file to produce limit props
for ln in fp:
    fld = ln.split()
    print("# ---")
    print(fld[0]+"/limitLo = "+str(np.format_float_positional(float(fld[1])-2.0*float(fld[6]), precision=4, unique=False, fractional=False, trim='k')))
    print(fld[0]+"/limitHi = "+str(np.format_float_positional(float(fld[2])+2.0*float(fld[6]), precision=4, unique=False, fractional=False, trim='k')))
    print(fld[0]+"/warnLo = "+str(np.format_float_positional(float(fld[1])-float(fld[6]), precision=4, unique=False, fractional=False, trim='k')))
    print(fld[0]+"/warnHi = "+str(np.format_float_positional(float(fld[2])+float(fld[6]), precision=4, unique=False, fractional=False, trim='k')))


 

