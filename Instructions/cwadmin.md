[Documentation Home](../README.md)

# CaseWorthy Administrator Instructions

This page will outline some of the basics of the day-to-day administration of CaseWorthy

1. Users
   1. Off-boarding
1. Household Composition Changes
1. Client Merges
1. Database Backups
1. SQL Server Management Studio (SSMS)
1. [Structured Query Language (SQL)](sql.md)
1. SQL Server Reporting Service (SSRS)
1. [`sqlGetter.py`](#sqlgetter.py)

---
---

## Users

Anybody at HRDC can access CaseWorthy with their manager's approval. It is generally a good idea to not provide login credentials until a new user has completed the introductory training.

### Where to configure users

You can create new users through the HRDC Admin role. Before creating a new user, do a search to make sure they do not already exist. This is done using the [Add User](../Forms/Baseline8.md) found on the [Users Summary](../Forms/Baseline7.md) form. Click-path shown below:

![User Setup](../Images/usersetup.png)

### Off-boarding

Once an employee leaves HRDC, their CaseWorthy privileges should be immediately revoked, unless otherwise specified. This is done by locking their account and making it inactive. This is accessed through the [Edit User](../Forms/Baseline8.md) form.

---
---

## Household Composition Changes

Sometimes clients need to be moved to different households. This section will cover the procedure for creating new households, moving clients into new households, and moving clients into existing households.

- View client family history with the [Client Families](../Forms/1000000048.md) form. Each row represents a family that this client has been a member of.

![Client Family History](../Images/clientfamilyhistory.png)

- Determine if the client needs to be moved into a new family or an existing family
  - For a new family use the [ADMIN ONLY - Create a New Family](../Forms/1000000202.md) form
  - For an existing family
    - Look up the head of household of the new family
    - Use the [Add Family Member Spreadsheet](../Forms/Baseline7114.md) on the left-nav bar to add the new family member
- Determine if any enrollments need to be transferred to the new family. Transfer enrollments when the client(s) moving to the new family is (are) the only enrollment member(s)
  - Transfer these enrollments to the new family ID using the [Edit Enrollment - Admin](../Forms/1000000111.md)
  
  
  
  
- Remove the client from program enrollments that are not being transferred using the [Program Enrollment](..Forms/1000000266.md) and [Add/Edit Members](../Forms/Baseline49.md) forms.
  - Change date from "Open" to the appropriate ending date.
  - Click path: Action gear - Member - "+ Add/Edit Members"



- If the client is moving back into an old family you can simply change the date added on that row to the appropriate date, and change the date removed to "Open".

In most cases, a client should only be in one family at a time. Make sure that the date added to the new family is the same as the date removed from the old family. The most notable exception to this is children in a joint custody situation. 



---
---

## Client Merges


## [Structured Query Language (SQL)](sql.md)
## SQL Server Reporting Service (SSRS)


## `sqlGetter.py`

`sqlGetter.py` is a module that allows you to establish a connection to a database and server. Import and instantiate the class to integrate it with your code

```python
# sqlGetter.py
import pyodbc
import pandas as pd

class Connection:
	def __init__(self, server, database):
		self.server = server
		self.database = database
		self.cnxn = self.connect()

	def connect(self):
		cnxn = pyodbc.connect('Trusted_Connection=Yes;DRIVER={ODBC Driver 17 for SQL Server};SERVER='+self.server+';DATABASE='+self.database)	
		print('Connection to {} established on {}'.format(self.database,self.server))
		return cnxn

	def pandize_data(self, query, string = False):
		if not string:
			path = query+'.sql'
			with open(path, 'r') as file:
				sql = file.read()
		else:
			sql = query
		return pd.read_sql_query(sql,self.cnxn)

```

```python
# yourPythonCode.py
from sqlGetter import Connection

server = 'YOUR SQL SERVER'
database = 'HRDC09_Prod'

# Create the Connection Object
cnxn = Connection(server, database)

# Use the built-in pandize_data() function from the Connection object
data = cnxn.pandize_data('SELECT * FROM Client', string = True) # Pass a literal query
other_data = cnxn.pandize_data('mysqlcode.sql') # Pass a path to a .sql file
```



### `connect(server, database)`

- Parameters
  - `server`: str
  - `database`: str
- Return Value
  - `cnxn`: pyodbc connection object


### `pandize_data(query)`

- Parameters
  - `query`: `str`,the name of the query to be used without the file suffix
    - e.g. `'clientdata'`
- Return Value
  - pandas dataframe object




