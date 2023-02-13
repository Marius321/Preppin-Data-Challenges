/*
Input the data
We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways (help):
Drag each table into the canvas and use a union step to stack them on top of one another
Use a wildcard union in the input step of one of the tables
Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
Make a Joining Date field based on the Joining Day, Table Names and the year 2023
Now we want to reshape our data so we have a field for each demographic, for each new customer (help)
Make sure all the data types are correct for each field
Remove duplicates (help)
If a customer appears multiple times take their earliest joining date
Output the data
*/

WITH CTE AS (
SELECT *, 'april' AS table_name
FROM [dbo].[April$]
UNION ALL
SELECT *, 'august' AS table_name
FROM [dbo].[August$]
UNION ALL 
SELECT *, 'december' AS table_name
FROM [dbo].[December$]
UNION ALL
SELECT *, 'february' AS table_name
FROM [dbo].[February$]
UNION ALL 
SELECT *, 'january' AS table_name
FROM [dbo].[January$]
UNION ALL
SELECT *, 'july' AS table_name
FROM [dbo].[July$]
UNION ALL
SELECT *, 'june' AS table_name
FROM [dbo].[June$]
UNION ALL
SELECT *, 'march' AS table_name
FROM [dbo].[March$]
UNION ALL
SELECT *, 'may' AS table_name
FROM [dbo].[May$]
UNION ALL
SELECT *, 'november' AS table_name
FROM [dbo].[November$]
UNION ALL
SELECT *, 'october' AS table_name
FROM [dbo].[October$]
UNION ALL
SELECT *, 'september' AS table_name
FROM [dbo].[September$]
)

SELECT CAST(pvt.ID AS int) AS ID,
MIN(CAST(CONCAT([Joining Day], ' ',table_name, ' ',2023) AS date)) AS [Joining Date],
CAST(Ethnicity AS varchar) AS Ethnicity,
CAST([Date of Birth] AS date) AS [Date of Birth],
CAST([Account Type] AS varchar) AS [Account Type]
FROM CTE
PIVOT 
(
MIN(Value)
FOR Demographic IN (Ethnicity, [Date of Birth], [Account Type]) 
) AS Pvt
GROUP BY ID, Ethnicity, [Date of Birth], [Account Type]