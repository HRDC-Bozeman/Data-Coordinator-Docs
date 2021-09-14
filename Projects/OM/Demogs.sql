SELECT EntityID
	   , dbo.ufn_ClientAge(BirthDate, GETDATE()) 'Age'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = Gender) 'Gender'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 133 AND ListValue = PrimaryLanguage) 'Primary Language'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 6 AND ListValue = Race) 'Race'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 7 AND ListValue = Ethnicity) 'Ethnicity'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 37 AND ListValue = VeteranStatus) 'Veteran Status'
FROM Client
WHERE EntityID > 10