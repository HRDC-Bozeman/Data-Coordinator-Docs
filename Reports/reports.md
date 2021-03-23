# Reporting Documentation

- [Annual Utilization Report](#annual-utilization-report)
- [Covid-19 Vaccine Outreach](#covid-19-vaccine-outreach)
- [CSBG Data Entry Worksheet](#csbg-data-entry-worksheet)
- [Food Bank Clients Served](#food-bank-clients-served)
- [Impact Report](#impact-report)
- [Senior Clients Income Report](#senior-clients-income-report)
- [Warming Center Monthly Comparison](#warming-center-monthly-comparison)

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

## Covid-19 Vaccine Outreach

This is a report that pulls potential leads out of CaseWorthy, along with contact information and the date of the client's last interaction with HRDC

- [SQL Script](covid_outreach/CovidVaccineOutreach.sql)
- Data Points
  - Client ID
  - Family ID
  - Name
  - Contact Information
  - Address
  - Age
  - Disabling Condition
  - Race
  - Last Staff Contact
  - Last Contact Date
  - Last Contact Program

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


## Impact Report

The Impact Report is a collection of information that HRDC releases to the public which outlines the overall impact and reach of HRDC services. 

### 2020

[Impact Report Numbers - 2020](https://docs.google.com/spreadsheets/d/1Xc82BEPn5rdYI0QG38aBX7ItpkQj7IaweQZW00kkCtw/edit#gid=0) (you may have to request access to this file)



## Senior Clients Income Report

This report generates the average reported income of HRDC's senior clients. It generates separate averages for different slices of the senior clientele: People who received senior services and non-senior services, people who received only senior services, and people age 60+ who only received non-senior services.

- [SQL Query](senior_programs/seniorsincome.sql)
- Data Points
  - Average Monthly Income
  - Clients who had data collected
  - Clients who did not have data collected

## Warming Center Monthly Comparison

- [SQL Query](warming_center/wc_monthly_comparison.sql)
- Data Points
  - Total services provided by year and month
  - Unique clients by year and month
  - Client demographics
    - Gender
    - Age range
  - Nights per guest
  - Guests per night
