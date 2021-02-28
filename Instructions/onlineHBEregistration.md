[Documentation Home](../README.md)

# Homebuyer Education Online Registration

Online HBE registration combines Google Forms, Form Publisher, and Google Sheets to handle all the form generation and class management.

- Household applies through a Google Form
- Their responses to intake questions are rendered onto PDF templates to reproduce old paper intake materials
- Households that applied, when they applied, their contact info, and much more are displayed on a Google Sheets response dashboard.

## The Google Form

The Google Form collects all the required information about the applying household. The questions are broken up into sections to help streamline the input.

- Applicant and Co-applicant Demographics
  - Name
  - Date of Birth
  - Last 4 of SSN
  - Contact Information
- CSBG Information
  - Housing Status
  - Non-cash Benefits
  - Health Insurance
  - Employment Status
  - Disability Status
  - Veteran Status
  - Highest Grade Achieved
- Financial Information
  - Sources of Household Income
  - Household Expenses
  - Credit and Debt Information
  

## Form Publisher Configuration

[Form Publisher](https://form-publisher.com/) is a Google Form add-on that lets you take form responses and render them onto a Google Docs or Google Sheets template. In this case household demographic information is rendered to a PDF using a Google Docs template, and household financial information is rendered using a Google Sheets template.



## The Response Dashboard

Google Form responses are typically stored in a Google Sheet. The response sheet for Homebuyer Education online registration has some extra features built in that allow for easier management and review of submitted registrations.

### Dashboard Columns

- Class Date
- Primary Applicant
- Co-applicant
- Call Back Number
- Email
- Registration
  - Google Drive link to a PDF of the household's registration
- Budget
  - Google Drive link to a PDF of the household's budget worksheet
- Confirmed Checkbox
- Attended Checkbox
- Rescheduled To drop-down
  - Lets the user change a household's class date
  - Choices for this drop-down are listed in the Dashboard Maintenance sheet
  - Changes made here change the Class Date column
  

