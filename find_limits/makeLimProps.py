# --------------------------------------------------------------------------------------
11;rgb:2020/2121/2424# makeLimsProps.py
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

subsys=sys.argv[1]
category=sys.argv[2]
props=sys.argv[3]


tm = None
if len(sys.argv) > 4 :
    tm=sys.argv[4]

# ---- current source run parameters ----
# https://rubinobs.atlassian.net/projects/BLOCK?selectedItem=com.atlassian.plugins.atlassian-connect-plugin:com.kanoah.test-manager__main-project-page#!/v2/testCase/BLOCK-T132
# Estimated 4h 54m
# 07/Oct/24 4:58 am
# ----------------------------------------
start="Oct 2 03:00:00 AM UTC 2024"
dur="1d"
# -- old --
start="Oct 7 04:58:00 AM UTC 2024"
dur="3h"


print("subsystem = ",subsys)
print("category = ",category)
print("properties name = ",props)
print("(optional) previous ns time of dat file to use = ",tm)

# ------------------------------------------------------------------------------------

# define limit exceptions here"

manual_chans_regex = {}
manual_chans_regex["R../Reb./Temp./limitHi"] = [25.0,"FocalPlane"]

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
        
    tmp_file = "oldprops_"+strns+".temp"
    out_file = category+"-operational_"+strns+".properties"
    
    # get an old categories properties file to be used for the channel list
    subprocess.call("cfs cat config/"+category+"/Limits/"+props+".properties > "+tmp_file,shell=True)
    
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
            cmnd = "python ~/mutils/trendutils/trender.py --stats --start \""+start+"\" --duration \""+dur+"\"  -- "+subsys+"/"+chan
            print("command = ",cmnd)
    
            try:
                rtrnstr = str(subprocess.check_output(cmnd,shell=True))
            except:
                print("Unable to get stats for chan - ",chan)
                continue
            
            result = rtrnstr.split("\\n")[8]
            print("result = ",result)
    
            fld = result.split()
    
            print("\n# --- "+chan+" ---")
            fpout.write("\n# --- "+chan+" ---"+"\n")
    
            if len(fld)<7 :
                print("Unable to get stats for chan - ",chan," Incomplete results")
                continue
    
        #  cnt      mean   median   stddev      min       max    d/dt 1/m  path                                      units
        #  8567     36.07    36.08 7.105e-15      36.1     36.1   -3.25e-15  rebpower/R00/RebG/OD/VbefLDO              Volts
    
            stddev = fld[3]
            print("stddev = ",stddev)
            if (float(fld[4])!=float(fld[5])) :
                stddev = fld[3]
            else :
                if (float(fld[4])!=0.00) :
                    stddev = 0.1*float(fld[4])
                else :
                    stddev = 0.1
                    
            subpath = chan
    
    
            # output the results

            chanpath= subpath+"/limitHi"
            value = check_chan_value(chanpath,float(fld[5])+3.0*float(stddev))
            print(chanpath + " = {:0.3g} ".format(value) )
            fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/warnHi"
            value = check_chan_value(chanpath,float(fld[5])+2.0*float(stddev))
            print(chanpath + " = {:0.3g} ".format(value) )
            fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/warnLo"
            value = check_chan_value(chanpath,float(fld[5])-2.0*float(stddev))
            print(chanpath + " = {:0.3g} ".format(value) )
            fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")

            chanpath= subpath+"/limitLo"
            value = check_chan_value(chanpath,float(fld[5])-3.0*float(stddev))
            print(chanpath + " = {:0.3g} ".format(value) )
            fpout.write(chanpath + " = {:0.3g} ".format(value)+"\n")
    
    # output the original entries for the states
    for ln in states :
        print(ln);
        fpout.write(ln+"\n")
        
                
    fpout.close()
    
if __name__ == "__main__":
    main()
