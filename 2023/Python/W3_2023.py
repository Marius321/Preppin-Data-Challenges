import pandas as pd

#Input the data
df_i = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 3\Inputs\PD 2023 Wk 1 Input.csv")
df_t = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 3\Inputs\Targets.csv")

#For the transactions file:
#Filter the transactions to just look at DSB (help)
#These will be transactions that contain DSB in the Transaction Code field
df_i = df_i[df_i['Transaction Code'].str.contains('DSB')]

#Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
df_i['Online or In-Person'] = df_i['Online or In-Person'].replace({1:'Online',2:'In-Person'})

#Change the date to be the quarter (help)
df_i['Transaction Date'] = pd.to_datetime(df_i['Transaction Date'],format='%d/%m/%Y %H:%M:%S')
df_i['Transaction Date'] = 'Q' + df_i['Transaction Date'].dt.quarter.astype(str)

#Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
df_i = df_i.groupby(['Transaction Date', 'Online or In-Person'],as_index=False)['Value'].sum()

#For the targets file:
#Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
df_t = pd.melt(df_t,id_vars=['Online or In-Person'], var_name='Quarter', value_name='Value')

#Rename the fields
df_i = df_i.rename(columns={"Transaction Date": "Quarter"})
df_t = df_t.rename(columns={"Value": "Quarterly Targets"})

#Remove the 'Q' from the quarter field and make the data type numeric (help)
df_i['Quarter'] = df_i['Quarter'].str.replace('Q','').astype(int)
df_t['Quarter'] = df_t['Quarter'].str.replace('Q','').astype(int)

#Join the two datasets together (help)
merged_data = pd.merge(df_i, df_t, how='inner', on=['Online or In-Person','Quarter'])

#Calculate the Variance to Target for each row (help)
merged_data['Variance to Target'] = merged_data['Value'] - merged_data['Quarterly Targets']

#Output the data
output= merged_data.iloc[:,[1,0,2,3,4]]
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 3\Outputs\output.csv',index=False)
print("Data Prepped!")