#Preppin Data 2023 W01

import pandas as pd

#Import the W1 File
df = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 1\Input\PD 2023 Wk 1 Input.csv")

pd.options.display.max_columns = None

#Split the Transaction Code to extract the letters at the start of the transaction code. 
#These identify the bank who processes the transaction (help)
#Rename the new field with the Bank code 'Bank'. 
df['Bank'] = df['Transaction Code'].str.split('-', expand=True)[0]

#Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values.
df['Online or In-Person'] = df['Online or In-Person'].replace({1:'Online',2:'In Person'})

#Change the date to be the day of the week (help)
df['Transaction Date'] = pd.to_datetime(df['Transaction Date'], format='%d/%m/%Y %H:%M:%S')
df['Transaction Date'] = df['Transaction Date'].dt.day_name()

#Different levels of detail are required in the outputs. You will need to sum up the values of the transactions in three ways (help):
#1. Total Values of Transactions by each bank
#2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
#3. Total Values by Bank and Customer Code

output_1 = df.groupby(['Bank'],as_index=False)['Value'].sum()
output_2 = df.groupby(['Bank','Online or In-Person','Transaction Date'],as_index=False)['Value'].sum()
output_3 = df.groupby(['Bank','Customer Code'],as_index=False)['Value'].sum()

output_1.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 1\Output\output1.csv', index=False)
output_2.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 1\Output\output2.csv', index=False)
output_3.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 1\Output\output3.csv', index=False)

print('Hurray! Data prepped.')
