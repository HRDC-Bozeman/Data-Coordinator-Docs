SELECT DISTINCT C.EntityID 
	   , En.EntityName 'Child''s Name'
	   , FM.FamilyID
	   , dbo.ufn_ClientAge(C.BirthDate, GETDATE()) 'Age'
	   , HoH.ClientID
	   , EnHoH.EntityName 'Head of Household Name'
	   , ECP.CellPhone
	   , ECP.HomePhone
	   , ECP.WorkPhone
	   , ECP.Email
	   --, CA.AddressID
	   --, LastKnown.Date
FROM Client C
	INNER JOIN Entity En
		ON En.EntityID = C.EntityID
	INNER JOIN FamilyMember FM
		ON FM.ClientID = C.EntityID
		   AND FM.DateRemoved > GETDATE()
	INNER JOIN FamilyMember HoH
		ON HoH.FamilyID = FM.FamilyID AND HoH.RelationToHoH = 1
	INNER JOIN Entity EnHoH
		ON EnHoH.EntityID = HoH.ClientID
	INNER JOIN EntityContactPreference ECP
		ON ECP.EntityID = HoH.ClientID
	INNER JOIN (SELECT ClientID, MAX(BeginDate) 'Date'
			    FROM ClientAddress 
				WHERE AddressType IN (1,2)
				GROUP BY ClientID, AddressID) LastKnown
		ON LastKnown.ClientID = HoH.ClientID
WHERE dbo.ufn_ClientAge(C.BirthDate, '09/10/2021') BETWEEN 3 AND 5 --Get records under age 5
	  AND C.BirthDate < GETDATE() -- Filter out records with birth dates in the future
ORDER BY En.EntityName

--1,152 children <= age 5
/*

SELECT ClientID, FamilyID, RelationToHoH 
FROM FamilyMember
ORDER BY FamilyID
*/