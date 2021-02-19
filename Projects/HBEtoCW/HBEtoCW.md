# Homebuyer Education Online Registration to CaseWorthy Connection

## Project Background

Successfully generating raw SQL for a bulk service upload for the food bank led to this project. For this project, I will take registration data from the response spreadsheet to generate more complex SQL required to create new client records. This will act as an extension of the existing data pipeline being used by Homebuyer Education.



### Existing Data Pipe Line
- Customer enters data via Google Form
- Form Publisher addon generates intake documents
- Form responses are recorded in the response spreadsheet
- Raw response data is reorganized into a dashboard view
- Staff use the dashboard to:
  - Generate class lists
  - Reschedule customers for different classes
  - View and download intake documents
  - Record who attended class and who received counseling, and on which date

### Extension of Data Pipe Line
- Staff determine if customers are in CaseWorthy or not
- Provide client ID if they are
- Use Python + Google Sheets API to read response spreadsheet
- For each customer registration
  - If they aren't a client, create a new client record and add enrollment, assessment and service information.
  - If they are an existing client, update existing client record with current information, add assessment and service information.
