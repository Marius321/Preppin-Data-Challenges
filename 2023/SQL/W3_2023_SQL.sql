/*
Input the data
For the transactions file:
Filter the transactions to just look at DSB (help)
These will be transactions that contain DSB in the Transaction Code field
Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
Change the date to be the quarter (help)
Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
For the targets file:
Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
 Rename the fields
Remove the 'Q' from the quarter field and make the data type numeric (help)
Join the two datasets together (help)
You may need more than one join clause!
Remove unnecessary fields
Calculate the Variance to Target for each row (help)
Output the data
*/

WITH cte
AS
(
SELECT
	CASE Online_or_In_Person
	WHEN 1 THEN 'Online'
	WHEN 2 THEN 'In-Person' 
	END AS Online_or_In_Person,
	DATEPART(Quarter,Transaction_Date) AS Quarter,
	SUM(Value) AS Value
	FROM [dbo].[PD 2023 Wk 1 Input] AS transactions
WHERE Transaction_Code LIKE 'DSB%'
GROUP BY DATEPART(Quarter,Transaction_Date), Online_or_In_Person
)

SELECT p.Online_or_In_Person,
	REPLACE(p.Quarter,'Q','') AS Quarter,
	cte.Value,
	Quaterly_targets,
	cte.Value - Quaterly_targets AS variance_to_target
FROM [dbo].[Targets] AS t
UNPIVOT(Quaterly_targets for Quarter IN (Q1,Q2,Q3,Q4)) AS p
INNER JOIN cte ON p.Online_or_In_Person=cte.Online_or_In_Person
AND REPLACE(p.Quarter,'Q','')=cte.Quarter