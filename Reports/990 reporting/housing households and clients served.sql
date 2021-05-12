WITH CTE AS(
SELECT S.ProvidedToEntityID 'HoH Client ID'
	   , MAX(E.FamilyID) 'Family ID'
	   , COUNT(DISTINCT FM.ClientID) 'Family Members' 
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN FamilyMember FM
		ON FM.FamilyID = E.FamilyID AND S.BeginDate BETWEEN FM.DateAdded AND FM.DateRemoved
WHERE (A.AccountName IN ('Housing First','Housing Choice Voucher') OR P.ProgramName = 'Section 8 Housing' OR P.ProgramName = 'Home to Stay')
      AND S.BeginDate BETWEEN '01/01/2020' AND '12/31/2020'
GROUP BY S.ProvidedToEntityID
)

SELECT COUNT([HoH Client ID])
       , SUM([Family Members]) 
FROM CTE
GROUP BY 