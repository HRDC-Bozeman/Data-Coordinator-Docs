with cte as (
	SELECT DISTINCT S.ProvidedToEntityID 'ClientID'
		   , e.EntityName
	FROM Service S
		INNER JOIN Account A
			ON A.AccountID = S.AccountID
		LEFT JOIN (SELECT DISTINCT EM.ClientID
						  , Entity.EntityName 
						  , P.ProgramName
				   FROM EnrollmentMember EM
					   INNER JOIN Enrollment E
							ON E.EnrollmentID = EM.EnrollmentID
					   INNER JOIN Program P
							ON P.ProgramID = E.ProgramID
					   INNER JOIN Entity
							ON Entity.EntityID = EM.ClientID
					WHERE P.ProgramName = 'Home to Stay'
						  AND E.BeginDate < '12/31/2020'
						  AND E.EndDate > '07/01/2020') e
			ON E.ClientID = S.ProvidedToEntityID
	WHERE S.BeginDate BETWEEN '07/01/2020' AND '12/31/2020'
		  AND A.AccountName = 'Housing First'
		  )
SELECT cte.ClientID, E.EntityName 'Client Name' FROM cte 
	INNER JOIN Entity E
		ON E.EntityID = cte.ClientID
WHERE cte.EntityName IS NULL


/*
SELECT DISTINCT EM.ClientID
	   , Entity.EntityName 
	   , P.ProgramName
	   , s.clientID
FROM EnrollmentMember EM
	INNER JOIN Enrollment E
		ON E.EnrollmentID = EM.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Entity
		ON Entity.EntityID = EM.ClientID
	RIGHT JOIN (SELECT DISTINCT S.ProvidedToEntityID 'clientID'
				FROM Service S
					INNER JOIN Account A
						ON A.AccountID = S.AccountID
				WHERE S.BeginDate BETWEEN '07/01/2020' AND '12/31/2020'
					  AND A.AccountName = 'Housing First') s
		ON s.clientID = EM.ClientID
WHERE P.ProgramName = 'Home to Stay'
      AND E.BeginDate < '12/31/2020'
	  AND E.EndDate > '07/01/2020'
*/
--SELECT * FROM EnrollmentMember
/*



SELECT DISTINCT EM.ClientID
	   , Entity.EntityName 
	   , P.ProgramName
FROM EnrollmentMember EM
	INNER JOIN Enrollment E
		ON E.EnrollmentID = EM.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Entity
		ON Entity.EntityID = EM.ClientID
WHERE P.ProgramName = 'Home to Stay'
      AND E.BeginDate < '12/31/2020'
	  AND E.EndDate > '07/01/2020'
	  */