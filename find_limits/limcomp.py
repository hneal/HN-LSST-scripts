import pandas
import numpy as np
import tabulate

tr0 = pandas.read_table('Quadbox-operational_Jul_17_01:00:00_48h_1754684662906122416.properties',sep=' ',skipinitialspace=True)
tr1 = pandas.read_table('Quadbox-operational_Jul_19_01:00:00_48h_1754688573622082828.properties',sep=' ',skipinitialspace=True)
tr2 = pandas.read_table('Quadbox-operational_Jul_21_01:00:00_48h_1754769411047287293.properties',sep=' ',skipinitialspace=True)
tr3 = pandas.read_table('Quadbox-operational_Jul_23_01:00:00_48h_1754945459636109407.properties',sep=' ',skipinitialspace=True)

df = pandas.DataFrame()
pandas.set_option('display.max_rows', None)
pandas.set_option('display.max_columns', None)
pandas.set_option('display.width', 200)

#tr2[[value.isalnum() for value in tr2[tr2.columns[2]]]]

def isnum(s):
    isit = True
    try:
        tst_val = float(s)
    except:
        isit = False
#    return s.isalnum()
    return isit

df["chan"]=tr0.get(tr0.columns[0])[[isnum(value) for value in tr0[tr0.columns[2]]]]
df["17July"]=tr0.get(tr0.columns[2])[[isnum(value) for value in tr0[tr0.columns[2]]]].astype('float64')
df["19July"]=tr1.get(tr1.columns[2])[[isnum(value) for value in tr0[tr0.columns[2]]]].astype('float64')
df["21July"]=tr2.get(tr2.columns[2])[[isnum(value) for value in tr0[tr0.columns[2]]]].astype('float64')
df["23July"]=tr3.get(tr3.columns[2])[[isnum(value) for value in tr0[tr0.columns[2]]]].astype('float64')

df["mean"] = (df["17July"]+df["19July"]+df["21July"]+df["23July"])/4.0
#df["mean"] = (df["17July"]+df["19July"]+df["21July"])/3.0
df["min"] = df.min(axis=1)
df["max"] = df.max(axis=1)
df["100*diff/mean"] = round(100.0*(df["max"]-df["min"])/df["mean"],2)
#df["min"] = np.min(df["17July"],df["19July"],df["21July"],df["23July"])

def pick_lim(row):
    if 'Lo' in row['chan'][-2:] :
        if "_I" in row['chan'].split('/')[2][-2:]:
            return max(row['min'],0.0)
        else:
            return max(row['min'],0.0)
    else:
        return row['max']

df['new lim'] = df.apply(pick_lim, axis=1) # Apply row-wise
                                
#print(df)

dd = pandas.DataFrame()
dd['chan'] = df['chan']
dd['equal'] = '='
dd['limit'] = df['new lim']

#for ln in outstr.split("\n"):
skip=True
for ln in dd.to_string(index=False).split("\n"):
    if not skip:
        print(ln.lstrip())
    else:
        skip=False
