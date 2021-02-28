- [Documentation Home](../../README.md)
- [Projects Home](../projects.md)

# Homebuyer Education Online Registration to CaseWorthy Connection

- [Homebuyer Education Online Registration Documentation](../../Instructions/onlineHBEregistration.md)
- [SQL Documentation](../../Instructions/sql.md)

## Project Background

Successfully generating raw SQL for a bulk service upload for the food bank led to this project. For this project, I will take registration data from the response spreadsheet to generate more complex SQL required to create new client records. This will act as an extension of the existing data pipeline being used by Homebuyer Education.



### Existing Data Pipe Line
- Customer enters data via Google Form
- Form Publisher add-on generates intake documents
- Form responses are recorded in the response spreadsheet
- Raw response data is reorganized into a dashboard view
- Staff use the dashboard to:
  - Generate class lists
  - Reschedule customers for different classes
  - View and download intake documents
  - Record who attended class and who received counseling, and on which date

### Extension of Data Pipe Line


#### Staff determine if customers are in CaseWorthy or not

This action will be taken on the response dashboard, potentially on a sheet dedicated to data entry. A staff member will verify if the household members are or are not in CaseWorthy. If one or more members of the household are existing clients, the staff member will enter their client ID(s). If they are not already in CaseWorthy, no further action needs to be taken.


#### Use Python + Google Sheets API to read response spreadsheet

The response dashboard can be read programatically through a Python library called [`gspread`](https://gspread.readthedocs.io/en/latest/). 

```python
# This is the library that handles data from Google Sheets
import gspread

# This enables the API connection to Google Sheets
# client_secret.json is a file you have to download through your Google service account
from oauth2client.service_account import ServiceAccountCredentials
scope = ['https://spreadsheets.google.com/feeds',
         'https://www.googleapis.com/auth/drive']
path = os.path.dirname(os.path.realpath(__file__))
sheets_creds = ServiceAccountCredentials.from_json_keyfile_name('{}\\client_secret.json'.format(path), scope)

# client is the object that interacts with the spreadsheet
client = gspread.authorize(sheets_creds)

# Opens the spreadsheet
# You must give the Google service account edit access to the spreadsheet
sh = client.open_by_key('**THE KEY OF YOUR SPREADSHEET**')

# Opens the worksheet
ws = sh.worksheet('Data Entry Worksheet')

# Returns all records from that worksheet as a list of dictionaries
# Each list item represents a row of the spreadsheet
# Each dictionary contains all of the values in that row
records = ws.get_all_records()
```

#### For each customer registration
- If they aren't a client, create a new client record and add enrollment, assessment and service information.
- If they are an existing client, update existing client record with current information, add assessment and service information.

  
## Python

### `get_registrations()`

### `create_client(record)`

### `update_client_info(record)`

### `encode_registration(record)`

### `create_enrollment(record)`

### `create_assessment(record)`


## SQL

[`newtestclient.sql`](newtestclient.sql) is a hard coded script which performs the following actions: 
- Create a new client
- Add them to a family
- Update their address
- Enroll them in Universal Intake
- Complete required assessments
- Add relevant services

### Create Client

### Update Info

### Create Enrollment

### Create Assessment

### Create Services


## Research

First challenge I notice is creating multiple SQL records and making sure all of the primary and foreign keys match up. For example, creating a client will look something like the psudeocode below:

```sql
INSERT INTO Client ([columns to assign values to])
VALUES ([the values for those columns])
```

Since the primary key values (EntityID) is not explicitly set by the code, I need to make sure that I have a way of returning that value to use as a foreign key in creating a different type of record:

```sql
INSERT INTO ClientAddress(ClientID, [other values])
VALUES ([PK from last insert], [assignment of other values])
```

Based on this [Stackoverflow question](https://stackoverflow.com/questions/42648/best-way-to-get-identity-of-inserted-row), I think the solution lies in using [`SCOPE_IDENTITY()`](https://docs.microsoft.com/en-us/sql/t-sql/functions/scope-identity-transact-sql?redirectedfrom=MSDN&view=sql-server-ver15). From that link:


> Returns the last identity value inserted into an identity column in the same scope. A scope is a module: a stored procedure, trigger, function, or batch. Therefore, if two statements are in the same stored procedure, function, or batch, they are in the same scope.

The following code snippet seems to work:

```sql
BEGIN TRANSACTION [Tran1]
	
	DECLARE @entityID int;

	INSERT INTO Entity (EntityTypeID, CreatedBy, OwnedByOrgID)
	VALUES ('3', '58357', '4196')
	
	SET @entityID = SCOPE_IDENTITY()

	INSERT INTO Client (EntityID, FirstName, MiddleName, LastName, BirthDate, Gender)
	VALUES (@entityID, 'HBE', 'to', 'CW', '02/19/2021', 99)

	INSERT INTO ClientAddress (ClientID, Address1, Address2, ZipCode, State, AddressType, BeginDate)
	VALUES (@entityID, '111 Fake Street', '', '59715', 'MT', 1, '02/19/2021')

	DECLARE @familyID int;

	INSERT INTO Family (FamilyName, CreatedBy, OwnedByOrgID)
	VALUES ('TestFamily', '58357', '4196')

	SET @familyID = SCOPE_IDENTITY()

	INSERT INTO FamilyMember (FamilyID, ClientID, RelationToHoH)
	VALUES (@familyID, @entityID, 1)

SELECT C.EntityID, F.FamilyID, F.FamilyName, C.FirstName, C.LastName, CA.Address1
FROM Client C
	INNER JOIN ClientAddress CA
		ON CA.ClientID = C.EntityID
	INNER JOIN FamilyMember FM
		ON FM.ClientID = C.EntityID
	INNER JOIN Family F
		ON F.FamilyID = FM.FamilyID
WHERE C.FirstName = 'HBE' AND C.LastName = 'CW'

ROLLBACK TRANSACTION [Tran1]
```

The `SELECT` at the bottom should return exactly 1 row with the values inserted in the above transaction. `ROLLBACK TRANSACTION [Tran1]` deletes the newly created records after displaying the return value. This is ideal for testing, but will have to be changed to `COMMIT TRANSACTION [Tran1]` in the live deployment.

|EntityID	|FamilyID	|FamilyName	|FirstName	|LastName	|Address1|
|
|69469	|45138	|TestFamily	|HBE	|CW	|111 Fake Street|