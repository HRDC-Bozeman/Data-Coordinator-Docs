[Documentation Home](../README.md)

# Structured Query Language - SQL

## What is SQL?
- SQL (pronounced sequel) stands for Structured Query Language
- It is a programming language that lets us pull data from (query) and manipulate databases.

## Databases and Tables

Relational databases are made up of tables and relations between them. A table consists of columns and rows. Each column represents a variable, and each row represents a record (think excel spreadsheet). Every table has 1 primary key. This can be 1 column or a combination of columns. Below is a basic example of the structure of a table that contains data on people.

![Person Table](../Images/basicsqltable.JPG)

Here is another table that contains information about cities:

![City Table](../Images/citytable.JPG)

All tables have a primary key which lets us quickly pull specific records. The primary keys in the above tables are **PersonID** and **CityID**. Some (most) tables also have a foreign key which lets us define relationships between tables. Relating tables to each other is one of the essential features of SQL. We can change our two basic tables to incorporate foreign keys.

![Basic Join](../Images/basicjoin.jpg)

The City column in the Person table has been replaced by a Foreign Key column that establishes a relationship between **Person** and **City**.









