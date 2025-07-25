# --------------------------------------------------------------------------------------
# makeLimsProps.py
# - Make limit properties 
#  Example:
#     python makeLimProps.py rebpower RebPowerSupply rebpower
#
#  Input argument format:    <subsys>  < category>  <properties>
#
#  Author: H. Neal on behalf of the CCS team
#
# replaces all of-->
#    ./genLimsForSubSys.sh RebPowerSupply rebpower
#   awk '{print $1}' oldprops.temp  > oldkeys.temp
#   Then after renaming the output file: RebPowerSupply.dat --> RebPowerSupply-operational.dat
#    python makeLimProps.py RebPowerSupply-operational.dat
#    grep -f oldkeys.temp current_properties/RebPowerSupply-operational.properties
#    cat current_properties/RebPowerSupply-operational-pruned.properties | cfs cat -cn config/RebPowerSupply/Limits/auto-operational.properties
# ---------------------------------------------------------------------------------------
import sys
import numpy as np
import time
import subprocess
import re
import math
import pandas

subsys=sys.argv[1]
category=sys.argv[2]
props=sys.argv[3]


tm = None
if len(sys.argv) > 4 :
    tm=sys.argv[4]

# -------------------------------------------------------------------
# define period to use by specifying a start date/tiome and duration
# -------------------------------------------------------------------
    
#start="Nov 5 00:00:00 AM UTC 2024"
#start="Wed Apr 16 00:00:00 AM UTC 2025"
#start="Wed May  7 01:00:00 AM UTC 2025"
start="Thu Jul  3 01:00:00 UTC 2025"
#start="Thu Jul  4 01:00:00 UTC 2025"
#dur="5h"
dur="48h"

# -------------------------------------------------------------------
# specify number of stddev's to use for the warning and limit determinations
# -------------------------------------------------------------------
nstd_warn = 5
nstd_limit = 6


print("subsystem = ",subsys)
print("category = ",category)
print("properties name = ",props)
print("(optional) previous ns time of dat file to use = ",tm)

# ------------------------------------------------------------------------------------

# define limit exceptions here"

manual_chans_regex = {}
manual_chans_regex["R../Reb./Temp./limitHi"] = [25.0,"FocalPlane"]
manual_chans_regex["R../Reb./Temp./limitLo"] = [-45.0,"FocalPlane"]

# ------------------------------------------------------------------------------------

def check_chan_value(chan : str, auto_val : float) -> float:
    '''
    check whether the channel matches one to be set manually and if so, return the manual value
    otherwise return the input value
    '''
    
    value = auto_val
    for man_chan_check in manual_chans_regex :
        match_test = re.compile(man_chan_check)
        #print("manual channel regex test = "+man_chan_check)
        if match_test.match(chan):
            # confirm that the category also matches
            if manual_chans_regex[man_chan_check][1] in category :
                value = manual_chans_regex[man_chan_check][0]
                print(chan+" found to be a channel limit with a manual setting of ",value)

    return value

# ----------------------------------------

def main() :
    strns = str(time.time_ns())
    if tm != None:
        strns = str(tm)

    sstrt = "_".join(start.split()[1:4])
        
    tmp_file = "oldprops_"+strns+".temp"
    out_file = category+"-operational_"+sstrt+"_"+dur+"_"+strns+".properties"
    
    # get an old categories properties file to be used for the channel list
    subprocess.call("cfs cat config/"+category+"/Limits/autogen-template.properties > "+tmp_file,shell=True)
    
    # make lists of all channels and unique keys
    fp=open(tmp_file)
    
    keys = []
    allchan = []
    states = []
    idx = 0
    
    for ln in fp:
        idx = idx + 1
    
        # ignore comment lines
        if ln[0]=='#' :
            print("Skipping comment line - ",ln) 
            continue
        
        # this is for a quick test ... otherwise comment out
        # if idx%200 != 0 :
        #     continue
        
        if "State" in ln and "/" in ln :
            states.append(ln)
        elif ("/" in ln):
            allchan.append((ln.split())[0])
            ch = "/".join(((ln.split())[0]).split("/")[:-1])
            if ("/" in ch):
                if ch not in keys:
                    keys.append(ch)
    
    print("keys = \n",keys)
    
    # --------- start processing and recording results --------------
    
    fpout=open(out_file,"a")
    
    
    # use trender to get the stats
    for chan in keys:
        print("getting stats for "+chan)
        if not "State" in chan:     # no longer needed because the keys are now for non State channels
            cmnd = "python ~/mutils/trendutils/trender.py --stats --start \""+start+"\" --duration \""+dur+"\"  -- "+subsys+"/"+chan+" | tail -2 | sed 's/#//' > tr_out.csv"
            print("command = ",cmnd)
    
            try:
                rtrnstr = str(subprocess.check_output(cmnd,shell=True))

                tr = pandas.read_table('tr_out.csv',sep=' ',skipinitialspace=True)
                tr.columns
                tr.values

            except:
                print("Unable to get stats for chan - ",chan)
                continue
                        
            print("\n# --- "+chan+" ---")
            fpout.write("\n# --- "+chan+" ---"+"\n")
    
            if len(tr.columns)<10 :
                print("Unable to get stats for chan - ",chan," Incomplete results")
                continue
    
        #  cnt      mean   median   stddev      min       max    d/dt 1/m  path                                      units
        #  8567     36.07    36.08 7.105e-15      36.1     36.1   -3.25e-15  rebpower/R00/RebG/OD/VbefLDO              Volts
    
            stddev = float(tr['stddev'][0])
            print("stddev = ",stddev)

            tr_min = float(tr['min'][0])
            tr_max = float(tr['max'][0])
            
            # This is to handle situations where stddev is too small for the formatted output
            absmean = abs(tr_min+tr_max)/2.0
            if absmean>0.0 :
                if (stddev/absmean) < 1.0e-2 :
                    x = 1.0e-2 * absmean
                    sigfigs = 2
                    stddev = round(x, -int(math.floor(math.log10(abs(x)))) + (sigfigs - 1)) # from Google AI
                    print("using alternate stddev = ",stddev)

                        
            subpath = chan
    
    
            # output the results

            chanpath= subpath+"/limitHi"
            if chanpath in allchan:
                value = check_chan_value(chanpath,tr_max+nstd_limit*stddev)
                print(chanpath + " = {:0.3g} ".format(value) )
                fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/warnHi"
            if chanpath in allchan:
                value = check_chan_value(chanpath,tr_max+nstd_warn*stddev)
                print(chanpath + " = {:0.3g} ".format(value) )
                fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/warnLo"
            if chanpath in allchan:
                value = check_chan_value(chanpath,tr_min-nstd_warn*stddev)
                print(chanpath + " = {:0.3g} ".format(value) )
                fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/limitLo"
            if chanpath in allchan:
                value = check_chan_value(chanpath,tr_min-nstd_limit*stddev)
                print(chanpath + " = {:0.3g} ".format(value) )
                fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")
    
                
    fpout.close()
    
if __name__ == "__main__":
    main()
