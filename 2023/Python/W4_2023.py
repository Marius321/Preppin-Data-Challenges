import pandas as pd

#Input the data
#We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways (help):
#Drag each table into the canvas and use a union step to stack them on top of one another
#Use a wildcard union in the input step of one of the tables
excel = pd.ExcelFile(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 4\Inputs\New Customers.xlsx')
sheet_names = excel.sheet_names

all_data = pd.DataFrame()
for sheet_name in sheet_names:
    data = pd.read_excel(excel, sheet_name)
    data['Table Name'] = sheet_name
    all_data = pd.concat([all_data, data])

#Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
all_data['Demographic'] = all_data['Demographic'].fillna(all_data['Demographiic']).fillna(all_data['Demagraphic'])
all_data = all_data.iloc[:,[0,1,2,3,4]]

#Make a Joining Date field based on the Joining Day, Table Names and the year 2023
all_data['Joining Date'] = all_data['Joining Day'].astype(str) + ' ' + all_data['Table Name'] + ' ' + '2023'
all_data['Joining Date'] = pd.to_datetime(all_data['Joining Date'], format='%d %B %Y')


#Now we want to reshape our data so we have a field for each demographic, for each new customer (help)
pivoted_data = all_data.pivot(index=['ID','Joining Date'], columns='Demographic', values='Value').reset_index()

#Remove duplicates (help)
#If a customer appears multiple times take their earliest joining date
df_sorted = pivoted_data.sort_values(by=['ID', 'Joining Date'], ascending=True)
df_unique = df_sorted.drop_duplicates(subset='ID', keep='first')
output = df_unique.sort_values(by=['ID','Joining Date'], ascending=True)

#Output the data
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 4\Outputs\output.csv',index=False)

print('Data Prepped!')