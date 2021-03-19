- [Documentation Home](../../README.md)
- [Projects Home](../projects.md)

# CounselorMax Automated Data Entry

1. [Project Background](#project-background)
1. [Form Filler](#form-filler)
1. [Form Filler v2](#form-filler-v2)
2. [Homebuyer Education Data Entry](#homebuyer-education-data-entry)
1. [Components](#components)
   1. [GSuite](#gsuite)
   1. [Python](#python)
   1. [Google Sheets API](#google-sheets-api)

## Project Background

Certain types of housing counseling qualify for reimbursement from HUD. These services need to be recorded in CounselorMax in order for HRDC to receive this reimbursement. This created a triple data entry problem where staff had to enter service information in CaseWorthy (for internal use), ServicePoint (for CoC), and CounselorMax(for HUD). In the past this was dealt with by making one person responsible for all CounselorMax data entry, in order to free up time for other staff members. HUD Counseling sessions were entered into a Google Form and then entered by hand by the data entry staff person.

---

## Form-Filler

In an effort to streamline the data processes of the housing department, I created a Python application to enter this data with less direct user input. The biggest part of this project was using the [Selenium with Python](https://selenium-python.readthedocs.io/) library to open browsers, and to perform read/write operations on HTML elements. This early attempt at automation broke down frequently, and required significant supervision. But even with those obstacles, it reduced data entry time and increased data quality by eliminating certain types of user input errors.

### Form-Filler Data Pipeline

- Housing Staff enter HUD counseling information through a Google Form
- Form responses are copied into a spreadsheet used to interact with Form-Filler
- Form-Filler looks at the spreadsheet for HUD counseling information
- An Internet Explorer Selenium driver is created to interact with CounselorMax
- A Google Chrome Selenium driver is created to interact with CaseWorthy
- Search for client in CounselorMax
  - If they are in CounselorMax
    - Do they have an active case?
      - Yes, add appointment
      - No, create case then add appointment
  - If they are not in CounselorMax
    - Pull data from CaseWorthy via Selenium (time consuming...)
    - Create new client and case based on CaseWorthy information
    - Add appointment
- Repeat this until all rows from the spreadsheet are added

Some notes about this process: rows from the spreadsheet must be manually deleted as the script is running. At each step in the process the script also needs user input: e.g. "Is this Client in CounselorMax?", "Is this client in CaseWorthy?", "Does this client have an active case?". This helps to make sure that the script doesn't go crazy and add a bunch of erroneous data, but it also comes at a time cost.

---

## Form-Filler v2

Form-Filler v2 makes a number of improvements over the original. It seamlessly pulls data from CaseWorthy without going through the screen-scraping procedure with Selenium. This saves 30-60 seconds per data pull. This also has the advantage of not being reliant on the front-end forms in CaseWorthy to find the correct information. Data are pulled directly from the appropriate tables in the SQL database. It also eliminates the external spreadsheet needed to interact with form-filler v1. Using the [gspread](https://gspread.readthedocs.io/en/latest/) library, form responses are pulled directly from the response spreadsheet. A "Processed" checkbox is checked automatically to indicate that the data in that row has been entered. 

These changes were made in conjunction with an update to the Google Form itself. In the past there were two different forms, one for Housing First, and one for Section 8. Now all responses are collected on a single form. The question flow has also be reorganized and streamlined to improve data quality and reduce the time needed to complete the form.

### Form-Filler v2 Data Pipeline

- gspread pulls response data from the spreadsheet that has not yet been processed
- An Internet Explorer Selenium driver is created to interact with CounselorMax
- Search for client in CounselorMax
  - If they are in CounselorMax
    - Do they have an active case?
      - Yes, add appointment
      - No, create case then add appointment
      - Mark record as processed in original response spreadsheet
  - If they are not in CounselorMax
    - Pull data from CaseWorthy via [`sqlGetter.py`](sqlGetter.py) and [`clientdata.sql`](clientdata.sql) (virtually instantaneous...)
    - Create new client and case based on CaseWorthy information
    - Add appointment
    - Mark record as processed in original response spreadsheet
    
---

## Homebuyer Education Data Entry

Another program that is required to use CounselorMax is Homebuyer Education, but their data entry workflow is slightly different. In this section I will outline how data is entered for Homebuyer Ed, and I will cover the additional Python/Selenium functionality required.

### Data Entry Steps

1. Create a new client
2. Intake
3. Enroll in Class
4. Attend Class
5. Change Service Type
6. Document Upload
---

## GSuite

- [Google Form](https://docs.google.com/forms/d/1LaEelklJ9hcycyQM0MG33cmcyYuXHG61wcpaf9FsTkQ/edit)
- [Response Spreadsheet](https://docs.google.com/spreadsheets/d/1ys_YjzH_HgeGxRcH9Nf_Q-Gg51209EjBI6ZMTvBxwVs/edit#gid=1001428010)

The first step in the data entry process is getting user input through the Google Form. A generic copy of the form is linked above. Response information is stored in the response spreadsheet, also linked above with personal information redacted.

---

## Python

This project uses 2 scripts written by me, and a number of external libraries. `driver.py` handles all of the interaction with GSuite and CounselorMax. `sqlGetter.py` is a utility script that creates a connection to a local database instance and allows the retrieval of records.

### `driver.py`

#### `initialize_gspread()`

- Parameters
  - None
- Return Value
  - gspread worksheet object

This function handles the Google Sheets API authentication, as well as hard-coded values for the Google Sheets ID and worksheet name.

#### `get_records(sheet)`

- Parameters
  - `sheet`: gspread worksheet object
- Return Value
  - List of `dict`s
  
Looks through all records in the response spreadsheet. Returns records with 'Processed' == FALSE. Preserves the row number of each appended record.


#### `cmax_login()`

- Parameters
  - None
- Return Value
  - Selenium IE driver object

Launches an IE driver and logs into CounselorMax. Replace 'Your CounselorMax Username' and 'Your CounselorMax Password'. Returns the driver object

#### `get_client_info(clientID)`

- Parameters
  - `clientID`: `int` or `str`
- Return Value
  - `dict`

Uses `sqlGetter.py`, `clientdata.sql`, and Pandas to retrieve required client intake information from a SQL server instance. This query should only ever return one row since it is matching a unique client ID. The `record` will contain the following keys:

- EntityID
- LastName
- FirstName
- MiddleName
- Gender
- BirthDate
- SSN
- Race
- Ethnicity
- Address1
- ZipCode
- County
- CellPhone
- HomePhone
- Email
- VeteranStatus
- PrimaryLanguage
- Members
- Prior Residence
- Highest Grade Completed
- Marital Status
- Active Military
- TotalIncome

#### `add_hud_appointment(driver, hud_data, sheet)`

- Parameters
  - `driver`: Selenium IE driver object
  - `hud_data`: `dict` of form response data
  - `sheet`: gspread worksheet object
- Return Value
  - None
  
Uses the IE driver to fill out forms in CounselorMax to create a new appointment. Marks the row in the form response spreadsheet as 'Processed == TRUE'

#### `create_cmax_client(driver, demogs, appt)`

- Parameters
  - `driver`: Selenium IE driver object
  - `demogs`: `dict` of data pulled from CaseWorthy
  - `appt`: `dict` of form response data
- Return Value
  - None

Uses the IE driver to fill out forms in CounselorMax to create a new client.

#### `fill_cmax_intake(driver, demogs, hud_data)`

- Parameters
  - `driver`: Selenium IE driver object
  - `demogs`: `dict` of data pulled from CaseWorthy
  - `appt`: `dict` of form response data
- Return Value
  - None
  
Uses the IE driver to fill out forms in CounselorMax to provide required intake information.

#### `add_appts()`

- Parameters
  - None
- Return Value
  - None
  
This is the main algorithm that handles the CounselorMax data entry. It invokes all of the above functions to complete tasks. Starts with `initialize_gspread()`, `get_records(s)`, and `cmax_login()`. Goes through each of the form responses with a for loop. Inside the for loop it uses a series of if-elif-else statements to determine which steps need to be taken for each form response.

---

## Google Sheets API

The interaction between Python and GSuite is facilitated by the Google Sheets API. You must enable and authorize the API before using it. Here are some resources on how to do that.

- [Enable and disable APIs](https://support.google.com/googleapi/answer/6158841?hl=en)
- [Google Sheets API Python Quickstart](https://developers.google.com/sheets/api/quickstart/python)
- [gspread API guide](https://gspread.readthedocs.io/en/latest/oauth2.html)





