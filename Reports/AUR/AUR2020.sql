SELECT DISTINCT EM.ClientID
       , CASE
			WHEN dbo.ufn_ClientAge(C.BirthDate, GETDATE()) > 17 THEN 'Adult'
			WHEN dbo.ufn_ClientAge(C.BirthDate, GETDATE()) <= 17 THEN 'Minor'
		END 'Age Group' 
	   , (SELECT ListLabel FROM ListItem WHERE ListID = Latest.HHcompListID AND ListValue = Latest.[Household Composition]) 'Household Type'
	   ,CASE
			WHEN Latest.[Disabling Condition] = 1 AND C.VeteranStatus = 2 THEN 'Disabled Non-Veteran'
			WHEN Latest.[Disabling Condition] = 1 AND C.VeteranStatus = 1 THEN 'Disabled Veteran'
			WHEN C.VeteranStatus = 1 THEN 'Veteran'
			WHEN Latest.[Disabling Condition] = 2 THEN 'Not Disabled'

		END 'Veteran'
	   , CR.RaceName
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 7 AND ListValue = C.Ethnicity) 'Ethnicity'
	   , CASE 
			WHEN C.Gender = 1 AND Latest.[Household Composition] = 15 THEN 'Single Male'
			WHEN C.Gender = 2 AND Latest.[Household Composition] = 15 THEN 'Single Female'
			WHEN Latest.[Household Composition] = 10 THEN 'Two Parent'
			ELSE (SELECT ListLabel FROM ListItem WHERE ListID = Latest.HHcompListID AND ListValue = Latest.[Household Composition])
	   END 'Household Composition'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = C.Gender) 'Gender'
	   , E.FamilyID
FROM Service S
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN EnrollmentMember EM
		ON EM.EnrollmentID = S.EnrollmentID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = EM.EnrollmentID
	INNER JOIN Client C
		ON C.EntityID = EM.ClientID
	LEFT JOIN X_UVW_LatestNonNullAssess Latest
		ON Latest.ClientID = EM.ClientID
	INNER JOIN UVW_ClientRace CR
		ON CR.ClientID = EM.ClientID
WHERE (S.BeginDate BETWEEN '01/01/2020' AND '12/31/2020')
      AND A.AccountName IN ('Warming Center'
	                        , 'Housing First'
							, 'Housing Choice Voucher'
							, 'Warming Center - Livingston'
							, 'Housing Navigation'
							, 'Homeownership Center'
							, 'Down Payment Assistance')
	  AND S.DeletedDate > GETDATE()