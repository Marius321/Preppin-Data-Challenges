SELECT *
FROM [dbo].[PD 2023 Wk 1 Input];

/* Input the data (help)
Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction (help)
Rename the new field with the Bank code 'Bank'. 
Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 
Change the date to be the day of the week (help)
Different levels of detail are required in the outputs. You will need to sum up the values of the transactions in three ways (help):
1. Total Values of Transactions by each bank
2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
3. Total Values by Bank and Customer Code
Output each data file (help) */

-- Create Output 1 Table
CREATE TABLE W1_2023_Output1 (
	Bank char(3),
	Value int);

-- Total Values of Transactions by each bank
INSERT INTO [dbo].[W1_2023_Output1]
SELECT LEFT(transaction_code,CHARINDEX('-',transaction_code)-1) AS Bank, --Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction
	Sum(value) AS Value
FROM [dbo].[PD 2023 Wk 1 Input]
GROUP BY LEFT(transaction_code,CHARINDEX('-',transaction_code)-1);

-- Execute to check whether the table was created and updated successfully
SELECT *
FROM [dbo].[W1_2023_Output1]

---- Create Output 2 Table
CREATE TABLE W1_2023_Output2 (
	Bank char(3),
	Online_Or_In_Person varchar(9),
	Transaction_Date varchar(9),
	Value int
	);

-- Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
WITH cte (Bank, Online_Or_In_Person, Transaction_Date, value)
AS
(
	SELECT LEFT(transaction_code,CHARINDEX('-',transaction_code)-1) AS Bank, --Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction
	CASE Online_or_In_Person WHEN 1 THEN 'Online' 
		ELSE 'In-Person' END AS Online_Or_In_Person,
	DATENAME(WEEKDAY,transaction_date) as Transaction_Date,
	value
FROM [dbo].[PD 2023 Wk 1 Input]
)
INSERT INTO W1_2023_Output2
SELECT Bank,
	Online_Or_In_Person,
	Transaction_Date,
	SUM(Value)
FROM cte
GROUP BY Bank, Transaction_Date, Online_Or_In_Person;

-- Execute to check whether the table was created and updated successfully
SELECT *
FROM [dbo].[W1_2023_Output2];

---- Create Output 3 Table
CREATE TABLE W1_2023_Output3 (
	Bank char(3),
	Customer_Code char(6),
	Value int
	);

--Total Values by Bank and Customer Code
WITH cte (Bank, Customer_Code, value)
AS
(
	SELECT LEFT(transaction_code,CHARINDEX('-',transaction_code)-1) AS Bank, --Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction
	Customer_Code,
	value
FROM [dbo].[PD 2023 Wk 1 Input]
)
INSERT INTO W1_2023_Output3
SELECT Bank,
	Customer_Code,
	SUM(Value)
FROM cte
GROUP BY Bank, Customer_Code;

-- Execute to check whether the table was created and updated successfully
SELECT *
FROM [dbo].[W1_2023_Output3];
