/*
Input the data
For the Transaction Path table:
Make sure field naming convention matches the other tables
i.e. instead of Account_From it should be Account From
For the Account Information table:
Make sure there are no null values in the Account Holder ID
Ensure there is one row per Account Holder ID
Joint accounts will have 2 Account Holders, we want a row for each of them
For the Account Holders table:
Make sure the phone numbers start with 07
Bring the tables together
Filter out cancelled transactions 
Filter to transactions greater than £1,000 in value 
Filter out Platinum accounts
Output the data
*/
WITH aicte AS 
(
SELECT Account_Number,
	Account_Type,
	Balance_Date,
	Balance,
	LEFT(Account_Holder_ID, CHARINDEX(',', Account_Holder_ID + ',') - 1) AS Account_Holder_ID
FROM [dbo].[W7_Account_Information]

UNION ALL

SELECT Account_Number,
	Account_Type,
	Balance_Date,
	Balance,
	STUFF(Account_Holder_ID, 1, CHARINDEX(',', Account_Holder_ID + ','), '') AS Account_Holder_ID
FROM [dbo].[W7_Account_Information]
WHERE STUFF(Account_Holder_ID, 1, CHARINDEX(',', Account_Holder_ID + ','), '') > ''
)

SELECT [dbo].[W7_Transaction_Detail].Transaction_ID,
	Account_To,
	Transaction_Date,
	Value,
	Account_Number,
	Account_Type,
	Balance_Date,
	Balance,
	Name,
	Date_of_Birth,
	CONCAT('0',Contact_Number) AS Contact_Number,
	First_Line_of_Address
FROM [dbo].[W7_Account_Holders] ah
INNER JOIN aicte ON ah.Account_Holder_ID = aicte.Account_Holder_ID
INNER JOIN [dbo].[W7_Transaction_Path] ON aicte.Account_Number = [dbo].[W7_Transaction_Path].Account_From
INNER JOIN [dbo].[W7_Transaction_Detail] ON [dbo].[W7_Transaction_Path].Transaction_ID = [dbo].[W7_Transaction_Detail].Transaction_ID
WHERE Cancelled=0
	AND Value>1000
	AND Account_Type!='Platinum';
