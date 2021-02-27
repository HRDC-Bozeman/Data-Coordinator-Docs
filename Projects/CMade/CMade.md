# CounselorMax Automated Data Entry

1. [Project Background](#project-background)
1. [Form Filler](#form-filler)
1. [Form Filler v2](#form-filler-v2)
1. [Python](#python)

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

## Python

### `initialize_gspread()`

Connects to the response spreadsheet and returns a gspread worksheet object containing the appointment data.

### `cmax_login()`

Launches an Internet Explorer Selenium driver, logs into CounselorMax, and returns the driver object.

### `get_client_info(clientID)`

### `get_records(sheet)`

### `add_appts()`

### `add_hud_appointment(driver, hud_data, sheet)`

### `create_cmax_client(driver, demogs, appt)`

### `fill_cmax_intake(driver, demogs, hud_data)`


