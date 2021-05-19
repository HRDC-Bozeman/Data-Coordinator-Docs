SELECT S.ProvidedToEntityID 'EntityID'
       , SUM(S.ServiceTotal) 'Total Units'
	   , COUNT(S.ServiceID) 'Times Served'
	   , MAX(ovr60.[# Over 60]) 'Family Members Over 60'
FROM Service S
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN (SELECT FM.FamilyID, COUNT(FM.ClientID) '# Over 60'
				FROM FamilyMember FM
					INNER JOIN Client C
						ON C.EntityID = FM.ClientID
				WHERE dbo.ufn_ClientAge(C.BirthDate, GETDATE()) >= 60
				      AND FM.DateRemoved > '07/01/2019'
				GROUP BY FM.FamilyID) ovr60
		ON ovr60.FamilyID = E.FamilyID
WHERE A.AccountName IN ('Gallatin Valley Food Bank', 'Senior Groceries')
      AND S.BeginDate BETWEEN '07/01/2019' AND GETDATE()
	  AND ST.Description IN ('Emergency  Food Service','Supplemental Food Service', 'Holiday Food Box')
GROUP BY S.ProvidedToEntityID