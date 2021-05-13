SELECT E.EntityID
	   , ST.Description
	   , S.Units
	   , S.UnitValue 'Value'
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 2 AND ListValue = S.UnitOfMeasure) 'Unit of Measure'
	   , S.ServiceTotal 'Total'
	   , S.BeginDate 'Date'
	   , A.AccountName 'Program'
FROM Service S
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	INNER JOIN Entity E
		ON E.EntityID = S.ProvidedToEntityID
	INNER JOIN Enrollment En
		ON En.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = En.ProgramID
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
		