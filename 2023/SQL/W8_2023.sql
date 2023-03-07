/*
Input each of the 12 monthly files
Create a 'file date' using the month found in the file name
The Null value should be replaced as 1
Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
Remove any rows with 'n/a'
Categorise the Purchase Price into groupings
0 to 24,999.99 as 'Low'
25,000 to 49,999.99 as 'Medium'
50,000 to 74,999.99 as 'High'
75,000 to 100,000 as 'Very High'
Categorise the Market Cap into groupings
Below $100M as 'Small'
Between $100M and below $1B as 'Medium'
Between $1B and below $100B as 'Large' 
$100B and above as 'Huge'
Rank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
Output only records with a rank of 1 to 5
*/

WITH CombinedTable AS (
  SELECT *, 'MOCK_DATA-1' AS table_name FROM [MOCK_DATA]
  UNION ALL
  SELECT *, 'MOCK_DATA-2' AS table_name FROM [MOCK_DATA-2]
  UNION ALL
  SELECT *, 'MOCK_DATA-3' AS table_name FROM [MOCK_DATA-3]
  UNION ALL
  SELECT *, 'MOCK_DATA-4' AS table_name FROM [MOCK_DATA-4]
  UNION ALL
  SELECT *, 'MOCK_DATA-5' AS table_name FROM [MOCK_DATA-5]
  UNION ALL
  SELECT *, 'MOCK_DATA-6' AS table_name FROM [MOCK_DATA-6]
  UNION ALL
  SELECT *, 'MOCK_DATA-7' AS table_name FROM [MOCK_DATA-7]
  UNION ALL
  SELECT *, 'MOCK_DATA-8' AS table_name FROM [MOCK_DATA-8]
  UNION ALL
  SELECT *, 'MOCK_DATA-9' AS table_name FROM [MOCK_DATA-9]
  UNION ALL
  SELECT *, 'MOCK_DATA-10' AS table_name FROM [MOCK_DATA-10]
  UNION ALL
  SELECT *, 'MOCK_DATA-11' AS table_name FROM [MOCK_DATA-11]
  UNION ALL
  SELECT *, 'MOCK_DATA-12' AS table_name FROM [MOCK_DATA-12]
)
SELECT *
FROM (
SELECT 	Market_Capitalisation_Category,
	Purchase_Price_Category,
	file_date,
	Ticker,
	Sector,
	Market,
	Stock_Name,
	Market_Capitalisation,
	Purchase_Price,
	RANK() OVER(PARTITION BY file_date, Purchase_Price_Category, Market_Capitalisation_Category ORDER BY SUM(Purchase_Price) DESC) AS Rank
FROM (
	SELECT *,
		DATENAME(month,DATEFROMPARTS(2023, RIGHT(table_name,CHARINDEX('-', (REVERSE(table_name))) - 1), 1)) AS file_date,
		CASE WHEN Purchase_Price <= 24999.99 THEN 'Low'
			WHEN Purchase_Price <= 49999.99 THEN 'Medium'
			WHEN Purchase_Price <= 74999.99 THEN 'High'
			ELSE 'Very High'
		END AS Purchase_Price_Category,
		CASE WHEN Market_Capitalisation <= 100000000 THEN 'Small'
			WHEN Market_Capitalisation <= 1000000000 THEN 'Medium'
			WHEN Market_Capitalisation < 100000000000 THEN 'Large'
			ELSE 'Huge'
		END AS Market_Capitalisation_Category
	FROM (
		SELECT *,
			CASE WHEN Market_Cap LIKE '%B' THEN CAST(TRIM(TRANSLATE(Market_Cap,'B$','  ')) AS float) * 1000000000
				ELSE CAST(TRIM(TRANSLATE(Market_Cap,'M$','  ')) AS float) * 1000000
			END AS Market_Capitalisation
		FROM CombinedTable) as sq
	WHERE Market_Cap!='n/a'
) AS sq2
GROUP BY file_date, Purchase_Price_Category, Market_Capitalisation_Category, Ticker, Sector, Market, Stock_Name, Market_Capitalisation, Purchase_Price
) AS sq3
WHERE Rank<=5;