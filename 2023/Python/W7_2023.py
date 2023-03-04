import pandas as pd
pd.options.display.max_columns = None

#Input the data
df_td = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 7\Inputs\Transaction Detail.csv")
df_tp = pd.read_csv(r"C:/Users/Marius/Documents/Prepping Data/2023 Week 7/Inputs/Transaction Path.csv")
df_ah = pd.read_csv(r"C:/Users/Marius/Documents/Prepping Data/2023 Week 7/Inputs/Account Holders.csv")
df_ai = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 7\Inputs\Account Information.csv")

#For the Transaction Path table:
#Make sure field naming convention matches the other tables
#i.e. instead of Account_From it should be Account From

df_tp.columns = df_tp.columns.str.replace('_', ' ')

#For the Account Information table:
#Make sure there are no null values in the Account Holder ID
#Ensure there is one row per Account Holder ID
#Joint accounts will have 2 Account Holders, we want a row for each of them

df_ai['Account Holder ID'] = df_ai['Account Holder ID'][df_ai['Account Holder ID'] != None]
df_ai = df_ai.assign(**{'Account Holder ID': df_ai['Account Holder ID'].str.split(',')}).explode('Account Holder ID').reset_index(drop=True)

#For the Account Holders table:
#Make sure the phone numbers start with 07
df_ah['Contact Number'] = '0' + df_ah['Contact Number'].apply(str)

#Bring the tables together
df_ai['Account Holder ID'] = df_ai['Account Holder ID'].astype('int')
output = pd.merge(df_td, df_tp, on='Transaction ID').merge(df_ai, left_on='Account From', right_on='Account Number').merge(df_ah, on='Account Holder ID')

# Filter out cancelled transactions
output = output[output['Cancelled?'] == 'N']

#Filter to transactions greater than £1,000 in value 
output =  output[output['Value'] >= 1000]

#Filter out Platinum accounts
output =  output[output['Account Type'] != 'Platinum']

#Output the data
output = output.iloc[:,[0,4,1,2,6,7,9,10,11,12,13,14]]
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 7\Outputs\output.csv',index=False)
print('Data Prepped!')