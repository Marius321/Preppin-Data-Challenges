WITH cte AS (
    SELECT *,
	ROUND(3963 * ACOS((SIN([Address Lat]) * SIN([Branch Lat])) + COS([Address Lat]) * COS([Branch Lat]) * COS([Branch Long] - [Address Long])),2) AS Distance,
	MIN(ROUND(3963 * ACOS((SIN([Address Lat]) * SIN([Branch Lat])) + COS([Address Lat]) * COS([Branch Lat]) * COS([Branch Long] - [Address Long])),2)) OVER (PARTITION BY Customer) AS "Min Distance"
	FROM (
	SELECT Customer,
        Address_Long/(180/PI()) AS [Address Long],
		Address_Long AS Address_Long,
        Address_Lat/(180/PI()) AS [Address Lat],
		Address_Lat AS Address_Lat,
        Branch,
        Branch_Long/(180/PI()) AS [Branch Long],
		Branch_Long AS Branch_Long,
        Branch_Lat/(180/PI()) AS [Branch Lat],
		Branch_Lat As Branch_Lat
    FROM [dbo].[DSB Customer Locations]
    CROSS JOIN [dbo].[DSB Branches]
	) a
)

SELECT Branch,
	ROUND(Branch_Long,6),
	ROUND(Branch_Lat,6),
	Distance,
	RANK() OVER(PARTITION BY Branch ORDER BY Distance) AS [Customer Priority],
	Customer,
	ROUND(Address_Long,6),
	ROUND(Address_Lat,6)
FROM cte
WHERE Distance = [Min Distance];