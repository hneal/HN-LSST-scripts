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
    print("\n# --- "+fld[0]+" ---")
    stddev = fld[6]
    if (float(fld[1])!=float(fld[2])) :
        stddev = fld[6]
    else :
        if (float(fld[1])!=0) :
            stddev = 0.1*float(fld[1])
        else :
            stddev = 0.1

#    print(fld[0]+"/limitHi = "+str(np.format_float_positional(float(fld[2])+2.0*float(stddev), precision=4, unique=False, fractional=False, trim='k')))
#    print(fld[0]+"/warnHi = "+str(np.format_float_positional(float(fld[2])+float(stddev), precision=4, unique=False, fractional=False, trim='k')))
#    print(fld[0]+"/warnLo = "+str(np.format_float_positional(float(fld[1])-float(stddev), precision=4, unique=False, fractional=False, trim='k')))
#    print(fld[0]+"/limitLo = "+str(np.format_float_positional(float(fld[1])-2.0*float(stddev), precision=4, unique=False, fractional=False, trim='k')))

    print(fld[0]+"/limitHi = {:>8.6g} ".format(float(fld[2])+2.0*float(stddev)))
    print(fld[0]+"/warnHi = {:>8.6g} ".format(float(fld[2])+float(stddev)))
    print(fld[0]+"/warnLo = {:>8.6g} ".format(float(fld[2])-float(stddev)))
    print(fld[0]+"/limitLo = {:>8.6g} ".format(float(fld[2])-2.0*float(stddev)))
 

