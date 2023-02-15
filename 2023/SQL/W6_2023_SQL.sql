/*
Input the data
Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
Clean the question categories so they don't have the platform in from of them
e.g. Mobile App - Ease of Use should be simply Ease of Use
Exclude the Overall Ratings, these were incorrectly calculated by the system
Calculate the Average Ratings for each platform for each customer 
Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
Catergorise customers as being:
Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
Mobile App Fans if difference >= 1
Online Interface Fan
Online Interface Superfan
Neutral if difference is between 0 and 1
Calculate the Percent of Total customers in each category, rounded to 1 decimal place
Output the data
*/
	
SELECT Preference,
	ROUND(CAST(COUNT(Preference) AS float) / CAST (SUM(COUNT(Preference)) OVER () AS float)*100,1)
FROM (SELECT
		CASE
		WHEN Difference>=2 THEN 'Mobile App Superfan'
		WHEN Difference>=1 AND Difference<2 THEN 'Mobile App Fan'
		WHEN Difference<=-2 THEN 'Online Interface Superfan'
		WHEN Difference<=-1 AND Difference>-2 THEN 'Online Interface Fan'
		ELSE 'Neutral'
		END AS Preference
	FROM (
		SELECT t1.Customer_ID,
			t1.Question,
			Mobile,
			AVG(CAST(Mobile AS float)) OVER (PARTITION BY t1.Customer_ID) AS Average_Rating_Mobile,
			Online,
			AVG(CAST(Online AS float)) OVER (PARTITION BY t1.Customer_ID) AS Average_Rating_Online,
			AVG(CAST(Mobile AS float)) OVER (PARTITION BY t1.Customer_ID) - AVG(CAST(Online AS float)) OVER (PARTITION BY t1.Customer_ID) AS Difference
		FROM
			(SELECT m.Customer_ID,
				SUBSTRING(m.Question, CHARINDEX('_', m.Question, CHARINDEX('_', m.Question)+1)+1, LEN(m.Question)) AS Question,
				Mobile
			FROM [dbo].[DSB Customer Survery]
			UNPIVOT (Mobile FOR Question IN ([Mobile_App_Ease_of_Use],[Mobile_App_Ease_of_Access],[Mobile_App_Navigation],[Mobile_App_Likelihood_to_Recommend],[Mobile_App_Overall_Rating])) m) t1
		INNER JOIN
			(SELECT Customer_ID,
				SUBSTRING(Question, CHARINDEX('_', Question, CHARINDEX('_', Question)+1)+1, LEN(Question)) AS Question,
				Online
			FROM [dbo].[DSB Customer Survery]
			UNPIVOT (Online FOR Question IN ([Online_Interface_Ease_of_Use],[Online_Interface_Ease_of_Access],[Online_Interface_Navigation],[Online_Interface_Likelihood_to_Recommend],[Online_Interface_Overall_Rating])) o) t2
		ON t1.Customer_ID=t2.Customer_ID
			AND t1.Question=t2.Question
		WHERE t1.Question!='Overall_Rating'
		) sub1) sub2
GROUP BY Preference;