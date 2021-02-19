DECLARE @EntityID int;

SET @EntityID = **Entity ID**

SELECT EM.ClientID, E.EnrollmentID FROM EnrollmentMember EM
	INNER JOIN Enrollment E
		ON E.EnrollmentID = EM.EnrollmentID
WHERE E.ProgramID = 261 AND EM.ClientID = @EntityID

