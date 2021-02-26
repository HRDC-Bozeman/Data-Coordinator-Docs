WITH Clients AS(
SELECT  AFS.TotalIncome
	   , CASE
			WHEN S.ClientID IS NOT NULL THEN 'Yes'
			ELSE 'No'
		END 'Senior Services'
	   , CASE
			WHEN S2.ClientID IS NOT NULL THEN 'Yes'
			ELSE 'No'
		END 'All Services'
	   , CASE
			WHEN dbo.ufn_ClientAge(C.BirthDate, '01/01/2020') >= 60 THEN 'Yes'
			ELSE 'No'
		END 'All Seniors'
FROM Client C
	INNER JOIN Assessment a1
		ON a1.ClientID = C.EntityID
	LEFT OUTER JOIN Assessment a2
		ON (C.EntityID = a2.ClientID
		    AND (a1.BeginAssessment < a2.BeginAssessment 
			OR (a1.BeginAssessment = a2.BeginAssessment AND a1.AssessmentID < a2.AssessmentID)))
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = a1.AssessmentID
	LEFT JOIN (SELECT DISTINCT EM.ClientID
			   FROM Service S
					INNER JOIN EnrollmentMember EM
						ON EM.EnrollmentID = S.ProvidedToEntityID
					INNER JOIN Account A
						ON A.AccountID = S.AccountID
					INNER JOIN Enrollment E
						ON E.EnrollmentID = S.EnrollmentID
					INNER JOIN Program P
						ON P.ProgramID = E.ProgramID
			   WHERE (S.BeginDate BETWEEN '01/01/2020' AND '12/31/2020')
			         AND (P.ProgramName IN ('Senior Nutrition', 'CSFP', 'CSFP - WIC', 'Homemaker Services', 'Senior Reach', 'Homemaker Services - PC', 'RSVP') 
					      OR (A.AccountName IN ('Senior Reach','Sherwood Service Coordinator','Senior Groceries','Homemaker Services')))
					 ) S
		ON S.ClientID = C.EntityID
	LEFT JOIN (SELECT DISTINCT EM.ClientID 'ClientID'
			   FROM Service S
					INNER JOIN EnrollmentMember EM
						ON EM.EnrollmentID = S.EnrollmentID
			   WHERE (S.BeginDate BETWEEN '01/01/2020' AND '12/31/2020')
			   ) S2
		ON S2.ClientID = C.EntityID
WHERE a2.AssessmentID IS NULL
)

SELECT [Senior Services]
       , [All Services]
	   , [All Seniors]
	   , COUNT(*)
	   , AVG(TotalIncome) 'Average Income'
	   , SUM(CASE WHEN TotalIncome IS NULL THEN 1 ELSE 0 END) 'No Data'
	   , COUNT(TotalIncome) 'Data Recorded'
FROM Clients
WHERE [All Seniors] = 'Yes'
GROUP BY Clients.[Senior Services], Clients.[All Services], Clients.[All Seniors] WITH ROLLUP
ORDER BY Clients.[Senior Services] DESC, Clients.[All Services] DESC, Clients.[All Seniors] DESC




/*
SELECT * FROM Assessment
SELECT * FROM AssessFinancialSummary
SELECT * FROM Account
SELECT * FROM Program
*/