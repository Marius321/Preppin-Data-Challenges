/*Input the data
For the Transaction Path table:
Make sure field naming convention matches the other tables
i.e. instead of Account_From it should be Account From
Filter out the cancelled transactions
Split the flow into incoming and outgoing transactions 
Bring the data together with the Balance as of 31st Jan 
Work out the order that transactions occur for each account
Hint: where multiple transactions happen on the same day, assume the highest value transactions happen first
Use a running sum to calculate the Balance for each account on each day (hint)
The Transaction Value should be null for 31st Jan, as this is the starting balance
Output the data*/

WITH cte AS (
  SELECT *,
    RANK() OVER(PARTITION BY Account_Number ORDER BY Balance_Date ASC, Balance DESC) AS Transaction_Order
  FROM (
	--- Incoming Transactions
    SELECT
      tp.Account_To AS Account_Number,
      td.Transaction_Date AS Balance_Date,
      Value AS Balance
    FROM [dbo].[W7_Transaction_Path] tp
    INNER JOIN [dbo].[W7_Transaction_Detail] td ON tp.Transaction_ID = td.Transaction_ID
	WHERE Cancelled=0
   
    UNION

    ---Outgoing Transactions
    SELECT
      tp.Account_From,
      td.Transaction_Date,
      Value * (-1)
    FROM [dbo].[W7_Transaction_Path] tp
    INNER JOIN [dbo].[W7_Transaction_Detail] td ON tp.Transaction_ID = td.Transaction_ID
	WHERE Cancelled=0

	UNION

	SELECT Account_Number,
	Balance_Date,
	Balance
	FROM W7_Account_Information

  ) a
)
---Work out the order that transactions occur for each account
---Hint: where multiple transactions happen on the same day, assume the highest value transactions happen first

SELECT a.Account_Number,
	a.Balance_Date,
		CASE WHEN a.Transaction_Order = 1 THEN NULL ELSE ROUND(a.Balance,2) END AS Transaction_Value,
	ROUND(SUM(b.Balance),2) AS Balance
FROM cte a
INNER JOIN cte b ON a.Account_Number = b.Account_Number
AND a.Transaction_Order >= b.Transaction_Order
GROUP BY a.Transaction_Order, a.Account_Number, a.Balance_Date, a.Balance;