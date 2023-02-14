/*
Input data
Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
Change transaction date to the just be the month of the transaction
Total up the transaction values so you have one row for each bank and month combination
Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
Without losing all of the other data fields, find:
The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
Output the data
*/

WITH CTE AS (
SELECT LEFT(Transaction_Code,CHARINDEX('-',Transaction_Code)-1) AS Bank,
DATENAME(month,Transaction_Date) AS Transaction_Date,
Value
FROM [dbo].[PD 2023 Wk 1 Input]
)

SELECT Transaction_Date,
	Bank,
	Value,
	Rank,
	AVG(CAST(Value AS float)) OVER(PARTITION BY Rank) AS Avg_Transaction_Value_per_Bank,
	AVG(CAST(Rank AS float)) OVER(PARTITION BY Bank) AS Avg_Rank_per_Bank
	FROM 
		(
		SELECT Bank,
			Transaction_Date,
			SUM(Value) AS Value,
			RANK() OVER(PARTITION BY Transaction_Date ORDER BY SUM(Value) DESC) Rank
		FROM CTE
		GROUP BY Bank,Transaction_Date
		) a
		ORDER BY Transaction_Date, Rank