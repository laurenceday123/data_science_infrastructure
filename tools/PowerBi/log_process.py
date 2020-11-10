# For a machine learning service using the log_it function, you can parse the logs as we can see below

import json
import pandas as pd
dataset

records= []
for eachItem in dataset['event']:
    try:
        records.append(json.loads(eachItem))
    except:
        #print(eachItem)
        pass
dfOut =pd.DataFrame.from_records(records)

dfOut = dataset[['timeStamp','service']].join(dfOut)
dfOut = dfOut[['timeStamp','service','Severity']].join(pd.DataFrame.from_dict([l for l in dfOut['Message']if type(l) is dict]))
dfOut['ApplicationId'] = dfOut['ApplicationId'].str.replace('[','').str.replace(']','')#.astype(int)
dfOut['timeStamp'] = pd.to_datetime(dfOut['timeStamp'])
dfOut.rename(columns={'Item': 'WarningItem','Event':'LogMessage'},inplace=True)
dfOut = dfOut[['timeStamp', 'service', 'ApplicationId', 'Severity','LogMessage','WarningItem',
     'Exception','Confidence', 'Result','RawData']]
dfOut = dfOut[~dfOut['Severity'].isna()]


