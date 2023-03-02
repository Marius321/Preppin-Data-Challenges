import pandas as pd
pd.options.display.max_columns = None

#Input the data
df = pd.read_csv(r"C:\Users\Marius\Documents\Prepping Data\2023 Week 6\Inputs\DSB Customer Survery.csv")

#Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
df = pd.melt(df, id_vars=['Customer ID'], var_name='Column', value_name='Value')

df['Platform'] = df['Column'].str.split('-', expand=True)[0]
df['Metric'] = df['Column'].str.split('-', expand=True)[1]
df['Platform'] = df['Platform'].str.strip()
df['Metric'] = df['Metric'].str.strip()
df = df.pivot(index=['Customer ID','Metric'], columns='Platform', values='Value').reset_index()

#Exclude the Overall Ratings, these were incorrectly calculated by the system
df = df[df['Metric']!='Overall Rating']

#Calculate the Average Ratings for each platform for each customer 
df['Avg Ratings Mobile'] = df.groupby(by=['Customer ID'])['Mobile App'].transform('mean')
df['Avg Ratings Online'] = df.groupby(by=['Customer ID'])['Online Interface'].transform('mean')

#Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
df['Difference'] = df['Avg Ratings Mobile'] - df['Avg Ratings Online']

#Catergorise customers as being:
#Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
#Mobile App Fans if difference >= 1
#Online Interface Fan
#Online Interface Superfan
#Neutral if difference is between 0 and 1

def categorize (diff):
    if diff >= 2.00:
        return 'Mobile App Superfans'
    elif diff >= 1.00:
        return 'Mobile App Fans'
    elif diff <= -2.00:
        return 'Online Interface Superfans'
    elif diff <= -1.00:
       return 'Online Interface Fans'
    else: 
        return 'Neutral'

df['Preference'] = df['Difference'].apply(categorize)

#Calculate the Percent of Total customers in each category, rounded to 1 decimal place
output = df.groupby(['Preference'], as_index=False)['Difference'].size()
output['Percent of Total'] = round(output['size'] / output['size'].sum() * 100,1)

#Output the data
output = output.iloc[:,[0,2]]
output.to_csv(r'C:\Users\Marius\Documents\Prepping Data\2023 Week 6\Outputs\output.csv',index=False)
print('Data Prepped!')