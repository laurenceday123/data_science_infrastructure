let AnalyticsQuery =
let Source = Json.Document(Web.Contents("get source URL from KUSTO query export", 
[Query=[#"query"="traces
| where timestamp > startofweek(now())
| project timeStamp = timestamp, service = customDimensions.[""Service Name""] , event = customDimensions.Content
| where event contains ""PASS"" or event contains ""RESULT"" or event contains ""WARNING"" or event contains ""ERROR""
| order by timeStamp desc nulls last
//| top 500 by timeStamp
",#"x-ms-app"="AAPBI",#"prefer"="ai.response-thinning=true"],Timeout=#duration(0,0,4,0)])),
TypeMap = #table(
{ "AnalyticsTypes", "Type" }, 
{ 
{ "string",   Text.Type },
{ "int",      Int32.Type },
{ "long",     Int64.Type },
{ "real",     Double.Type },
{ "timespan", Duration.Type },
{ "datetime", DateTimeZone.Type },
{ "bool",     Logical.Type },
{ "guid",     Text.Type },
{ "dynamic",  Text.Type }
}),
DataTable = Source[tables]{0},
Columns = Table.FromRecords(DataTable[columns]),
ColumnsWithType = Table.Join(Columns, {"type"}, TypeMap , {"AnalyticsTypes"}),
Rows = Table.FromRows(DataTable[rows], Columns[name]), 
Table = Table.TransformColumnTypes(Rows, Table.ToList(ColumnsWithType, (c) => { c{0}, c{3}}))
in
Table,
    #"Run Python script" = Python.Execute("import json#(lf)import pandas as pd#(lf)dataset#(lf)#(lf)records= []#(lf)for eachItem in dataset['event']:#(lf)    try:#(lf)        records.append(json.loads(eachItem))#(lf)    except:#(lf)        #print(eachItem)#(lf)        pass#(lf)dfOut =pd.DataFrame.from_records(records)#(lf)#(lf)dfOut = dataset[['timeStamp','service']].join(dfOut)#(lf)dfOut = dfOut[['timeStamp','service','Severity']].join(pd.DataFrame.from_dict([l for l in dfOut['Message']if type(l) is dict]))#(lf)dfOut['ApplicationId'] = dfOut['ApplicationId'].str.replace('[','').str.replace(']','')#.astype(int)#(lf)dfOut['timeStamp'] = pd.to_datetime(dfOut['timeStamp'])#(lf)dfOut.rename(columns={'Item': 'WarningItem','Event':'LogMessage'},inplace=True)#(lf)dfOut = dfOut[['timeStamp', 'service', 'ApplicationId', 'Severity','LogMessage','WarningItem',#(lf)     'Exception','Confidence', 'Result','RawData']]#(lf)dfOut = dfOut[~dfOut['Severity'].isna()]#(lf)#(lf)#(lf)",[dataset=AnalyticsQuery]),
    dfOut = #"Run Python script"{[Name="dfOut"]}[Value],
    #"Changed Type" = Table.TransformColumnTypes(dfOut,{{"timeStamp", type datetime}, {"service", type text}, {"ApplicationId", Int64.Type}, {"Severity", type text}, {"LogMessage", type text}, {"WarningItem", type text}, {"Exception", type text}, {"Confidence", type number}, {"Result", type logical}, {"RawData", type text}})
in
    #"Changed Type"




