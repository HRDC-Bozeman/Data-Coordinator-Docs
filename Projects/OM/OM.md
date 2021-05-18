- [Documentation Home](../../README.md)

# Outcome Matrix Data Analysis

## Table of Contents

1. [Project Background](#project-background)
1. [Data Overview](#data-overview)
1. [Analysis Strategy](#analysis-strategy)

## Project Background

The Outcome Matrix is a data collection tool that measures the overall well-being of a family across multiple dimensions. These dimensions inlcude things like food security, housing, and access to transportation. HRDC has been collecting Outcome Matrix data for several(?) years.

### Questions To Ask

1. There is an apparent increase in volatility in the housing scores starting in 2020. What is causing this? It could be an actual increase in housing instability in the community, or an artifact of the data, specifically a smaller sample of scores. 
1. How do various services correlate with changes in outcome scores? The first hypothesis I want to test is that case management services are correlated with increases in housing outcome scores. In the future I want to add controls for other factors that may also be correlated with receiving case management services and changes in housing scores. The most obvious omitted variable in this case is a person's own internal drive to better their own situation. This is obviously impossible to measure directly, especially at the scale that would be required for this analysis. 
1. What are some proxy variables that are more closely correlated with 'internal drive'? Frequency of case management services may be a good indicator.

## Data Overview

### Outcome Matrix ([OM_Scores.sql](OM_Scores.sql))

Each Outcome Matrix observation contains 7 variables:

1. EntityID - A unique client identifier
1. Domain - The dimension of well-being that is being measured
1. Score - The numerical score that the client received (1-10)
1. Date
1. Program Collecting Score
1. Alternate Date - Some of the dates in the other date column are incorrect due to data entry errors. The alternate date corresponds to the date of the assessment, and is set by the database directly. The alternate date will be incorrect in the case of a back dated assessment, but is an acceptable substitute when the primary date is clearly incorrect.
1. Username - The username of the staff member who entered the data. 'CaseBirdy' is the username for all data migrated from CAP60.


### Services ([Services.sql](Services.sql))

Each Service observation contains 8 variables

1. EntityID 
1. Description - The type of service provided
1. Units - The number of units provided
1. Value - The value of each unit provided
1. Unit of Measure - e.g. Dollars or Individuals
1. Total - The product of Units and Value
1. Date
1. Program


## Analysis Strategy

### Preliminary Analysis

The first thing I did was look at the average monthly outcome score across the different dimensions over time. The following domains have a quality sample size:

1. Education
1. Employment
1. Housing
1. Income
1. Transportation
1. Childcare
1. Food Security
1. Healthcare
1. Nutrition
1. Social Support Networks
1. Financial Literacy

The following domains have a limited sample, probably due to being used by only one program:

1. Personal Care Activities
1. Home Management

To analyze the efficacy of HRDC services I will combine the OM and Service data. The combined data set will contain information on changes in scores over time as well as services received between those score changes. 

1. EntityID
1. Domain
1. Change in score
1. Date range of the score change - This will probably be stored in 3 columns: start date, end date, and time elapsed
1. Indicator Variables for services received - A set of 1/0 columns where 1 denotes that a service was received in that period, and a 0 means a service was not received. There are many possible permutations of indicator variables that we can use to analyze different slices of our data. To start I will make a data set with an indicator for each service type description, and another data set with variables for programs. In the future I will create data sets with indicators for categories of service types, but that will require manual categorization.

## Data Processing ([data_processing.py](data_processing.py))

1. Make connection to local sql server
1. Pull data using `pandize_data()`. Alternately pull from saved .csv files.
1. Convert date columns to correct format
1. Index observations by date and EntityID
1. For each client and outcome domain, calculate the change in score from the last assessment.
1. For each client and outcome date, pivot the outcome scores to a single row with columns for each domain and change in domain score (e.g. `Housing` and `Housing_d`). At this point we have a data set that resembles this:

| EntityID | Date       | Housing | Housing_D | ... | LastScoreDate |
|----------|------------|---------|-----------|-----|---------------|
| 12345    | 01/12/2018 | 3       | NaN       | ... | NaT           |
|          | 03/05/2019 | 8       | 5         | ... | 01/12/2018    |
| 23456    | 01/01/2016 | 4       | NaN       | ... | NaT           |
| 78942    | 01/03/2017 | 5       | NaN       | ... | NaT           |
|          | 07/09/2020 | 3       | -2        | ... | 01/03/2017    |

This is the basis of any outcome matrix analysis. Other client data can be incorporated by joining on `EntityID`. 

- Other Client Data
  - Services
  - Assessments
  - Demographics
  - 













