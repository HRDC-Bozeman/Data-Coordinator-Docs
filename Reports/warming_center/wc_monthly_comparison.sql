-- Breakdown of total services provided by year, month, and service type

SELECT CONCAT(DATEPART(MONTH, S.BeginDate),'/', DATEPART(Year, S.BeginDate)) 'Month/Year'
       , DATEPART(MONTH, S.BeginDate) 'Month'
	   , DATEPART(Year, S.BeginDate) 'Year'
	   --, ST.Description
       , COUNT(*) 'Services Provided'
	   , COUNT(DISTINCT S.ProvidedToEntityID) 'Unique Clients'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE A.AccountName LIKE 'Warming%'
	  AND DATEPART(Month, S.BeginDate) = 2
	  AND S.DeletedDate > GETDATE()
GROUP BY DATEPART(Year, S.BeginDate)
         , DATEPART(Month, S.BeginDate)
         --, ST.Description
ORDER BY DATEPART(Year, S.BeginDate)
         , DATEPART(Month, S.BeginDate);


-- Change around "SELECT DISTINCT {something} to get different slices of data
-- Use the inner query for one level of aggregation
-- Use the CTE to aggregate aggregated data
WITH CTE AS(
SELECT DISTINCT CONVERT(DATE, S.BeginDate) 'Night'
                , COUNT(*) 'Stays'
    --            , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = C.Gender) 'Gender'
				--, C.Gender 'gender_code'
				--, ST.Description
				--, CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) < 6 THEN 'Under 5'
	   -- 			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN '6 - 11'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN '12 - 17'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 18 AND 25 THEN '18 - 25'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 26 AND 34 THEN '26 - 34'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35 - 44'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55 - 64'
				--	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) > 64 THEN '65+'
				--	END AgeRange
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE A.AccountName LIKE 'Warming%'
	  AND ST.Description IN ('Emergency Temporary Shelter', 'WC-Motel/Hotel')
      AND S.BeginDate BETWEEN '02/01/2020' AND '02/29/2020'
	  AND S.DeletedDate > GETDATE()
GROUP BY S.BeginDate
)

SELECT AVG(Stays)
FROM CTE
