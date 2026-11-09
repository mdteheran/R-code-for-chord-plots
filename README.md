# R-code-for-chord-plots
R code to generate chord diagrams from Excel databases, exporting high-resolution PDF and PNG format 
This code generates chord diagrams to visualize the relationship between two categorical variables. The width of each chord is proportional to the data. If a configured file is missing or the code detects a problem when reading it, it shows an error message.

1. Requirements
Install R and RStudio. The script uses the readxl and circlize packages.

2. Format of the Excel files
In the single sheet of each file, place the headers in the first row and the first column of the categorical variables.
Save the counts as numeric values. If you copy them from another sheet, use «Paste Values» so that the file contains the results of the formulas. Leave cells with missing data empty.
Use the database in the file labled "example"
3. Configuration and execution
Before running the script in RStudio, adjust these parameters:
Input path in line 11 and, add the local path to Excel file
File names 16-21 with the exact name of each file, including the .xlsx extension
Database identifiers in lines 28-29 to the Identifier of each categorical varible
Adjust the title in line 30-32
Run script.
