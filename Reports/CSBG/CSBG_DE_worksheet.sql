SELECT DISTINCT S.ProvidedToEntityID 'ClientID'
				--, A.AccountName 'Location'
				, F.FamilyID
				, C.SSN
				, C.BirthDate
				, E.EntityName 'Client Name'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 4 AND ListValue = FM.RelationToHoH) 'Relation to HoH'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = C.Gender) 'Gender'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 127 AND ListValue = C.CitizenshipStatusID) 'Citizen'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 7 AND ListValue = C.Ethnicity) 'Ethnicity'
				, [RaceList].Races 'Client Race' --Here is a column for race that is a concatenated list of all the races selected
				, CONCAT(EA.Address1, ' ', EA.Address2, ', ', EA.City, ', ', EA.ZipCode) 'Address'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 37 AND ListValue = C.VeteranStatus) 'Veteran'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 37 AND ListValue = C.X_ActiveMilitary) 'Active Military'
				, [InsList].[Health Insurance] 'Health Insurance'--Here is a column for health insurance that is a concatenated list of all the health insurance types selected
				, (SELECT ListLabel FROM ListItem WHERE ListID = 37 AND ListValue = AHU.DisablingCondition) 'Disabling Condition'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 1000000089 AND ListValue = AHP.EmploymentType) 'Employment'
				, [IncomeSources].[Income Sources] 'Income'
				, [NCBs].[Non Cash Benefits] 'Non Cash Benefits'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 1000000063 AND ListValue = AHP.EduHighestGrade) 'Highest Grade'
				, (SELECT ListLabel FROM ListItem WHERE ListID = 37 AND ListValue = AHP.EduInSchool) 'Still Attending School'
				, A.AccountName 'Location'
				, CONVERT(DATE, SL.BeginDate) 'Service Date'
				, ST.Description 'Service Type'
				, SL.ServiceTotal 'Service Total'
FROM Service S
	INNER JOIN FamilyMember FM
		ON FM.ClientID = S.ProvidedToEntityID AND FM.DateRemoved > GETDATE()
	INNER JOIN Entity E
		ON E.EntityID = FM.ClientID
	INNER JOIN Client C
		ON C.EntityID = FM.ClientID 
	INNER JOIN Family F
		ON F.FamilyID = FM.FamilyID
	INNER JOIN Service SL
		ON SL.ProvidedToEntityID = S.ProvidedToEntityID
	INNER JOIN Account A
		ON A.AccountID = SL.AccountID
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = SL.ServiceTypeID
	LEFT JOIN UVW_AssessHUDUniversal_Last HUDview
		ON HUDview.ClientID = FM.ClientID
	LEFT JOIN AssessHUDUniversal AHU
		ON AHU.AssessmentID = HUDview.AssessmentID
	LEFT JOIN UVW_LatestAHPAssessment AHPAssess
		ON AHPAssess.ClientID = FM.ClientID
	LEFT JOIN AssessHUDProgram AHP
		ON AHP.AssessmentID = AHPAssess.HUDProgramAssessmentID
	LEFT JOIN UVW_EntityAddress EA
		ON EA.EntityID = FM.ClientID

	-- The following join and subquery creates a concatenated list of races for each client
	LEFT JOIN (SELECT C1.EntityID
						  , SUBSTRING( (SELECT ', '+(SELECT ListLabel FROM ListItem WHERE ListID = 6 AND ListValue = CR.RaceID) AS [text()]
										FROM Client C2
											INNER JOIN ClientRace CR
												ON CR.ClientID = C2.EntityID
										WHERE C2.EntityID = C1.EntityID
										FOR XML PATH ('')
							), 2, 100) 'Races'
					FROM Client C1
						INNER JOIN ClientRace CR
							ON CR.ClientID = C1.EntityID
				) [RaceList]
		ON [RaceList].EntityID = FM.ClientID
	
	-- The following join and subquery creates a concatenated list of health insurance types for each client
	LEFT JOIN (SELECT C.EntityID
					 , SUBSTRING( (SELECT ', '+(SELECT ListLabel FROM ListItem WHERE ListID = 1797 AND ListValue = AHI.InsuranceTypeID AND AHI.Results = 1) AS [text()]
								   FROM Client C2
									 LEFT JOIN UVW_LatestAHPAssessment LA
										 ON LA.ClientID = C2.EntityID
									 LEFT JOIN AssessHealthInsurance AHI
										 ON AHI.AssessmentID = LA.HUDProgramAssessmentID
								   WHERE C2.EntityID = C.EntityID
								   FOR XML PATH ('')
					), 2, 100) 'Health Insurance'
			  FROM Client C) [InsList]
		ON [InsList].EntityID = FM.ClientID
	-- Noncash Benefits Subquery
	LEFT JOIN (SELECT C.EntityID
					  , SUBSTRING( (SELECT ', '+(SELECT ListLabel FROM ListItem WHERE ListID = 1000000065 AND ListValue = ANCB.BenefitID) AS [text()]
									FROM Client C2
										LEFT JOIN UVW_LatestAHPAssessment LA
											ON LA.ClientID = C2.EntityID
										LEFT JOIN AssessNonCashBenefits ANCB
											ON ANCB.AssessmentID = LA.HUDProgramAssessmentID
									WHERE C2.EntityID = C.EntityID
									FOR XML PATH ('')
					), 2, 100) 'Non Cash Benefits'
			   FROM Client C) [NCBs]
		ON [NCBs].EntityID = FM.ClientID

	-- Income Sources
	LEFT JOIN (SELECT C.EntityID
			    , SUBSTRING( (SELECT ', '+CONCAT((SELECT ListLabel FROM ListItem WHERE ListID = 1000000087 AND ListValue = AFI.FinancialItemTypeID),': ',AFI.Amount)
							  FROM Client C2
								LEFT JOIN UVW_LatestAssessment LA
									ON LA.ClientID = C.EntityID AND LA.HUDUniversalAssessmentID IS NOT NULL
								INNER JOIN AssessFinancialSummary AFS
									ON AFS.AssessmentID = LA.HUDUniversalAssessmentID
								INNER JOIN AssessFinancialItem AFI
									ON AFI.AssessmentID = AFS.AssessmentID
								WHERE C2.EntityID = C.EntityID
								 FOR XML PATH ('')
								), 2, 100) 'Income Sources'
			   FROM Client C) [IncomeSources]
		ON [IncomeSources].EntityID = FM.ClientID
-- Filters
WHERE (A.AccountName NOT LIKE '%Food Bank')
      AND (A.AccountName NOT LIKE 'LIEAP')
	  AND (SL.BeginDate BETWEEN '01/01/2020' AND '12/31/2020')
ORDER BY F.FamilyID, S.ProvidedToEntityID


--SELECT * FROM Client
--SELECT * FROM UVW_AssessHUDUniversal_Last
--SELECT * FROM AssessHUDUniversal