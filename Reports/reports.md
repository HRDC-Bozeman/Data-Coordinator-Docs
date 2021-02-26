# Reporting Documentation

- [Annual Utilization Report](#annual-utilization-report)
- [CSBG Data Entry Worksheet](#csbg-data-entry-worksheet)
- [Food Bank Clients Served](#food-bank-clients-served)
- [Senior Clients Income Report](#senior-clients-income-report)

## Annual Utilization Report

Subset of required data point for the annual utilization report. Not all of the data is available in CaseWorthy. Run the SQL script to get un-duplicated client level data, use pivot tables to get totals.

- [SQL Script](AUR/AUR2020.sql)
- Reporting Period: Calendar Year
- Programs
  - Warming Center
  - Housing First
  - Housing Choice Voucher
  - Housing Navigation
  - Homeownership Center
  - Down Payment Assistance
- Data Points
    - Total Shelter Nights Provided
    - Adults
    - Minors
    - Two-parent households
    - Single Female Households
    - Single Male Households
    - Disabled (non-veteran)
    - Veterans
    - Individuals
    - American Indian/Alaskan Native
    - Asian
    - Black/African American
    - Native Hawaiian/Pacific Islander
    - White
    - Multiracial
    - Hispanic
    - Non-hispanic

## CSBG Data Entry Worksheet

A report that pulls service and client data to generate a human readable worksheet for CDS data entry. Run the script to generate the worksheet. This report takes a long time to finish, possibly up to 20 minutes for year's worth of data. Use the filters in the `WHERE` clause to narrow the search.

- [SQL Script](CSBG/CSBG_DE_worksheet.sql)
- Run for any program tracked in CaseWorthy
- Data Points (one row per service record)
  - Client Information
      - ClientID
      - FamilyID
      - Social Security Number
      - Birth Date
      - Client Name
      - Relation to Head of Household
      - Gender
      - Citizenship Status
      - Ethnicity
      - Client Race
      - Address
      - Veteran Status
      - Active Military
      - Health Insurance
      - Disabling Condition
      - Employment
      - Income
      - Non-cash Benefits
      - Highest Grade Achieved
      - Still Attending School
  - Service Information
      - Program
      - Service Date
      - Service Total


## Food Bank Clients Served

The Food Bank needs a custom report to get an accurate count of unique clients served and overall clientele demographics. Each food box is provided to a whole household, but the service is only recorded under the head of household. The number of people in the household is recorded as the quantity of the service. Due to Covid protocols, household member information can be difficult to keep up to date on a monthly basis. This report uses the service quantity information to generate a unique client count, but the imperfect household member information to generate demographics. 

- [SQL Query](Food_Bank/clients_served.sql)
- Data Points
  - Unique Clients Served
  - Unique Households Served
  - Counts of services provided by service type
  - Client and Household Demographics
    - Age
    - Gender
    - County of Residence


## Senior Clients Income Report

This report generates the average reported income of HRDC's senior clients. It generates separate averages for different slices of the senior clientele: People who received senior services and non-senior services, people who received only senior services, and people age 60+ who only received non-senior services.

- [SQL Query](senior_programs/seniorsincome.sql)
- Data Points
  - Average Monthly Income
  - Clients who had data collected
  - Clients who did not have data collected