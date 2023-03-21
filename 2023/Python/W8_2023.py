import pandas as pd
import glob
import os
import calendar

pd.options.display.max_columns = None

#Input each of the 12 monthly files
#Create a 'file date' using the month found in the file name
csv_files = glob.glob(r'C:/Users/Marius/Documents/Prepping Data/2023 Week 8/Inputs/*.csv')
merged_data = pd.DataFrame()

for file in csv_files:
    data = pd.read_csv(file)
    base_name = os.path.splitext(os.path.basename(file))[0]
    data['File Date'] = base_name
    merged_data = pd.concat([merged_data, data])
   
merged_data.loc[merged_data['File Date'] == 'MOCK_DATA', 'File Date'] = 'MOCK_DATA-1'
merged_data['File Date'] = merged_data['File Date'].str.extract(r'(\d+)').astype(int)
merged_data['File Date'] = merged_data['File Date'].apply(lambda x: calendar.month_name[x])

#Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
#Remove any rows with 'n/a'
merged_data = merged_data.dropna(subset='Market Cap').reset_index(drop=True)

#Categorise the Purchase Price into groupings
#0 to 24,999.99 as 'Low'
#25,000 to 49,999.99 as 'Medium'
#50,000 to 74,999.99 as 'High'
#75,000 to 100,000 as 'Very High'

merged_data['Purchase Price'] = merged_data['Purchase Price'].str.replace('$','', regex=False)
merged_data['Purchase Price'] = pd.to_numeric(merged_data['Purchase Price'], errors='coerce')

bins_pp = [0,24999.99,49999.99,74999.99,100000]
labels_pp = ['Low', 'Medium', 'High', 'Very High']
merged_data['Purchase Price Categorisation'] = pd.cut(merged_data['Purchase Price'], bins=bins_pp, labels=labels_pp)


#Categorise the Market Cap into groupings
#Below $100M as 'Small'
#Between $100M and below $1B as 'Medium'
#Between $1B and below $100B as 'Large' 
#$100B and above as 'Huge'
print(merged_data)
merged_data['Market Cap'] = merged_data['Market Cap'].str.replace('$','', regex=False)

def convert_market_cap(val):
    if val.endswith('M'):
        return float(val[0:-1]) * 1000000
    elif val.endswith('B'):
        return float(val[0:-1]) * 1000000000
    else:
        return float(val)

merged_data['Market Cap'] = merged_data['Market Cap'].apply(convert_market_cap)

def categorize_market_cap(val):
    if val < 100000000:
        return 'Small'
    elif val < 1000000000:
        return 'Medium'
    elif val < 100000000000:
        return 'Large'
    elif val >= 100000000000:
        return 'Huge'
    else:
        return 'Unknown'
    
merged_data['Market Capitalisation Categorisation'] = merged_data['Market Cap'].apply(categorize_market_cap)



merged_data = merged_data.iloc[:,[11,10,9,3,4,5,6,7,8]]
print(merged_data)

merged_data['Rank'] = merged_data.groupby(['File Date', 'Purchase Price Categorisation','Market Capitalisation Categorisation'])['Purchase Price'].rank(ascending=False)
print(merged_data)

#Output only records with a rank of 1 to 5
output = merged_data[merged_data['Rank']<=5]
print(output)
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 8\Outputs\W8_2023_Output_py.csv', index=False)