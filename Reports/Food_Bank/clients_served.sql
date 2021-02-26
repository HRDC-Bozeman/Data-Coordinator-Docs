DECLARE @startdate date;
DECLARE @enddate date;
DECLARE @program varchar;

-- This example was for Gallatin Valley food bank, but I want to parameterize the programs and service types
--DECLARE @programsIDList;
--DECLARE @servicetypeIDList;

-- I also want to filter by client demographics
--DECLARE @otherdemographicinformation;

--In looking through the baseline reports I saw that you have a way of managing the parameters that came out of the form
--I didn't bother to try that here

-- I have this hardcoded for when I run the report
SET @startdate = '11/01/2020';
SET @enddate = '11/30/2020';
SET @program = 'Gallatin Valley Food Bank';
-- Originally: Summary of all food banks, how many visits and total food boxes
-- This should become summary of all programs selected, and a count of the different service types selected
/*
SELECT A.AccountName 'Program'
	   , COUNT(S.ServiceID) 'Visits'
	   , SUM(S.ServiceTotal) 'Quantity'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Account A
		ON A.AccountID = S.AccountID
	--INNER JOIN AccountService ActS
		--ON ActS.ServiceTypeID = ST.ServiceTypeID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	--INNER JOIN Client C
		--ON C.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName = 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank')) -- Parameterize
	  -- Filter by client demographics
	  AND ST.Description = 'Emergency  Food Service'
	  AND (S.BeginDate BETWEEN @startdate AND @enddate)
	  AND (S.DeletedDate > GETDATE())
GROUP BY A.AccountName;
*/

-- List of all services by program(s)
-- I want this available as a sub-report somewhere

SELECT S.ProvidedToEntityID 'ClientID'
	   , CONCAT(C.FirstName,' ',C.LastName) 'Client Name'
	   , CONVERT(date, S.BeginDate) 'Service Date'
	   , ST.Description 'Service Type'
	   , S.ServiceTotal 'Quantity'
	   --, S.AccountID
	   --, A.AccountName 'Program'
	   --, P.ProgramName 'Legacy Program'
	   , E.BeginDate 'Enrollment Start Date' 
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank')) -- Parameterize
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
ORDER BY [Service Date];


-- FOOD BANK SPECIFIC:
-- Number of unique households served
-- All food boxes are recorded under HoH only

SELECT ST.Description, A.AccountName, COUNT(DISTINCT S.ProvidedToEntityID)'HHs', SUM(S.ServiceTotal) 'Units'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
GROUP BY A.AccountName, ST.Description;


-- Number of clients served (derived from food box sizes)
-- FOOD BANK SPECIFIC:
-- We record food boxes for a family as a single service under the HoH, and the service quantity is the number of HH members
-- To get the number of unique clients served I take the all the largest services for any given client and add them all together
-- PLEASE LET ME KNOW IF THERE IS A BETTER WAY TO DO THIS GIVEN THE WAY WE RECORD FOOD BOXES

SELECT Account, Program, SUM([Largest Service]) FROM (
SELECT C.[Client Name] 'HoH Name', A.AccountName 'Account', P.ProgramName 'Program', COUNT(*) 'Visits', MAX(S.Units) 'Largest Service', MIN(S.Units) 'Smallest Service'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN (SELECT EntityID, CONCAT(LastName, ', ', FirstName) 'Client Name' FROM Client) C
		ON C.EntityID = S.ProvidedToEntityID
WHERE (
	      (A.AccountName LIKE 'Gallatin Valley Food Bank') 
       OR (P.ProgramName LIKE 'Gallatin Valley Food Bank')
	   )
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
	  AND ST.Description LIKE 'Emergency  Food Service'
GROUP BY C.[Client Name], A.AccountName, P.ProgramName
) tab GROUP BY Account, Program;



-- Clients served by county

WITH hhmembers AS 
(
SELECT S.ProvidedToEntityID 'HoH', MAX(S.ServiceTotal) '# in HH' 
FROM Service S
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Entity En
		ON En.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
		AND S.BeginDate BETWEEN @startdate AND @enddate
		AND S.DeletedDate > GETDATE()
		AND ST.Description LIKE 'Emergency  Food Service'
GROUP BY S.ProvidedToEntityID
)

SELECT CA.County, COUNT(hhmembers.HoH) 'Households', SUM(hhmembers.[# in HH]) 'Clients' FROM hhmembers
	INNER JOIN UVW_EntityAddress EA
		ON EA.EntityID = hhmembers.HoH
	LEFT JOIN ClientAddress CA
		ON CA.AddressID = EA.CAAddressID
GROUP BY CA.County WITH ROLLUP



-- Households and clients served by service type

SELECT [Service Type], COUNT([HHSize])'Households Served', SUM([HHSize]) 'Clients Served' FROM (
SELECT ST.Description 'Service Type', S.ProvidedToEntityID, MAX(S.ServiceTotal) 'HHSize'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
GROUP BY S.ProvidedToEntityID, ST.Description
) t
GROUP BY [Service Type];


-- Number of unique households served


-- Age Range of HH served
/*
SELECT SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) < 6 THEN 1 ELSE 0 END) 'Under 5'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) '6 - 11'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) '12 - 17'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) '18 - 23'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 24 AND 44 THEN 1 ELSE 0 END) '24 - 44'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN 1 ELSE 0 END) '45 - 54'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 55 AND 69 THEN 1 ELSE 0 END) '55 - 69'
	  ,SUM(CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) > 69 THEN 1 ELSE 0 END) '70+'
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()

*/
--
-- GENDER DISTRIBUTION
-- HoH demographics
WITH ClientData AS (
SELECT DISTINCT S.ProvidedToEntityID 'HoH'
	   , E.FamilyID
	   , la.AssessmentID
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = C.Gender) Gender
	   , DATEDIFF(year, C.Birthdate, GETDATE()) 'Age'
	   , CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) < 6 THEN 'Under 5'
	    	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN '6 - 11'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN '12 - 17'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 18 AND 25 THEN '18 - 25'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 26 AND 44 THEN '26 - 44'
		      WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 55 AND 69 THEN '55 - 69'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) > 69 THEN '70+'
		 END AgeRange
	   , AFS.TotalIncome
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	LEFT JOIN UVW_AssessHUDUniversal_Last la
		ON la.ClientID = C.EntityID
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = la.AssessmentID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
)

SELECT Gender, COUNT(*) FROM ClientData
GROUP BY Gender
WITH ROLLUP;
-- Household demographics

WITH ClientData AS (
SELECT DISTINCT S.ProvidedToEntityID 'HoH'
	   , E.FamilyID
	   , FM.ClientID
	   , la.AssessmentID
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = FMC.Gender) Gender
	   , DATEDIFF(year, FMC.Birthdate, GETDATE()) 'Age'
	   , CASE WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) < 6 THEN 'Under 5'
	    	  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN '6 - 11'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN '12 - 17'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 18 AND 25 THEN '18 - 25'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 26 AND 44 THEN '26 - 44'
		      WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 55 AND 69 THEN '55 - 69'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) > 69 THEN '70+'
		 END AgeRange
	   , AFS.TotalIncome
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	LEFT JOIN FamilyMember FM
		ON FM.FamilyID = E.FamilyID
		   AND FM.DateRemoved > @startdate
	LEFT JOIN Client FMC
		ON FMC.EntityID = FM.ClientID
	LEFT JOIN UVW_AssessHUDUniversal_Last la
		ON la.ClientID = FMC.EntityID
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = la.AssessmentID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
)

SELECT Gender, COUNT(*) FROM ClientData
WHERE ClientID > 999
GROUP BY Gender WITH ROLLUP;


WITH ClientData AS (
SELECT DISTINCT S.ProvidedToEntityID 'HoH'
	   , E.FamilyID
	   , la.AssessmentID
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = C.Gender) Gender
	   , DATEDIFF(year, C.Birthdate, GETDATE()) 'Age'
	   , CASE WHEN DATEDIFF(year, C.Birthdate, GETDATE()) < 6 THEN 'Under 5'
	    	  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN '6 - 11'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN '12 - 17'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 18 AND 25 THEN '18 - 25'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 26 AND 44 THEN '26 - 44'
		      WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) BETWEEN 55 AND 69 THEN '55 - 69'
			  WHEN DATEDIFF(year, C.Birthdate, GETDATE()) > 69 THEN '70+'
		 END AgeRange
	   , AFS.TotalIncome
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	LEFT JOIN UVW_AssessHUDUniversal_Last la
		ON la.ClientID = C.EntityID
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = la.AssessmentID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
)

SELECT AgeRange, COUNT(*) FROM ClientData
GROUP BY AgeRange
WITH ROLLUP;



WITH ClientData AS (
SELECT DISTINCT S.ProvidedToEntityID 'HoH'
	   , E.FamilyID
	   , FM.ClientID
	   , la.AssessmentID
	   , (SELECT ListLabel FROM ListItem WHERE ListID = 1 AND ListValue = FMC.Gender) Gender
	   , DATEDIFF(year, FMC.Birthdate, GETDATE()) 'Age'
	   , CASE WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) < 6 THEN 'Under 5'
	    	  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 6 AND 11 THEN '6 - 11'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 12 AND 17 THEN '12 - 17'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 18 AND 25 THEN '18 - 25'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 26 AND 44 THEN '26 - 44'
		      WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) BETWEEN 55 AND 69 THEN '55 - 69'
			  WHEN DATEDIFF(year, FMC.Birthdate, GETDATE()) > 69 THEN '70+'
		 END AgeRange
	   , AFS.TotalIncome
FROM Service S
	INNER JOIN ServiceType ST
		ON ST.ServiceTypeID = S.ServiceTypeID
	LEFT JOIN Account A
		ON A.AccountID = S.AccountID
	LEFT JOIN Enrollment E
		ON E.EnrollmentID = S.EnrollmentID
	INNER JOIN Program P
		ON P.ProgramID = E.ProgramID
	INNER JOIN Client C
		ON C.EntityID = S.ProvidedToEntityID
	LEFT JOIN FamilyMember FM
		ON FM.FamilyID = E.FamilyID
		   AND FM.DateRemoved > @startdate
	LEFT JOIN Client FMC
		ON FMC.EntityID = FM.ClientID
	LEFT JOIN UVW_AssessHUDUniversal_Last la
		ON la.ClientID = FMC.EntityID
	LEFT JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = la.AssessmentID
WHERE ((A.AccountName LIKE 'Gallatin Valley Food Bank') OR (P.ProgramName LIKE 'Gallatin Valley Food Bank'))
	  AND S.BeginDate BETWEEN @startdate AND @enddate
	  AND S.DeletedDate > GETDATE()
)

SELECT AgeRange, COUNT(*) FROM ClientData
GROUP BY AgeRange
WITH ROLLUP;




