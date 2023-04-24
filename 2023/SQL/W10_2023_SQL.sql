/* Input the data
Aggregate the data so we have a single balance for each day already in the dataset, for each account
Scaffold the data so each account has a row between 31st Jan and 14th Feb (hint)
Make sure new rows have a null in the Transaction Value field
Create a parameter so a particular date can be selected
Filter to just this date
Output the data - making it clear which date is being filtered to */

WITH DateRange AS (
  SELECT CAST('2023-01-31' AS DATE) AS DateValue
  UNION ALL
  SELECT DATEADD(day, 1, DateValue)
  FROM DateRange
  WHERE DateValue < '2023-02-14'
),
DistinctAccounts AS (
	SELECT DISTINCT Account_Number
	FROM [dbo].[Account Statements]
)
SELECT DistinctAccounts.Account_Number,
	DateRange.DateValue AS Balance_Date,
	Transaction_Value,
	Balance
FROM DateRange
CROSS JOIN DistinctAccounts
LEFT JOIN (
SELECT Account_Number,
		Balance_Date,
		SUM(Transaction_Value) AS Transaction_Value,
		Balance
FROM [dbo].[Account Statements]
GROUP BY Account_Number, Balance_Date, Balance ) AS b
ON DateRange.DateValue = b.Balance_Date 
AND DistinctAccounts.Account_Number = b.Account_Number
ORDER BY DistinctAccounts.Account_Number, DateRange.DateValue;