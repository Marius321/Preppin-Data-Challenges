import pandas as pd
pd.options.display.max_columns = None

#Input the data
df_t=pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 2\Inputs\W2_Transactions.csv")
df_sc=pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 2\Inputs\W2_Swift_Codes.csv")

#In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string (hint)
df_t['Sort Code']= df_t['Sort Code'].str.replace('-','')

#Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account (hint)
merged_data = pd.merge(df_t, df_sc, how='inner', on='Bank')

#Add a field for the Country Code (hint)
#Hint: all these transactions take place in the UK so the Country Code should be GB
merged_data['Country Code'] = 'GB'

#Create the IBAN as above (hint)
#Hint: watch out for trying to combine sting fields with numeric fields - check data types
merged_data['IBAN']=merged_data['Country Code'] + merged_data['Check Digits'] + merged_data['SWIFT code'] \
+ merged_data['Sort Code'] + merged_data['Account Number'].apply(str)

#Remove unnecessary fields (hint)
output = merged_data[['Transaction ID', 'IBAN']]

#Output the data
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 2\Outputs\output.csv', index=False)

print('Well done, data prepped!')