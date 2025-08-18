import pandas
import numpy as np

tr0 = pandas.read_table('Quadbox-operational_Jul_17_01:00:00_48h_1754684662906122416.properties',sep=' ',skipinitialspace=True)
tr1 = pandas.read_table('Quadbox-operational_Jul_19_01:00:00_48h_1754688573622082828.properties',sep=' ',skipinitialspace=True)
tr2 = pandas.read_table('Quadbox-operational_Jul_21_01:00:00_48h_1754769411047287293.properties',sep=' ',skipinitialspace=True)
tr3 = pandas.read_table('Quadbox-operational_Jul_23_01:00:00_48h_1754945459636109407.properties',sep=' ',skipinitialspace=True)

df = pandas.DataFrame()
pandas.set_option('display.max_rows', None)
pandas.set_option('display.max_columns', None)
pandas.set_option('display.width', 200)

#tr2[[value.isalnum() for value in tr2[tr2.columns[2]]]]

df["chan"]=tr0.get(tr0.columns[0])[[value.isalnum() for value in tr0[tr0.columns[2]]]]
df["17July"]=tr0.get(tr0.columns[2])[[value.isalnum() for value in tr0[tr0.columns[2]]]].astype('float64')
df["19July"]=tr1.get(tr1.columns[2])[[value.isalnum() for value in tr0[tr0.columns[2]]]].astype('float64')
df["21July"]=tr2.get(tr2.columns[2])[[value.isalnum() for value in tr0[tr0.columns[2]]]].astype('float64')
df["23July"]=tr3.get(tr3.columns[2])[[value.isalnum() for value in tr0[tr0.columns[2]]]].astype('float64')

df["mean"] = (df["17July"]+df["19July"]+df["21July"]+df["23July"])/4.0
df["min"] = df.min(axis=1)
df["max"] = df.max(axis=1)
df["100*diff/mean"] = round(100.0*(df["max"]-df["min"])/df["mean"],2)
#df["min"] = np.min(df["17July"],df["19July"],df["21July"],df["23July"])

print(df)

#print(df["17July"].astype('float64', raise_on_error = False))
#print(df["17July"].astype('float64'))
