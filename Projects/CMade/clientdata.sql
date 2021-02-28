SELECT C.EntityID
	   , C.LastName
	   , C.FirstName
	   , C.MiddleName
	   , C.Gender
	   , FORMAT(C.BirthDate, 'MM/dd/yyyy') 'BirthDate'
	   , C.SSN
	   , CR.RaceName 'Race'
	   , C.Ethnicity
	   , Ca1.Address1
	   , Ca1.ZipCode
	   , Ca1.County
	   , ECP.CellPhone
	   , ECP.HomePhone
	   , ECP.Email
	   , C.VeteranStatus
	   , C.PrimaryLanguage
	   , Fcount.Members
	   , Latest.[Prior Residence]
	   , Latest.[Highest Grade Completed]
	   , Latest.[Marital Status]
	   , Latest.[Active Military]
	   , AFS.TotalIncome
FROM Client C
	INNER JOIN ClientAddress Ca1
		ON Ca1.ClientID = C.EntityID
	LEFT OUTER JOIN ClientAddress Ca2
		ON (C.EntityID = Ca2.ClientID
		    AND (Ca1.BeginDate < Ca2.BeginDate
			OR ( Ca1.BeginDate = Ca2.BeginDate AND Ca1.AddressID < Ca2.AddressID)))
	INNER JOIN EntityContactPreference ECP
		ON ECP.EntityID = C.EntityID
	INNER JOIN FamilyMember FM
		ON FM.ClientID = C.EntityID
		   AND FM.DateRemoved > GETDATE()
	INNER JOIN (SELECT F.FamilyName, F.FamilyID, COUNT(*) 'Members'
				FROM Family F
					INNER JOIN FamilyMember FM
						ON FM.FamilyID = F.FamilyID
						   AND FM.DateRemoved > GETDATE()
				GROUP BY F.FamilyName, F.FamilyID) Fcount
		ON Fcount.FamilyID = FM.FamilyID
	INNER JOIN X_UVW_LatestNonNullAssess Latest
		ON Latest.ClientID = C.EntityID
	INNER JOIN Assessment a1
		ON a1.ClientID = C.EntityID
	LEFT OUTER JOIN Assessment a2
		ON (C.EntityID = a2.ClientID
		    AND (a1.BeginAssessment < a2.BeginAssessment 
			OR (a1.BeginAssessment = a2.BeginAssessment AND a1.AssessmentID < a2.AssessmentID)))
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = a1.AssessmentID
	LEFT JOIN UVW_ClientRace CR
		ON CR.ClientID = C.EntityID
WHERE Ca2.AddressID IS NULL 
      AND a2.AssessmentID IS NULL
	  AND C.EntityID = **ClientID**


