BEGIN TRANSACTION [Outer]


	-- Create parameter to hold created Entity ID
	DECLARE @entityID int;

	-- Create Entity
	INSERT INTO Entity (EntityTypeID, CreatedBy, OwnedByOrgID)
	VALUES (3, 58357, 4196)
	
	-- Get Generated Entity ID
	SET @entityID = SCOPE_IDENTITY()

	-- Create Client
	INSERT INTO Client (EntityID, FirstName, MiddleName, LastName, BirthDate, Gender)
	VALUES (@entityID, 'HBE', 'to', 'CW', '02/19/2021', 99)

	-- Create Client Address
	INSERT INTO ClientAddress (ClientID, Address1, Address2, ZipCode, State, AddressType, BeginDate)
	VALUES (@entityID, '111 Fake Street', '', '59715', 'MT', 1, '02/19/2021')

	-- Create Client Contact Information
	INSERT INTO EntityContactPreference (EntityID, CellPhone, Email)
	VALUES (@entityID, '123-456-7890', 'example@email.com')

	-- Create parameter to hold created Family ID
	DECLARE @familyID int;

	-- Create Family
	INSERT INTO Family (FamilyName, CreatedBy, OwnedByOrgID)
	VALUES ('TestFamily', 58357, 4196)

	-- Get generated Family ID
	SET @familyID = SCOPE_IDENTITY()

	-- Add members to family
	INSERT INTO FamilyMember (FamilyID, ClientID, RelationToHoH)
	VALUES (@familyID, @entityID, 1)

	-- Create parameter to hold created Enrollment ID
	DECLARE @enrollmentID int;

	-- Create Enrollment
	INSERT INTO Enrollment (ProgramID, FamilyID, OrganizationID, Status, BeginDate)
	VALUES (261, @familyID, 4196, 100, '02/19/2021')

	SET @enrollmentID = SCOPE_IDENTITY()

	-- Add Enrollment Members
	INSERT INTO EnrollmentMember (EnrollmentID, ClientID, ProviderID, BeginDate)
	VALUES (@enrollmentID, @entityID, 4197, '02/19/2021')

	DECLARE @assessmentID int;
	-- Create Assessment
	INSERT INTO Assessment (EnrollmentID, ClientID, AssessmentBy, AssessmentEvent, BeginAssessment, CreatedBy, OwnedByOrgID)
	VALUES (@enrollmentID, @entityID, 58357, 1, '02/19/2021', 58357, 4196)

	SET @assessmentID = SCOPE_IDENTITY()

	-- Create Satellite Assessments
	INSERT INTO AssessHUDUniversal (AssessmentID, PriorResidence, DisablingCondition, CreatedBy)
	VALUES (@assessmentID, 9, 2, 58357)

	INSERT INTO AssessHUDProgram (AssessmentID, NonCashBenefit, HealthInsurance, Employed, EmploymentType, WhyNotEmployed, EduHighestGrade, MaritalStatusID, CreatedBy, CreatedDate)
	VALUES (@assessmentID, 2, 1, 1, 5, NULL, 8, 1, 58357, '02/19/2021')

	INSERT INTO AssessEligibility (AssessmentID, HouseHoldType, ActiveMilitary)
	VALUES (@assessmentID, 1, 2)

	INSERT INTO AssessFinancialItem (AssessmentID, FinancialItemTypeID, Amount, CreatedBy, CreatedDate, Interval, IntervalAmount, TransactionType, IntervalsPerMonth)
	VALUES (@assessmentID, 3, 1000, 58357, '02/19/2021', 5, 1000, 2, 1)
	       , (@assessmentID, 6, 200, 58357, '02/19/2021', 5, 200, 2, 1)

EXEC plugin_FinancialAssessSummarySet @CurrentUserID = 58357
										,@AssessmentID = @assessmentID
										,@AMIID = 32
										,@IsMetro = 1
										,@FinancialType = 1
										,@IsNoIncome = 1
										,@IsFamilyIncome = 1
										,@FamilyMemberCount = 1
	-- Create Services
	INSERT INTO Service (ServiceTypeID, ProvidedToEntityID, ProvidedByEntityID, EnrollmentID, UnitOfMeasure, UnitValue, Units, ServiceTotal, BeginDate, EndDate, CreatedBy, OwnedByOrgID, CreatedDate, AccountID)
	VALUES (932, @entityID, 58357, @enrollmentID, 4, 1, 1, 1, '02/19/2021', '02/19/2021', 58357, 4196, '02/19/2021', 157)


SELECT C.EntityID
       , F.FamilyID
	   , F.FamilyName
	   , C.FirstName
	   , C.LastName
	   , E.EnrollmentID
	   , P.ProgramName
	   , A.AssessmentID
	   , AHP.NonCashBenefit
	   , AHU.DisablingCondition
	   , AFS.TotalIncome
	   , S.ServiceID
FROM Client C
	INNER JOIN ClientAddress CA
		ON CA.ClientID = C.EntityID
	INNER JOIN FamilyMember FM
		ON FM.ClientID = C.EntityID
	INNER JOIN Family F
		ON F.FamilyID = FM.FamilyID
	INNER JOIN EnrollmentMember EM
		ON EM.ClientID = C.EntityID
	INNER JOIN Enrollment E
		ON E.EnrollmentID = EM.EnrollmentID
	INNER JOIN Assessment A
		ON A.EnrollmentID = E.EnrollmentID
	INNER JOIN Program P
		ON E.ProgramID = P.ProgramID
	INNER JOIN AssessHUDProgram AHP
		ON AHP.AssessmentID = A.AssessmentID
	INNER JOIN AssessHUDUniversal AHU
		ON AHU.AssessmentID = A.AssessmentID
	INNER JOIN AssessEligibility AE
		ON AE.AssessmentID = A.AssessmentID
	INNER JOIN AssessFinancialSummary AFS
		ON AFS.AssessmentID = A.AssessmentID
	INNER JOIN AssessFinancialItem AFI
		ON AFI.AssessmentID = A.AssessmentID
	INNER JOIN Service S
		ON S.EnrollmentID = E.EnrollmentID
WHERE C.FirstName = 'HBE' AND C.LastName = 'CW'

ROLLBACK TRANSACTION [Outer]

	
/*
SELECT * FROM Entity
SELECT * FROM Family
SELECT * FROM FamilyMember
SELECT * FROM EntityContactPreference
SELECT * FROM Enrollment
SELECT * FROM EnrollmentMember
SELECT * FROM Assessment
SELECT * FROM Lists WHERE ListName LIKE '%Assessment Event%'
SELECT * FROM ListItem WHERE ListID = 27
SELECT * FROM AssessHUDUniversal
SELECT * FROM AssessHUDProgram
SELECT * FROM AssessFinancialSummary
SELECT * FROM AssessFinancialItem
SELECT * FROM ListItem WHERE ListID = 1000000087
SELECT * FROM AreaMedianIncome
SELECT CONTEXT_INFO()
SELECT * FROM Service
SELECT * FROM ServiceType
SELECT * FROM Account
*/