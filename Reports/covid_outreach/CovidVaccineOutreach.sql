SELECT DISTINCT S.ProvidedToEntityID 'ClientID'
                , E.FamilyID 'FamilyID'
				,C.FirstName
				, C.LastName
				, ECP.HomePhone
				, ECP.WorkPhone
				, ECP.CellPhone
				, ECP.Email
				, CA.Address1
				, CA.ZipCode
				, CA.City
				, CA.County
				, dbo.ufn_ClientAge(C.BirthDate, GETDATE()) 'Age'
				, (SELECT ListLabel FROM ListItem WHERE ListID = Assess.DisListID AND ListValue = Assess.[Disabling Condition]) 'Disabling Condition'
				, CR.RaceName 'Client Race'
				, EU.EntityName 'Last Staff Contact'
				, CONVERT(DATE, S2.BeginDate) 'Date'
				, A.AccountName 'Program'
				--, P.ProgramName 'Enrollment Type'
FROM Service S
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	LEFT JOIN ClientAddress CA
		ON CA.ClientID = C.EntityID
		   AND CA.AddressType = 1
	INNER JOIN X_UVW_LatestNonNullAssess Assess
		ON Assess.ClientID = C.EntityID
	INNER JOIN UVW_ClientRace CR
		ON CR.ClientID = C.EntityID
	INNER JOIN ClientSummaryInfo CSI
		ON CSI.ClientID = C.EntityID
	INNER JOIN EntityContactPreference ECP
		ON ECP.EntityID = C.EntityID
	LEFT JOIN (SELECT ProvidedToEntityID, MAX(ServiceID) 'ServiceID'
			    FROM Service
				GROUP BY ProvidedToEntityID) LS
		ON LS.ProvidedToEntityID = S.ProvidedToEntityID
	INNER JOIN Service S2
		ON S2.ServiceID = LS.ServiceID
	INNER JOIN Entity EU
		ON EU.EntityID = S2.ProvidedByEntityID
	INNER JOIN Account A
		ON A.AccountID = S2.AccountID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = S2.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
WHERE --P.ProgramName LIKE 'Homemaker%'
	  --OR P.ProgramName LIKE 'CFSP'
	   -- These are the filters for 80+, or 70+ & Disabled, or black or native American
	   
	   (dbo.ufn_ClientAge(C.BirthDate, GETDATE()) > 60 AND dbo.ufn_ClientAge(C.BirthDate, GETDATE()) < 75)
	   -- OR 
	  AND NOT (dbo.ufn_ClientAge(C.BirthDate, '01/01/2020') > 70 AND Assess.[Disabling Condition] = 1)
	   -- OR
	   AND NOT ((CR.RaceName LIKE '%Native%') OR (CR.RaceName LIKE '%Black%'))
	  
	  AND (NULLIF(ECP.HomePhone, '') IS NOT NULL OR NULLIF(ECP.WorkPhone, '') IS NOT NULL OR NULLIF(ECP.CellPhone, '') IS NOT NULL OR NULLIF(ECP.Email, '') IS NOT NULL)
	  AND CSI.DateOfDeath IS NULL
	  AND CA.County = 'Meagher'
ORDER BY [Date] DESC

--SELECT * FROM ClientAddress

--SELECT * FROM Lists WHERE ListName LIKE '%Address%'
--SELECT ListID, ListValue, ListLabel FROM ListItem WHERE ListID = 5

/*
SELECT DISTINCT S.ProvidedToEntityID, P.ProgramName, A.AccountName, S2.BeginDate, LS.ServiceID
FROM Service S
	INNER JOIN (SELECT ProvidedToEntityID, MAX(ServiceID) 'ServiceID'
			    FROM Service
				GROUP BY ProvidedToEntityID) LS
		ON LS.ProvidedToEntityID = S.ProvidedToEntityID
	INNER JOIN Service S2
		ON S2.ServiceID = LS.ServiceID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = S2.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Account A
		ON A.AccountID = S2.AccountID
*/

