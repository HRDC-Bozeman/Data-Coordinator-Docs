DECLARE @FirstName VARCHAR(30);
DECLARE @LastName VARCHAR(30);

SET @FirstName = '*FIRST NAME*';
SET @LastName = '*LAST NAME*';

SELECT EntityID, FirstName, LastName, CONVERT(date, BirthDate)
FROM Client
WHERE FirstName LIKE @FirstName+'%'
      AND LastName LIKE @LastName+'%'