import pandas as pd
pd.options.display.max_columns = None

#Input data
df = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 1\Input\PD 2023 Wk 1 Input.csv")

#Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
df['Bank'] = df['Transaction Code'].str.split('-', expand=True)[0]

#Change transaction date to the just be the month of the transaction
df['Transaction Date'] = pd.to_datetime(df['Transaction Date'], format='%d/%m/%Y %H:%M:%S').dt.month_name()

#Total up the transaction values so you have one row for each bank and month combination
df = df.groupby(by=['Bank', 'Transaction Date'], as_index=False)['Value'].sum()

#Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
df['Bank Rank per Month'] = df.groupby(by=['Transaction Date'])['Value'].rank(ascending=False).apply(int)

#Without losing all of the other data fields, find:
#The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
df['Avg Rank per Bank'] = df.groupby(by=['Bank'])['Bank Rank per Month'].transform('mean')

#The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
df['Avg Transaction Value per Rank'] = df.groupby(by=['Bank Rank per Month'])['Value'].transform('mean')

#Output the data
output = df.iloc[:,[1,0,2,3,5,4]]
output = output.sort_values(by=['Transaction Date', 'Bank Rank per Month'], ascending=True)
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 5\Outputs\output.csv',index=False)

print('Congrats, data prepped!')