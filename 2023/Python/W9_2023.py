import pandas as pd
from pandasql import sqldf
pd.options.display.max_columns = None

#Input the data
df_td = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 7\Inputs\Transaction Detail.csv")
df_tp = pd.read_csv(r"C:/Users/Marius/Documents/Prepping Data/2023 Week 7/Inputs/Transaction Path.csv")
df_ai = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 7\Inputs\Account Information.csv")

#For the Transaction Path table:
#Make sure field naming convention matches the other tables
#i.e. instead of Account_From it should be Account From
df_tp = df_tp.rename(columns={"Account_To":"Account To", "Account_From":"Account From"})

#Filter out the cancelled transactions
df_td = df_td[df_td['Cancelled?']=="N"]

#Split the flow into incoming and outgoing transactions 
df_merged = df_td.merge(df_tp, how="inner", on="Transaction ID")
df_inc = df_merged.iloc[:,[4,1,2]]
df_out = df_merged.iloc[:,[5,1,2]]
df_out["Value"] = df_out["Value"] * -1

#Bring the data together with the Balance as of 31st Jan
df_inc = df_inc.rename(columns={"Account To":"Account Number","Transaction Date":"Balance Date", "Value":"Balance"})
df_out = df_out.rename(columns={"Account From":"Account Number","Transaction Date":"Balance Date", "Value":"Balance"})
df_union = pd.concat([df_inc,df_out,df_ai])

#Work out the order that transactions occur for each account
#Hint: where multiple transactions happen on the same day, assume the highest value transactions happen first
df_union = df_union.sort_values(by=["Account Number", "Balance Date"], ascending=[True,True])
df_union['Transaction Order'] = df_union.groupby(["Account Number"]).cumcount() + 1

#Use a running sum to calculate the Balance for each account on each day (hint)
df_join1 = df_union.iloc[:,[0,1,2,5]]
df_join2 = df_join1.iloc[:,[0,2,3]]
df_join2.columns = [col + " 2" for col in df_join2.columns]


cond_join= '''
    SELECT *
    FROM df_join1
    INNER JOIN df_join2
    ON df_join1.[Account Number] = df_join2.[Account Number 2]
    AND  df_join1.[Transaction Order] >= df_join2.[Transaction Order 2]
'''
joined_df = sqldf(cond_join)

output = joined_df.groupby(["Transaction Order", "Account Number", "Balance Date", "Balance"])["Balance 2"].agg("sum").reset_index()
output = output.rename(columns={"Balance 2": "Balance","Balance": "Transaction Value"})

#The Transaction Value should be null for 31st Jan, as this is the starting balance
if 1 in output["Transaction Order"].values:
    output.loc[output["Transaction Order"] == 1, "Transaction Value"] = None
else:
    pass

#Output the data
output = output.iloc[:,[0,1,2,3,4]]
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 9\Outputs\W9_2023_Output_py.csv', index=False)
print("Data prepped")