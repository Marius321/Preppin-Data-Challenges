/*
Input the data
In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string (hint)
Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account (hint)
Add a field for the Country Code (hint)
Hint: all these transactions take place in the UK so the Country Code should be GB
Create the IBAN as above (hint)
Hint: watch out for trying to combine string fields with numeric fields - check data types
Remove unnecessary fields (hint)
Output the data
*/

-- CTE that does all of the transformations
WITH cte (Transaction_ID,Account_Number,SWIFT_code,Check_Digits,Sort_Code,Country_Code)
AS
(
SELECT Transaction_ID,
	Account_Number,
	SWIFT_code,
	Check_Digits,
	REPLACE(a.Sort_Code,'-','') AS Sort_Code,
	'GB' AS Country_Code
FROM [dbo].[W2_Transactions] AS a
INNER JOIN [dbo].[W2_Swift_Codes] AS b
ON a.Bank = b.Bank
)

-- Selecting Transaction_ID column from CTE and adding the rest of the columns to form IBAN
SELECT Transaction_ID,
	Country_Code + Check_Digits + SWIFT_code + Sort_Code + CAST(Account_Number AS nvarchar) AS IBAN
FROM cte;